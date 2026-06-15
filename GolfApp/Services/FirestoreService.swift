import Foundation
import Combine

protocol FirestoreServiceProtocol {
    func fetchUser(uid: String) async throws -> User
    func saveUser(_ user: User) async throws
    func fetchProfile(userId: String) async throws -> GolfProfile
    func saveProfile(_ profile: GolfProfile) async throws
    func fetchBag(userId: String) async throws -> Bag
    func saveBag(_ bag: Bag) async throws
    func fetchCourse(id: String) async throws -> Course?
    func saveCourse(_ course: Course) async throws
    func fetchHole(courseId: String, holeNumber: Int) async throws -> Hole?
    func saveHole(_ hole: Hole, courseId: String) async throws
    func fetchRecentRounds(userId: String, limit: Int) async throws -> [Round]
    func saveRound(_ round: Round) async throws
}

/// Stub implementation — wire Firestore SDK in Xcode after adding Firebase SPM dependency.
/// All methods follow the same pattern: encode Swift model → Firestore document, decode on read.
final class FirestoreService: FirestoreServiceProtocol {

    func fetchUser(uid: String) async throws -> User {
        // Firestore.firestore().collection(Constants.Firestore.usersCollection).document(uid).getDocument()
        throw FirestoreError.notImplemented
    }

    func saveUser(_ user: User) async throws {
        // try Firestore.firestore().collection(...).document(user.id).setData(from: user)
        throw FirestoreError.notImplemented
    }

    func fetchProfile(userId: String) async throws -> GolfProfile {
        throw FirestoreError.notImplemented
    }

    func saveProfile(_ profile: GolfProfile) async throws {
        throw FirestoreError.notImplemented
    }

    func fetchBag(userId: String) async throws -> Bag {
        throw FirestoreError.notImplemented
    }

    func saveBag(_ bag: Bag) async throws {
        throw FirestoreError.notImplemented
    }

    func fetchCourse(id: String) async throws -> Course? {
        // Check cache first — return nil if not cached (triggers Golfbert API call)
        throw FirestoreError.notImplemented
    }

    func saveCourse(_ course: Course) async throws {
        throw FirestoreError.notImplemented
    }

    func fetchHole(courseId: String, holeNumber: Int) async throws -> Hole? {
        throw FirestoreError.notImplemented
    }

    func saveHole(_ hole: Hole, courseId: String) async throws {
        throw FirestoreError.notImplemented
    }

    func fetchRecentRounds(userId: String, limit: Int) async throws -> [Round] {
        throw FirestoreError.notImplemented
    }

    func saveRound(_ round: Round) async throws {
        throw FirestoreError.notImplemented
    }
}

enum FirestoreError: LocalizedError {
    case notImplemented
    case documentNotFound
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .notImplemented: return "Firestore SDK not yet wired. Complete Xcode setup first."
        case .documentNotFound: return "Document not found."
        case .decodingFailed: return "Failed to decode Firestore document."
        }
    }
}
