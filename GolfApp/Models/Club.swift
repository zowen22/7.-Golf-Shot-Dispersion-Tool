import Foundation

struct Club: Codable, Identifiable {
    let id: String
    let bagId: String
    var clubType: ClubType
    var clubName: String                  // e.g. "7 Iron", "PW", "3 Wood"
    var distanceYards: Double?            // user entered; nil until set
    var dispersionWidth: Double?          // optional — unlocks Tier 3 when all clubs have this
    var sortOrder: Int                    // lower = longer; auto-maintained

    // Post-MVP future-proofing fields
    var gpsValidatedDistance: Double?
    var sampleCount: Int = 0

    enum ClubType: String, Codable, CaseIterable {
        case driver, wood, hybrid, iron, wedge, putter
    }

    var hasDistance: Bool { distanceYards != nil }
    var hasDispersion: Bool { dispersionWidth != nil }

    static func defaultClubs(bagId: String) -> [Club] {
        let defaults: [(ClubType, String, Int)] = [
            (.driver, "Driver", 0),
            (.wood, "3 Wood", 1),
            (.wood, "5 Wood", 2),
            (.hybrid, "4 Hybrid", 3),
            (.iron, "5 Iron", 4),
            (.iron, "6 Iron", 5),
            (.iron, "7 Iron", 6),
            (.iron, "8 Iron", 7),
            (.iron, "9 Iron", 8),
            (.wedge, "PW", 9),
            (.wedge, "GW", 10),
            (.wedge, "SW", 11),
            (.wedge, "LW", 12),
            (.putter, "Putter", 13)
        ]
        return defaults.map { type, name, order in
            Club(id: UUID().uuidString, bagId: bagId, clubType: type,
                 clubName: name, distanceYards: nil, dispersionWidth: nil, sortOrder: order)
        }
    }
}
