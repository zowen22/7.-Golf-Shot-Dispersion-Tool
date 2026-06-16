import XCTest
@testable import GolfApp

final class BagViewModelTests: XCTestCase {

    // MARK: - Unlock state logic (via Bag model, which is pure)

    func testHasAnyClubs_emptyBag_false() {
        let bag = makeBag(clubs: [])
        XCTAssertFalse(bag.hasAnyClubs)
    }

    func testHasAnyClubs_putterOnly_false() {
        let putter = makeClub(type: .putter, distance: nil)
        let bag = makeBag(clubs: [putter])
        XCTAssertFalse(bag.hasAnyClubs)
    }

    func testHasAnyClubs_oneIron_true() {
        let iron = makeClub(type: .iron, distance: 150)
        let bag = makeBag(clubs: [iron])
        XCTAssertTrue(bag.hasAnyClubs)
    }

    func testHasAllDistances_allEntered_true() {
        let clubs = [
            makeClub(type: .driver, distance: 250),
            makeClub(type: .iron, distance: 150)
        ]
        let bag = makeBag(clubs: clubs)
        XCTAssertTrue(bag.hasAllDistances)
    }

    func testHasAllDistances_oneMissing_false() {
        let clubs = [
            makeClub(type: .driver, distance: 250),
            makeClub(type: .iron, distance: nil)  // missing
        ]
        let bag = makeBag(clubs: clubs)
        XCTAssertFalse(bag.hasAllDistances)
    }

    func testHasAllDispersions_allEntered_true() {
        let clubs = [
            makeClub(type: .driver, distance: 250, dispersion: 20),
            makeClub(type: .iron, distance: 150, dispersion: 8)
        ]
        let bag = makeBag(clubs: clubs)
        XCTAssertTrue(bag.hasAllDispersions)
    }

    func testHasAllDispersions_distanceButNoDispersion_false() {
        let clubs = [
            makeClub(type: .driver, distance: 250, dispersion: nil)
        ]
        let bag = makeBag(clubs: clubs)
        XCTAssertFalse(bag.hasAllDispersions)
    }

    func testSortedClubs_longestFirst() {
        let clubs = [
            makeClub(type: .iron, distance: 100, sortOrder: 2),
            makeClub(type: .driver, distance: 250, sortOrder: 0),
            makeClub(type: .wood, distance: 220, sortOrder: 1)
        ]
        let bag = makeBag(clubs: clubs)
        let sorted = bag.sortedClubs
        XCTAssertEqual(sorted[0].sortOrder, 0)
        XCTAssertEqual(sorted[1].sortOrder, 1)
        XCTAssertEqual(sorted[2].sortOrder, 2)
    }

    func testDefaultClubs_createsNonEmptyList() {
        let defaults = Club.defaultClubs(bagId: "test-bag-id")
        XCTAssertFalse(defaults.isEmpty)
        XCTAssertTrue(defaults.contains { $0.clubType == .driver })
        XCTAssertTrue(defaults.contains { $0.clubType == .putter })
    }

    func testDefaultClubs_allDistancesNil() {
        let defaults = Club.defaultClubs(bagId: "test")
        XCTAssertTrue(defaults.allSatisfy { $0.distanceYards == nil })
    }

    // MARK: - HandicapCalculator

    func testHandicap_score90() {
        let hdcp = HandicapCalculator.handicap(fromAverageScore: 90)
        XCTAssertGreaterThan(hdcp, 14)
        XCTAssertLessThan(hdcp, 20)
    }

    func testHandicap_score72_scratch() {
        let hdcp = HandicapCalculator.handicap(fromAverageScore: 72)
        XCTAssertEqual(hdcp, 0.0, accuracy: 0.01)
    }

    func testHandicap_drivingDistance250() {
        let hdcp = HandicapCalculator.handicap(fromDrivingDistance: 250)
        XCTAssertLessThan(hdcp, 10)
    }

    // MARK: - BearingCalculator

    func testBearing_dueNorth() {
        let from = CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0)
        let to = CLLocationCoordinate2D(latitude: 37.1, longitude: -122.0)
        let bearing = BearingCalculator.bearing(from: from, to: to)
        XCTAssertEqual(bearing, 0.0, accuracy: 2.0)
    }

    func testBearing_dueEast() {
        let from = CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0)
        let to = CLLocationCoordinate2D(latitude: 37.0, longitude: -121.9)
        let bearing = BearingCalculator.bearing(from: from, to: to)
        XCTAssertEqual(bearing, 90.0, accuracy: 2.0)
    }

    func testDistanceYards_knownDistance() {
        // ~100m apart should be ~109 yards
        let from = CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0)
        let to = CLLocationCoordinate2D(latitude: 37.0009, longitude: -122.0)
        let yards = BearingCalculator.distanceYards(from: from, to: to)
        XCTAssertEqual(yards, 109, accuracy: 10)
    }

    // MARK: - Helpers

    private func makeClub(type: Club.ClubType, distance: Double?, dispersion: Double? = nil, sortOrder: Int = 0) -> Club {
        Club(id: UUID().uuidString, bagId: "bag1", clubType: type,
             clubName: type.rawValue.capitalized, distanceYards: distance,
             dispersionWidth: dispersion, sortOrder: sortOrder)
    }

    private func makeBag(clubs: [Club]) -> Bag {
        Bag(id: "bag1", userId: "user1", clubs: clubs)
    }
}

// CLLocationCoordinate2D imported for tests
import CoreLocation
