import Foundation
import CoreLocation

enum DispersionSkew: String, Codable, CaseIterable {
    case leftEdge = "left_edge"
    case leftCenter = "left_center"
    case center = "center"
    case rightCenter = "right_center"
    case rightEdge = "right_edge"

    var displayLabel: String {
        switch self {
        case .leftEdge: return "L"
        case .leftCenter: return "←"
        case .center: return "·"
        case .rightCenter: return "→"
        case .rightEdge: return "R"
        }
    }
}

struct DispersionSettings: Codable {
    var skew: DispersionSkew = .center
    var useCustomPerClub: Bool = false
    var defaultFormulaMultiplier: Double = 1.0  // derived from handicap
}

struct ClubDataPoint {
    let distanceYards: Double
    let dispersionWidth: Double
}

struct DispersionResult {
    let leftWidth: Double
    let rightWidth: Double
    let length: Double
    let ellipseCoordinates: [CLLocationCoordinate2D]
}

enum DispersionTier {
    case tier1Formula           // score/driving distance only
    case tier2ClubDistances     // all clubs have distances (unlocks suggestion box)
    case tier3ClubDispersions   // all clubs have dispersion widths (unlocks custom shape)
}
