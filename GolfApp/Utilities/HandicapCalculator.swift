import Foundation

struct HandicapCalculator {

    /// Derives a handicap index approximation from average 18-hole score.
    /// Uses simplified USGA formula: handicap ≈ (avgScore - courseRating) × slopeAdjustment
    /// For MVP we assume a standard course (rating 72, slope 113).
    static func handicap(fromAverageScore averageScore: Int) -> Double {
        let courseRating = 72.0
        let slope = 113.0
        let differential = (Double(averageScore) - courseRating) * (113.0 / slope)
        return max(0, differential * 0.96)  // 0.96 = USGA adjustment factor
    }

    /// Derives a rough handicap from driving distance (fallback when no score entered).
    static func handicap(fromDrivingDistance distanceYards: Int) -> Double {
        // Rough correlation from published amateur data
        switch distanceYards {
        case 250...: return 2.0
        case 230..<250: return 7.0
        case 210..<230: return 12.0
        case 190..<210: return 18.0
        case 170..<190: return 24.0
        default: return 30.0
        }
    }

    /// Returns the best available handicap estimate given profile data.
    static func derivedHandicap(averageScore: Int?, drivingDistance: Int?) -> Double {
        if let score = averageScore, score > 0 {
            return handicap(fromAverageScore: score)
        }
        if let distance = drivingDistance, distance > 0 {
            return handicap(fromDrivingDistance: distance)
        }
        return 10.0  // baseline default
    }
}
