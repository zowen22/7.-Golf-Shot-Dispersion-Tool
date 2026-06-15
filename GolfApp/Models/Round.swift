import Foundation

struct Round: Codable, Identifiable {
    let id: String
    let userId: String
    let courseId: String
    var teeColor: String
    var startedAt: Date
    var completedAt: Date?
    var mode: RoundMode
    var holesPlayed: [Int]

    enum RoundMode: String, Codable {
        case round, study
    }
}

// Post-MVP: Shot document — fields present now, nothing writes to them until Tier 4 GPS tracking
struct Shot: Codable, Identifiable {
    let id: String
    let roundId: String
    let holeId: String
    var shotCoordinate: Coordinate?       // post-MVP GPS
    var clubUsed: String?                 // post-MVP GPS
    var actualDistance: Double?           // post-MVP GPS
    var timestamp: Date?                  // post-MVP GPS
}
