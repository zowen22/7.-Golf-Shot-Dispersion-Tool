import Foundation
import SwiftUI
import AuthenticationServices

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private weak var appState: AppState?

    // Stored between prepareAppleSignIn() and handleAppleSignIn()
    private var pendingAppleNonce: String?

    init(appState: AppState) {
        self.authService = appState.authService
        self.firestoreService = appState.firestoreService
        self.appState = appState
    }

    var canSignIn: Bool { !email.isEmpty && !password.isEmpty }
    var canSignUp: Bool {
        !email.isEmpty && password.count >= 6
            && !confirmPassword.isEmpty && password == confirmPassword
    }

    // MARK: - Apple Sign In (two-step)

    /// Step 1 — called in SignInWithAppleButton's onRequest closure.
    /// Returns the SHA256 nonce to set on the request.
    func prepareAppleSignIn() -> String {
        let nonce = AuthNonce.generate()
        pendingAppleNonce = nonce
        return AuthNonce.sha256(nonce)
    }

    /// Step 2 — called in SignInWithAppleButton's onCompletion closure.
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard
                let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8),
                let rawNonce = pendingAppleNonce
            else {
                errorMessage = "Apple Sign In failed — missing credential data."
                return
            }
            perform {
                let uid = try await self.authService.signInWithApple(idToken: idToken, rawNonce: rawNonce)
                await self.routeAfterAuth(uid: uid)
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Google Sign In

    func signInWithGoogle(presentingVC: UIViewController) {
        perform {
            let uid = try await self.authService.signInWithGoogle(presentingViewController: presentingVC)
            await self.routeAfterAuth(uid: uid)
        }
    }

    // MARK: - Email

    func signInWithEmail() {
        guard canSignIn else { return }
        perform {
            let uid = try await self.authService.signInWithEmail(email: self.email, password: self.password)
            await self.routeAfterAuth(uid: uid)
        }
    }

    func signUpWithEmail() {
        guard canSignUp else { return }
        perform {
            let uid = try await self.authService.signUpWithEmail(email: self.email, password: self.password)
            await self.routeAfterAuth(uid: uid)
        }
    }

    func sendPasswordReset() {
        guard !email.isEmpty else { errorMessage = "Enter your email address first."; return }
        perform { try await self.authService.sendPasswordReset(email: self.email) }
    }

    // MARK: - Routing

    private func routeAfterAuth(uid: String) async {
        if let user = try? await firestoreService.fetchUser(uid: uid) {
            appState?.authState = user.onboardingComplete ? .authenticated(user) : .onboarding(user)
        } else {
            let newUser = User(
                id: uid, name: "", email: email, createdAt: Date(),
                subscriptionStatus: .free, referralCode: generateReferralCode(),
                handedness: .right, distanceUnit: .yards, onboardingComplete: false
            )
            try? await firestoreService.saveUser(newUser)
            appState?.authState = .onboarding(newUser)
        }
    }

    private func perform(_ action: @escaping () async throws -> Void) {
        isLoading = true
        errorMessage = nil
        Task {
            defer { isLoading = false }
            do { try await action() }
            catch { errorMessage = error.localizedDescription }
        }
    }

    private func generateReferralCode() -> String {
        String(UUID().uuidString.prefix(8).uppercased())
    }
}
