import Foundation
import SwiftUI
import StoreKit   // native Apple framework — no SPM needed

enum OnboardingStep: String, CaseIterable {
    case welcome, name, goal, dreamScore, profile, distanceUnit,
         snapshot, demo, successStories, gpsPermission, referral, paywall
}

enum StoreKitProducts {
    static let weekly    = "com.golfapp.subscription.weekly"
    static let quarterly = "com.golfapp.subscription.quarterly"
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

        let saved = UserDefaults.standard.string(forKey: Constants.Onboarding.lastStepKey)
        self.currentStep = saved.flatMap(OnboardingStep.init(rawValue:)) ?? .welcome
    }

    // MARK: - Navigation

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

    // MARK: - Referral

    func applyReferralCode() {
        guard !referralCode.isEmpty else { return }
        isLoading = true
        Task {
            defer { isLoading = false }
            // Firestore lookup: find user with referralCode == self.referralCode
            // For MVP the validation is just "does anyone have this code"
            // try await firestoreService.validateReferralCode(referralCode)
            // Stub — wire when Firestore is live:
            try? await Task.sleep(nanoseconds: 500_000_000)
            referralApplied = true
        }
    }

    // MARK: - StoreKit 2 Purchase

    func purchase(productID: String) {
        isLoading = true
        errorMessage = nil
        Task {
            defer { isLoading = false }
            do {
                let products = try await Product.products(for: [productID])
                guard let product = products.first else {
                    errorMessage = "Product unavailable — check App Store Connect configuration."
                    return
                }
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    let transaction = try checkVerified(verification)
                    await transaction.finish()
                    advance()
                case .userCancelled:
                    break
                case .pending:
                    errorMessage = "Purchase is pending approval (e.g. Ask to Buy). Try again once approved."
                @unknown default:
                    break
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func restorePurchases() {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                try await AppStore.sync()
                for await result in Transaction.currentEntitlements {
                    if case .verified(let transaction) = result {
                        let ids = [StoreKitProducts.weekly, StoreKitProducts.quarterly]
                        if ids.contains(transaction.productID) {
                            advance()
                            return
                        }
                    }
                }
                errorMessage = "No active subscription found."
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw StoreKitError.failedVerification
        case .verified(let value): return value
        }
    }

    // MARK: - Computed

    var derivedHandicap: Double {
        HandicapCalculator.derivedHandicap(averageScore: averageScore, drivingDistance: drivingDistance)
    }

    var scoreGapDisplay: String {
        "You're \(averageScore - dreamScore) strokes from your dream game"
    }

    // MARK: - Completion

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
