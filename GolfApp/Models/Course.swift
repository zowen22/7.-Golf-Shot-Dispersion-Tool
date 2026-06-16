import Foundation
import CoreLocation

struct Course: Codable, Identifiable {
    let id: String                        // Golfbert course ID
    var name: String
    var city: String
    var state: String
    var numHoles: Int
    var tees: [Tee]
    var cachedAt: Date

    var displayName: String { "\(name), \(city), \(state)" }

    struct Tee: Codable {
        var name: String                  // e.g. "Championship", "Blue", "White", "Red"
        var color: String
        var totalYardage: Int
    }
}

struct CourseSearchResult: Codable, Identifiable {
    let id: String
    var name: String
    var city: String
    var state: String
    var numHoles: Int
    var distanceFromUser: Double?         // meters; nil when not in GPS mode

    var distanceDisplay: String? {
        guard let d = distanceFromUser else { return nil }
        let miles = d / 1609.34
        return String(format: "%.1f mi", miles)
    }
}
