// Requires Firebase iOS SDK via SPM: FirebaseAuth
// Add package in Xcode → File → Add Package Dependencies
// then uncomment the Firebase/GoogleSignIn imports below.
//
// import Firebase
// import FirebaseAuth
// import GoogleSignIn

import Foundation
import AuthenticationServices
import CryptoKit   // native Apple framework — no SPM needed
import Combine

protocol AuthServiceProtocol {
    var currentUserID: String? { get }
    /// Pass the raw nonce and idToken string from ASAuthorizationAppleIDCredential.
    func signInWithApple(idToken: String, rawNonce: String) async throws -> String
    /// Returns uid — GIDSignIn.sharedInstance handles its own UI presentation.
    func signInWithGoogle(presentingViewController: UIViewController) async throws -> String
    func signInWithEmail(email: String, password: String) async throws -> String
    func signUpWithEmail(email: String, password: String) async throws -> String
    func sendPasswordReset(email: String) async throws
    func signOut() throws
    func addAuthStateListener(handler: @escaping (String?) -> Void)
}

// MARK: - Nonce utilities (no external dependencies)

enum AuthNonce {
    static func generate() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    /// SHA256 of the nonce — passed to Apple's request so Firebase can verify it.
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Production implementation
// Uncomment the body of each method after adding Firebase + GoogleSignIn SPM packages.

final class AuthService: AuthServiceProtocol {

    var currentUserID: String? {
        // return Auth.auth().currentUser?.uid
        return nil
    }

    func signInWithApple(idToken: String, rawNonce: String) async throws -> String {
        // let credential = OAuthProvider.credential(
        //     withProviderID: "apple.com",
        //     idToken: idToken,
        //     rawNonce: rawNonce
        // )
        // let result = try await Auth.auth().signIn(with: credential)
        // return result.user.uid
        throw AuthError.sdkNotConfigured
    }

    func signInWithGoogle(presentingViewController: UIViewController) async throws -> String {
        // guard let clientID = FirebaseApp.app()?.options.clientID else {
        //     throw AuthError.sdkNotConfigured
        // }
        // let config = GIDConfiguration(clientID: clientID)
        // GIDSignIn.sharedInstance.configuration = config
        // let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        // let idToken = result.user.idToken?.tokenString ?? ""
        // let accessToken = result.user.accessToken.tokenString
        // let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        // let authResult = try await Auth.auth().signIn(with: credential)
        // return authResult.user.uid
        throw AuthError.sdkNotConfigured
    }

    func signInWithEmail(email: String, password: String) async throws -> String {
        // let result = try await Auth.auth().signIn(withEmail: email, password: password)
        // guard result.user.isEmailVerified else { throw AuthError.emailNotVerified }
        // return result.user.uid
        throw AuthError.sdkNotConfigured
    }

    func signUpWithEmail(email: String, password: String) async throws -> String {
        // let result = try await Auth.auth().createUser(withEmail: email, password: password)
        // try await result.user.sendEmailVerification()
        // return result.user.uid
        throw AuthError.sdkNotConfigured
    }

    func sendPasswordReset(email: String) async throws {
        // try await Auth.auth().sendPasswordReset(withEmail: email)
        throw AuthError.sdkNotConfigured
    }

    func signOut() throws {
        // try Auth.auth().signOut()
        throw AuthError.sdkNotConfigured
    }

    func addAuthStateListener(handler: @escaping (String?) -> Void) {
        // Auth.auth().addStateDidChangeListener { _, user in handler(user?.uid) }
    }
}

enum AuthError: LocalizedError {
    case sdkNotConfigured
    case emailNotVerified
    case invalidCredentials
    case networkError

    var errorDescription: String? {
        switch self {
        case .sdkNotConfigured: return "Firebase SDK not yet configured. Add SPM package and uncomment imports."
        case .emailNotVerified: return "Please verify your email before signing in."
        case .invalidCredentials: return "Incorrect email or password."
        case .networkError: return "Network error. Please check your connection."
        }
    }
}
