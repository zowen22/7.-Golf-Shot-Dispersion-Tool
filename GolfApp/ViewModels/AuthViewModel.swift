import Foundation
import SwiftUI

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

    init(appState: AppState) {
        self.authService = appState.authService
        self.firestoreService = appState.firestoreService
        self.appState = appState
    }

    var canSignIn: Bool {
        !email.isEmpty && !password.isEmpty
    }

    var canSignUp: Bool {
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
    }

    func signInWithApple() {
        perform {
            let uid = try await self.authService.signInWithApple()
            await self.routeAfterAuth(uid: uid)
        }
    }

    func signInWithGoogle() {
        perform {
            let uid = try await self.authService.signInWithGoogle()
            await self.routeAfterAuth(uid: uid)
        }
    }

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
        guard !email.isEmpty else {
            errorMessage = "Enter your email address first."
            return
        }
        perform {
            try await self.authService.sendPasswordReset(email: self.email)
        }
    }

    private func routeAfterAuth(uid: String) async {
        if let user = try? await firestoreService.fetchUser(uid: uid) {
            appState?.authState = user.onboardingComplete ? .authenticated(user) : .onboarding(user)
        } else {
            // New user — route to onboarding (profile will be created there)
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
            do {
                try await action()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func generateReferralCode() -> String {
        String(UUID().uuidString.prefix(8).uppercased())
    }
}
