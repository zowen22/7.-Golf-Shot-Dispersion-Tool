import Foundation
import Combine

protocol AuthServiceProtocol {
    var currentUserID: String? { get }
    func signInWithApple() async throws -> String  // returns uid
    func signInWithGoogle() async throws -> String
    func signInWithEmail(email: String, password: String) async throws -> String
    func signUpWithEmail(email: String, password: String) async throws -> String
    func sendPasswordReset(email: String) async throws
    func signOut() throws
    func addAuthStateListener(handler: @escaping (Any?) -> Void)
}

/// Stub implementation — wire Firebase SDK calls in Xcode after adding SPM dependency.
final class AuthService: AuthServiceProtocol {
    var currentUserID: String? { nil }  // replace with Auth.auth().currentUser?.uid

    func signInWithApple() async throws -> String {
        // 1. Create ASAuthorizationAppleIDRequest via ASAuthorizationController
        // 2. Get credential from ASAuthorizationControllerDelegate
        // 3. Pass nonce + identityToken to Firebase OAuthProvider.credential
        // 4. Auth.auth().signIn(with: credential)
        // 5. Return Auth.auth().currentUser!.uid
        throw AuthError.notImplemented
    }

    func signInWithGoogle() async throws -> String {
        // 1. GIDSignIn.sharedInstance.signIn(withPresenting:)
        // 2. Create Firebase credential from GIDGoogleUser tokens
        // 3. Auth.auth().signIn(with: credential)
        // 4. Return uid
        throw AuthError.notImplemented
    }

    func signInWithEmail(email: String, password: String) async throws -> String {
        // Auth.auth().signIn(withEmail: email, password: password)
        // Check result.user.isEmailVerified
        throw AuthError.notImplemented
    }

    func signUpWithEmail(email: String, password: String) async throws -> String {
        // Auth.auth().createUser(withEmail: email, password: password)
        // result.user.sendEmailVerification()
        throw AuthError.notImplemented
    }

    func sendPasswordReset(email: String) async throws {
        // Auth.auth().sendPasswordReset(withEmail: email)
        throw AuthError.notImplemented
    }

    func signOut() throws {
        // try Auth.auth().signOut()
        throw AuthError.notImplemented
    }

    func addAuthStateListener(handler: @escaping (Any?) -> Void) {
        // Auth.auth().addStateDidChangeListener { _, user in handler(user) }
    }
}

enum AuthError: LocalizedError {
    case notImplemented
    case emailNotVerified
    case invalidCredentials
    case networkError

    var errorDescription: String? {
        switch self {
        case .notImplemented: return "Firebase SDK not yet wired. Complete Xcode setup first."
        case .emailNotVerified: return "Please verify your email before signing in."
        case .invalidCredentials: return "Incorrect email or password."
        case .networkError: return "Network error. Please check your connection."
        }
    }
}
