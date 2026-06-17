import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                switch appState.authState {
                case .unauthenticated:
                    AuthFlowView(appState: appState)
                case .onboarding(let user):
                    OnboardingContainerView(userId: user.id, appState: appState)
                case .authenticated(let user):
                    MainTabView(user: user, appState: appState)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.authState.id)

            if appState.isOffline {
                OfflineBannerView()
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut, value: appState.isOffline)
            }
        }
    }
}

extension AuthState {
    var id: String {
        switch self {
        case .unauthenticated: return "unauth"
        case .onboarding(let u): return "onboarding-\(u.id)"
        case .authenticated(let u): return "auth-\(u.id)"
        }
    }
}
