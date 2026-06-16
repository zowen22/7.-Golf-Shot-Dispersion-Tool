import Foundation

struct User: Codable, Identifiable {
    let id: String                        // Firestore document ID = Firebase Auth UID
    var name: String
    var email: String
    var createdAt: Date
    var subscriptionStatus: SubscriptionStatus
    var subscriptionExpiry: Date?
    var referralCode: String
    var referredBy: String?
    var handedness: Handedness
    var distanceUnit: DistanceUnit
    var onboardingComplete: Bool

    // Post-MVP future-proofing fields (nothing writes to these until Tier 4)
    var totalRounds: Int = 0
    var totalShots: Int = 0

    enum SubscriptionStatus: String, Codable {
        case free, paid
    }

    enum Handedness: String, Codable {
        case left, right
    }

    enum DistanceUnit: String, Codable {
        case yards, meters
    }

    enum CodingKeys: String, CodingKey {
        case id, name, email, createdAt, subscriptionStatus, subscriptionExpiry
        case referralCode, referredBy, handedness, distanceUnit, onboardingComplete
        case totalRounds, totalShots
    }
}
