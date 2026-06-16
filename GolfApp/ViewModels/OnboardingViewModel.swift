import Foundation
import SwiftUI
import CoreLocation

enum OnboardingStep: String, CaseIterable {
    case welcome, name, goal, dreamScore, profile, distanceUnit,
         snapshot, demo, successStories, gpsPermission, referral, paywall
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep
    @Published var name = ""
    @Published var goal: GolfProfile.Goal = .lowerHandicap
    @Published var dreamScore = 85
    @Published var averageScore = 90
    @Published var drivingDistance = 220
    @Published var playFrequency: GolfProfile.PlayFrequency = .oncePerWeek
    @Published var mentalGameRating = 5
    @Published var roadblock: GolfProfile.Roadblock = .courseManagement
    @Published var handedness: User.Handedness = .right
    @Published var distanceUnit: User.DistanceUnit = .yards
    @Published var referralCode = ""
    @Published var referralError: String?
    @Published var referralApplied = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firestoreService: FirestoreServiceProtocol
    private let locationService: LocationServiceProtocol
    private weak var appState: AppState?
    private let userId: String

    init(appState: AppState, userId: String) {
        self.appState = appState
        self.firestoreService = appState.firestoreService
        self.locationService = appState.locationService
        self.userId = userId

        // Resume from last completed step
        let saved = UserDefaults.standard.string(forKey: Constants.Onboarding.lastStepKey)
        self.currentStep = saved.flatMap(OnboardingStep.init(rawValue:)) ?? .welcome
    }

    func advance() {
        let all = OnboardingStep.allCases
        guard let idx = all.firstIndex(of: currentStep), idx + 1 < all.count else {
            completeOnboarding()
            return
        }
        currentStep = all[idx + 1]
        UserDefaults.standard.set(currentStep.rawValue, forKey: Constants.Onboarding.lastStepKey)
    }

    func requestGPSPermission() {
        locationService.requestPermission()
        advance()
    }

    func applyReferralCode() {
        guard !referralCode.isEmpty else { return }
        isLoading = true
        Task {
            defer { isLoading = false }
            // Validate referral code against Firestore users collection
            // For MVP: look for user with matching referralCode field
            // try await firestoreService.validateReferralCode(referralCode)
            referralApplied = true  // stub — wire Firestore validation
        }
    }

    func purchase(productID: String) {
        isLoading = true
        Task {
            defer { isLoading = false }
            // StoreKit 2: Product.products(for: [productID]) → purchase
            // On success: advance()
        }
    }

    func restorePurchases() {
        // StoreKit 2: AppStore.sync()
    }

    var derivedHandicap: Double {
        HandicapCalculator.derivedHandicap(averageScore: averageScore, drivingDistance: drivingDistance)
    }

    var scoreGapDisplay: String {
        let gap = averageScore - dreamScore
        return "You're \(gap) strokes from your dream game"
    }

    private func completeOnboarding() {
        Task {
            await writeProfileToFirestore()
            UserDefaults.standard.set(true, forKey: Constants.Onboarding.completeKey)
            UserDefaults.standard.removeObject(forKey: Constants.Onboarding.lastStepKey)
            UserDefaults.standard.set(distanceUnit.rawValue, forKey: Constants.Onboarding.distanceUnitKey)

            if case .onboarding(var user) = appState?.authState {
                user.name = name
                user.handedness = handedness
                user.distanceUnit = distanceUnit
                user.onboardingComplete = true
                try? await firestoreService.saveUser(user)
                appState?.authState = .authenticated(user)
            }
        }
    }

    private func writeProfileToFirestore() async {
        let handicap = derivedHandicap
        let profile = GolfProfile(
            id: UUID().uuidString, userId: userId,
            averageScore: averageScore, drivingDistance: drivingDistance,
            derivedHandicap: handicap, dreamScore: dreamScore, goal: goal,
            mentalGameRating: mentalGameRating, biggestRoadblock: roadblock,
            howOftenPlays: playFrequency, doneCourseManagement: false,
            defaultDispersionMultiplier: DispersionEngine.handicapMultiplier(for: handicap)
        )
        try? await firestoreService.saveProfile(profile)
    }
}
