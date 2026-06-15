import XCTest
import CoreLocation
@testable import GolfApp

final class DispersionEngineTests: XCTestCase {

    // MARK: - Tier 1 Formula

    func testCalculateWidth_baseline_10handicap() {
        // 150 yards × 0.10 × 1.0 multiplier = 15 yards
        let width = DispersionEngine.calculateWidth(distanceYards: 150, handicap: 10)
        XCTAssertEqual(width, 15.0, accuracy: 0.001)
    }

    func testCalculateWidth_scratch() {
        // 200 yards × 0.10 × 0.6 = 12 yards
        let width = DispersionEngine.calculateWidth(distanceYards: 200, handicap: 0)
        XCTAssertEqual(width, 12.0, accuracy: 0.001)
    }

    func testCalculateWidth_30handicap() {
        // 250 yards × 0.10 × 2.0 = 50 yards — hits ceiling
        let width = DispersionEngine.calculateWidth(distanceYards: 250, handicap: 30)
        XCTAssertEqual(width, 50.0, accuracy: 0.001)
    }

    func testCalculateWidth_floorEnforced() {
        // Very short distance — floor of 5 yards
        let width = DispersionEngine.calculateWidth(distanceYards: 20, handicap: 0)
        XCTAssertGreaterThanOrEqual(width, 5.0)
    }

    func testCalculateWidth_ceilingEnforced() {
        // Long distance, high handicap — ceiling of 50 yards
        let width = DispersionEngine.calculateWidth(distanceYards: 400, handicap: 35)
        XCTAssertLessThanOrEqual(width, 50.0)
    }

    // MARK: - Handicap multiplier

    func testHandicapMultiplier_scratch() {
        XCTAssertEqual(DispersionEngine.handicapMultiplier(for: 0), 0.6, accuracy: 0.001)
    }

    func testHandicapMultiplier_5() {
        XCTAssertEqual(DispersionEngine.handicapMultiplier(for: 5), 0.8, accuracy: 0.001)
    }

    func testHandicapMultiplier_10() {
        XCTAssertEqual(DispersionEngine.handicapMultiplier(for: 10), 1.0, accuracy: 0.001)
    }

    func testHandicapMultiplier_30plus() {
        XCTAssertEqual(DispersionEngine.handicapMultiplier(for: 32), 2.0, accuracy: 0.001)
    }

    // MARK: - Tier 3 Interpolation

    func testInterpolation_exactMatch() {
        let data = [
            ClubDataPoint(distanceYards: 150, dispersionWidth: 6),
            ClubDataPoint(distanceYards: 300, dispersionWidth: 12)
        ]
        let width = DispersionEngine.interpolateWidth(distanceYards: 150, clubData: data)
        XCTAssertEqual(width, 6.0, accuracy: 0.001)
    }

    func testInterpolation_midpoint() {
        let data = [
            ClubDataPoint(distanceYards: 100, dispersionWidth: 5),
            ClubDataPoint(distanceYards: 200, dispersionWidth: 10)
        ]
        // 150 yards = midpoint → 7.5 yards
        let width = DispersionEngine.interpolateWidth(distanceYards: 150, clubData: data)
        XCTAssertEqual(width, 7.5, accuracy: 0.001)
    }

    func testInterpolation_belowFloor_returnsFloor() {
        let data = [ClubDataPoint(distanceYards: 100, dispersionWidth: 4)]
        let width = DispersionEngine.interpolateWidth(distanceYards: 50, clubData: data)
        XCTAssertGreaterThanOrEqual(width, 5.0)
    }

    func testInterpolation_aboveCeiling_returnsCeiling() {
        let data = [ClubDataPoint(distanceYards: 300, dispersionWidth: 60)]
        let width = DispersionEngine.interpolateWidth(distanceYards: 350, clubData: data)
        XCTAssertLessThanOrEqual(width, 50.0)
    }

    func testInterpolation_emptyData_fallsBackToFormula() {
        // Empty club data should not crash
        let width = DispersionEngine.interpolateWidth(distanceYards: 150, clubData: [])
        XCTAssertGreaterThanOrEqual(width, 5.0)
        XCTAssertLessThanOrEqual(width, 50.0)
    }

    // MARK: - Skew

    func testSkew_center_equalWidths() {
        let (left, right) = DispersionEngine.applySkew(width: 10, skew: .center)
        XCTAssertEqual(left, right)
        XCTAssertEqual(left, 10.0, accuracy: 0.001)
    }

    func testSkew_leftCenter_narrowerLeft() {
        let (left, right) = DispersionEngine.applySkew(width: 10, skew: .leftCenter)
        // 1/4 left of center means less on left, more on right
        XCTAssertLessThan(left, right)
    }

    func testSkew_rightCenter_narrowerRight() {
        let (left, right) = DispersionEngine.applySkew(width: 10, skew: .rightCenter)
        XCTAssertGreaterThan(left, right)
    }

    func testSkew_leftEdge_extremeRight() {
        let (_, right) = DispersionEngine.applySkew(width: 10, skew: .leftEdge)
        XCTAssertGreaterThan(right, 15.0)
    }

    func testSkew_totalWidthConserved() {
        // Total width (left + right) should equal 2× input for all skew positions
        let baseWidth = 10.0
        for skew in DispersionSkew.allCases {
            let (left, right) = DispersionEngine.applySkew(width: baseWidth, skew: skew)
            XCTAssertEqual(left + right, baseWidth * 2, accuracy: 0.001, "Skew \(skew) failed")
        }
    }

    // MARK: - Ellipse builder

    func testBuildEllipse_returnsCorrectPointCount() {
        let center = CLLocationCoordinate2D(latitude: 37.5, longitude: -121.9)
        let coords = DispersionEngine.buildEllipse(
            center: center, aimBearing: 90, leftWidthYards: 10,
            rightWidthYards: 10, lengthYards: 150, pointCount: 32
        )
        XCTAssertEqual(coords.count, 32)
    }

    func testBuildEllipse_allPointsNearCenter() {
        let center = CLLocationCoordinate2D(latitude: 37.5, longitude: -121.9)
        let coords = DispersionEngine.buildEllipse(
            center: center, aimBearing: 0, leftWidthYards: 20,
            rightWidthYards: 20, lengthYards: 200
        )
        // All ellipse points should be within ~500m of center
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        for coord in coords {
            let dist = centerLoc.distance(from: CLLocation(latitude: coord.latitude, longitude: coord.longitude))
            XCTAssertLessThan(dist, 500, "Point \(coord) too far from center")
        }
    }
}
