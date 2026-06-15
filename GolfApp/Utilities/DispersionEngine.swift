import Foundation
import CoreLocation

/// Pure functions — no side effects, no services. Fully unit testable.
struct DispersionEngine {

    // MARK: - Tier 1: Formula-based width

    static func calculateWidth(distanceYards: Double, handicap: Double) -> Double {
        let base = distanceYards * 0.10
        let multiplier = handicapMultiplier(for: handicap)
        let raw = base * multiplier
        return clamped(raw)
    }

    static func handicapMultiplier(for handicap: Double) -> Double {
        // Non-linear scale from spec
        switch handicap {
        case ..<0:    return 0.6
        case 0..<3:   return 0.6
        case 3..<7:   return 0.8
        case 7..<12:  return 1.0
        case 12..<17: return 1.2
        case 17..<22: return 1.4
        case 22..<27: return 1.6
        case 27..<30: return 1.8
        default:      return 2.0
        }
    }

    // MARK: - Tier 3: Interpolated width from club data

    static func interpolateWidth(distanceYards: Double, clubData: [ClubDataPoint]) -> Double {
        guard !clubData.isEmpty else {
            return calculateWidth(distanceYards: distanceYards, handicap: 10)
        }
        let sorted = clubData.sorted { $0.distanceYards < $1.distanceYards }

        // Below shortest club — extrapolate down, floor applies
        if distanceYards <= sorted.first!.distanceYards {
            return clamped(sorted.first!.dispersionWidth)
        }
        // Above longest club — cap at driver dispersion
        if distanceYards >= sorted.last!.distanceYards {
            return clamped(sorted.last!.dispersionWidth)
        }
        // Find surrounding two points and linearly interpolate
        for i in 0..<(sorted.count - 1) {
            let lo = sorted[i]
            let hi = sorted[i + 1]
            if distanceYards >= lo.distanceYards && distanceYards <= hi.distanceYards {
                let t = (distanceYards - lo.distanceYards) / (hi.distanceYards - lo.distanceYards)
                let interpolated = lo.dispersionWidth + t * (hi.dispersionWidth - lo.dispersionWidth)
                return clamped(interpolated)
            }
        }
        return clamped(sorted.last!.dispersionWidth)
    }

    // MARK: - Skew

    /// Returns (leftWidth, rightWidth) in yards based on skew selection.
    static func applySkew(width: Double, skew: DispersionSkew) -> (leftWidth: Double, rightWidth: Double) {
        switch skew {
        case .center:
            return (width, width)
        case .leftCenter:
            // 1/4 left, 3/4 right of center
            return (width * 0.5, width * 1.5)
        case .rightCenter:
            // 3/4 left, 1/4 right of center
            return (width * 1.5, width * 0.5)
        case .leftEdge:
            return (width * 0.1, width * 1.9)
        case .rightEdge:
            return (width * 1.9, width * 0.1)
        }
    }

    // MARK: - Ellipse builder

    /// Builds ellipse polygon coordinates aligned to aimDirection (bearing in degrees).
    /// Length is the shot distance in yards (converted to meters for CLLocation math).
    static func buildEllipse(
        center: CLLocationCoordinate2D,
        aimBearing: Double,
        leftWidthYards: Double,
        rightWidthYards: Double,
        lengthYards: Double,
        pointCount: Int = 64
    ) -> [CLLocationCoordinate2D] {
        let leftWidthMeters = leftWidthYards * 0.9144
        let rightWidthMeters = rightWidthYards * 0.9144
        let lengthMeters = lengthYards * 0.9144
        let halfLength = lengthMeters / 2

        var points: [CLLocationCoordinate2D] = []
        for i in 0..<pointCount {
            let angle = (Double(i) / Double(pointCount)) * 2 * .pi
            // Ellipse in local coordinate space (x = cross-track, y = along-track)
            let x = (angle > .pi ? leftWidthMeters : rightWidthMeters) * sin(angle)
            let y = halfLength * cos(angle)

            // Rotate by aim bearing and offset from center
            let bearing = aimBearing * .pi / 180
            let rotatedX = x * cos(bearing) - y * sin(bearing)
            let rotatedY = x * sin(bearing) + y * cos(bearing)

            let coord = offset(coordinate: center, dNorth: rotatedY, dEast: rotatedX)
            points.append(coord)
        }
        return points
    }

    // MARK: - Private helpers

    private static func clamped(_ width: Double) -> Double {
        min(max(width, 5.0), 50.0)
    }

    private static func offset(
        coordinate: CLLocationCoordinate2D,
        dNorth: Double,   // meters
        dEast: Double     // meters
    ) -> CLLocationCoordinate2D {
        let earthRadius = 6_371_000.0
        let dLat = dNorth / earthRadius
        let dLon = dEast / (earthRadius * cos(coordinate.latitude * .pi / 180))
        return CLLocationCoordinate2D(
            latitude: coordinate.latitude + dLat * 180 / .pi,
            longitude: coordinate.longitude + dLon * 180 / .pi
        )
    }
}
