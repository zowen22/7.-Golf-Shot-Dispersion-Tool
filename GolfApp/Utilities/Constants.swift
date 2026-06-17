import Foundation

enum Constants {
    enum API {
        // Set via Xcode build configuration / xcconfig — never commit actual keys
        static var golfbertAPIKey: String {
            Bundle.main.infoDictionary?["GOLFBERT_API_KEY"] as? String ?? ""
        }
        static var golfbertSecretKey: String {
            Bundle.main.infoDictionary?["GOLFBERT_SECRET_KEY"] as? String ?? ""
        }
        static var mapboxToken: String {
            Bundle.main.infoDictionary?["MBXAccessToken"] as? String ?? ""
        }
        static let golfbertBaseURL = "https://api.golfbert.com/v1"
        static let golfbertCacheExpiryDays = 30
    }

    enum Firestore {
        static let usersCollection = "users"
        static let profilesCollection = "profiles"
        static let bagsCollection = "bags"
        static let coursesCollection = "courses"
        static let roundsCollection = "rounds"
    }

    enum Dispersion {
        static let minimumWidthYards = 5.0
        static let maximumWidthYards = 50.0
        static let ellipseOpacity = 0.35
        static let ellipseColor = "FFFF00"  // yellow
        static let targetFPS: Double = 60
        static let debounceInterval: Double = 1.0 / 60.0  // ~16ms
    }

    enum Onboarding {
        static let lastStepKey = "onboarding_last_step"
        static let completeKey = "onboarding_complete"
        static let distanceUnitKey = "distance_unit"
        static let defaultSkewKey = "default_skew"
    }

    enum Map {
        static let holePrefetchCount = 18
        static let nearbyCoursesRadius = 50_000  // meters (50km)
        static let maxNearbyResults = 5
        static let searchDebounceSeconds = 0.5
    }
}
