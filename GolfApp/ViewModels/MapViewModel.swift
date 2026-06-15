import Foundation
import Combine
import CoreLocation

@MainActor
final class MapViewModel: ObservableObject {
    // MARK: - Published state
    @Published var shotCoordinate: CLLocationCoordinate2D?
    @Published var distanceToGreenYards: Double = 0
    @Published var distanceFromTeeYards: Double = 0
    @Published var dispersionEllipse: [CLLocationCoordinate2D] = []
    @Published var suggestedClub: String?
    @Published var suggestedAlternateClub: String?
    @Published var skew: DispersionSkew = .center
    @Published var hole: Hole?
    @Published var selectedTeeColor: String = "White"
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var dispersionTier: DispersionTier = .tier1Formula

    // MARK: - Dependencies
    private let firestoreService: FirestoreServiceProtocol
    private let networkService: NetworkServiceProtocol
    private var bag: Bag?
    private var profile: GolfProfile?
    private var cancellables = Set<AnyCancellable>()

    init(appState: AppState) {
        self.firestoreService = appState.firestoreService
        self.networkService = appState.networkService
    }

    // MARK: - Hole loading

    func loadHole(courseId: String, holeNumber: Int, teeColor: String) {
        isLoading = true
        selectedTeeColor = teeColor
        Task {
            defer { isLoading = false }
            do {
                if let cached = try? await firestoreService.fetchHole(courseId: courseId, holeNumber: holeNumber) {
                    self.hole = cached
                } else {
                    let fetched = try await networkService.fetchHole(courseId: courseId, holeNumber: holeNumber)
                    self.hole = fetched
                    try? await firestoreService.saveHole(fetched, courseId: courseId)
                }
                resetShotMarker()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func updateBag(_ bag: Bag, profile: GolfProfile) {
        self.bag = bag
        self.profile = profile
        updateDispersionTier()
        recalculate()
    }

    // MARK: - Shot marker drag

    func moveShotMarker(to coordinate: CLLocationCoordinate2D) {
        shotCoordinate = coordinate
        recalculate()
    }

    func updateSkew(_ newSkew: DispersionSkew) {
        skew = newSkew
        recalculate()
    }

    // MARK: - Core calculation

    private func recalculate() {
        guard let shot = shotCoordinate, let hole = hole else { return }
        guard let teeBox = hole.teeBox(forColor: selectedTeeColor) else { return }

        let green = hole.greenCenterCoordinate.clLocation
        let tee = teeBox.coordinate.clLocation

        distanceToGreenYards = BearingCalculator.distanceYards(from: shot, to: green)
        distanceFromTeeYards = BearingCalculator.distanceYards(from: tee, to: shot)

        let width = calculateDispersionWidth(distanceYards: distanceToGreenYards)
        let (left, right) = DispersionEngine.applySkew(width: width, skew: skew)
        let bearing = BearingCalculator.bearing(from: shot, to: green)

        dispersionEllipse = DispersionEngine.buildEllipse(
            center: shot,
            aimBearing: bearing,
            leftWidthYards: left,
            rightWidthYards: right,
            lengthYards: distanceToGreenYards * 0.6  // ellipse covers ~60% of shot distance
        )

        updateClubSuggestion()
    }

    private func calculateDispersionWidth(distanceYards: Double) -> Double {
        guard let profile = profile else { return DispersionEngine.calculateWidth(distanceYards: distanceYards, handicap: 10) }

        switch dispersionTier {
        case .tier3ClubDispersions:
            guard let bag = bag else { fallthrough }
            let dataPoints = bag.clubs
                .filter { $0.hasDispersion && $0.hasDistance }
                .compactMap { club -> ClubDataPoint? in
                    guard let d = club.distanceYards, let w = club.dispersionWidth else { return nil }
                    return ClubDataPoint(distanceYards: d, dispersionWidth: w)
                }
            return DispersionEngine.interpolateWidth(distanceYards: distanceYards, clubData: dataPoints)

        case .tier1Formula, .tier2ClubDistances:
            return DispersionEngine.calculateWidth(distanceYards: distanceYards, handicap: profile.derivedHandicap)
        }
    }

    private func updateClubSuggestion() {
        guard dispersionTier >= .tier2ClubDistances, let bag = bag else {
            suggestedClub = nil
            suggestedAlternateClub = nil
            return
        }
        let target = distanceToGreenYards
        let candidates = bag.clubs
            .filter { $0.hasDistance && !$0.clubType.isPutter }
            .sorted { abs(($0.distanceYards ?? 0) - target) < abs(($1.distanceYards ?? 0) - target) }

        suggestedClub = candidates.first?.clubName
        // Show second option if within 5% of target distance
        if let second = candidates.dropFirst().first,
           let secondDist = second.distanceYards,
           abs(secondDist - target) / target < 0.05 {
            suggestedAlternateClub = second.clubName
        } else {
            suggestedAlternateClub = nil
        }
    }

    private func updateDispersionTier() {
        guard let bag = bag else { dispersionTier = .tier1Formula; return }
        if bag.hasAllDispersions { dispersionTier = .tier3ClubDispersions }
        else if bag.hasAllDistances { dispersionTier = .tier2ClubDistances }
        else { dispersionTier = .tier1Formula }
    }

    private func resetShotMarker() {
        guard let teeBox = hole?.teeBox(forColor: selectedTeeColor) else { return }
        shotCoordinate = teeBox.coordinate.clLocation
        recalculate()
    }
}

extension DispersionTier: Comparable {
    static func < (lhs: DispersionTier, rhs: DispersionTier) -> Bool {
        let order: [DispersionTier] = [.tier1Formula, .tier2ClubDistances, .tier3ClubDispersions]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}
