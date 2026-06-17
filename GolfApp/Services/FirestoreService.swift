// Requires Firebase iOS SDK via SPM: FirebaseFirestore + FirebaseFirestoreSwift
// Add package in Xcode → File → Add Package Dependencies
// then uncomment the imports below.
//
// import FirebaseFirestore
// import FirebaseFirestoreSwift

import Foundation

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

// MARK: - Production implementation
// Each method follows the same pattern:
//   read  → collection.document(id).getDocument() → try doc.data(as: Model.self)
//   write → collection.document(id).setData(from: model, merge: true)
//
// Uncomment body of each method after adding Firebase SPM package.
// Firestore offline persistence (enabled below) handles reads with no connection automatically.

final class FirestoreService: FirestoreServiceProtocol {

    // private let db: Firestore = {
    //     let db = Firestore.firestore()
    //     let settings = FirestoreSettings()
    //     settings.isPersistenceEnabled = true   // offline cache
    //     db.settings = settings
    //     return db
    // }()

    // MARK: User

    func fetchUser(uid: String) async throws -> User {
        // let doc = try await db.collection(Constants.Firestore.usersCollection).document(uid).getDocument()
        // guard doc.exists else { throw FirestoreError.documentNotFound }
        // return try doc.data(as: User.self)
        throw FirestoreError.sdkNotConfigured
    }

    func saveUser(_ user: User) async throws {
        // try db.collection(Constants.Firestore.usersCollection).document(user.id).setData(from: user, merge: true)
        throw FirestoreError.sdkNotConfigured
    }

    // MARK: Profile

    func fetchProfile(userId: String) async throws -> GolfProfile {
        // let snapshot = try await db.collection(Constants.Firestore.profilesCollection)
        //     .whereField("userId", isEqualTo: userId)
        //     .limit(to: 1)
        //     .getDocuments()
        // guard let doc = snapshot.documents.first else { throw FirestoreError.documentNotFound }
        // return try doc.data(as: GolfProfile.self)
        throw FirestoreError.sdkNotConfigured
    }

    func saveProfile(_ profile: GolfProfile) async throws {
        // try db.collection(Constants.Firestore.profilesCollection).document(profile.id).setData(from: profile, merge: true)
        throw FirestoreError.sdkNotConfigured
    }

    // MARK: Bag

    func fetchBag(userId: String) async throws -> Bag {
        // let snapshot = try await db.collection(Constants.Firestore.bagsCollection)
        //     .whereField("userId", isEqualTo: userId)
        //     .limit(to: 1)
        //     .getDocuments()
        // guard let doc = snapshot.documents.first else { throw FirestoreError.documentNotFound }
        // return try doc.data(as: Bag.self)
        throw FirestoreError.sdkNotConfigured
    }

    func saveBag(_ bag: Bag) async throws {
        // try db.collection(Constants.Firestore.bagsCollection).document(bag.id).setData(from: bag, merge: true)
        throw FirestoreError.sdkNotConfigured
    }

    // MARK: Course cache
    // Path: courses/{courseId}  — cached after first Golfbert API fetch

    func fetchCourse(id: String) async throws -> Course? {
        // let doc = try await db.collection(Constants.Firestore.coursesCollection).document(id).getDocument()
        // guard doc.exists else { return nil }
        // let course = try doc.data(as: Course.self)
        // let staleDays = Calendar.current.dateComponents([.day], from: course.cachedAt, to: Date()).day ?? 0
        // return staleDays < Constants.API.golfbertCacheExpiryDays ? course : nil
        return nil  // falls through to Golfbert API call
    }

    func saveCourse(_ course: Course) async throws {
        // try db.collection(Constants.Firestore.coursesCollection).document(course.id).setData(from: course, merge: true)
        throw FirestoreError.sdkNotConfigured
    }

    // MARK: Hole cache
    // Path: courses/{courseId}/holes/{holeNumber}

    func fetchHole(courseId: String, holeNumber: Int) async throws -> Hole? {
        // let doc = try await db.collection(Constants.Firestore.coursesCollection)
        //     .document(courseId)
        //     .collection("holes")
        //     .document("\(holeNumber)")
        //     .getDocument()
        // guard doc.exists else { return nil }
        // return try doc.data(as: Hole.self)
        return nil
    }

    func saveHole(_ hole: Hole, courseId: String) async throws {
        // try db.collection(Constants.Firestore.coursesCollection)
        //     .document(courseId)
        //     .collection("holes")
        //     .document("\(hole.holeNumber)")
        //     .setData(from: hole, merge: true)
        throw FirestoreError.sdkNotConfigured
    }

    // MARK: Rounds

    func fetchRecentRounds(userId: String, limit: Int) async throws -> [Round] {
        // let snapshot = try await db.collection(Constants.Firestore.roundsCollection)
        //     .whereField("userId", isEqualTo: userId)
        //     .order(by: "startedAt", descending: true)
        //     .limit(to: limit)
        //     .getDocuments()
        // return try snapshot.documents.map { try $0.data(as: Round.self) }
        return []
    }

    func saveRound(_ round: Round) async throws {
        // try db.collection(Constants.Firestore.roundsCollection).document(round.id).setData(from: round, merge: true)
        throw FirestoreError.sdkNotConfigured
    }
}

enum FirestoreError: LocalizedError {
    case sdkNotConfigured
    case documentNotFound
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .sdkNotConfigured: return "Firestore SDK not yet configured. Add SPM package and uncomment imports."
        case .documentNotFound: return "Document not found."
        case .decodingFailed: return "Failed to decode Firestore document."
        }
    }
}
