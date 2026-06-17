import SwiftUI

struct OnboardingContainerView: View {
    let appState: AppState
    @StateObject private var viewModel: OnboardingViewModel

    init(userId: String, appState: AppState) {
        self.appState = appState
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(appState: appState, userId: userId))
    }

    var body: some View {
        Group {
            switch viewModel.currentStep {
            case .welcome:        WelcomeView(vm: viewModel)
            case .name:           NameEntryView(vm: viewModel)
            case .goal:           GoalSelectionView(vm: viewModel)
            case .dreamScore:     DreamScoreView(vm: viewModel)
            case .profile:        GolfProfileView(vm: viewModel)
            case .distanceUnit:   DistanceUnitView(vm: viewModel)
            case .snapshot:       SnapshotView(vm: viewModel)
            case .demo:           DispersionDemoView(vm: viewModel)
            case .successStories: SuccessStoriesView(vm: viewModel)
            case .gpsPermission:  GPSPermissionView(vm: viewModel)
            case .referral:       ReferralCodeView(vm: viewModel)
            case .paywall:        PaywallView(vm: viewModel)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.currentStep)
    }
}
