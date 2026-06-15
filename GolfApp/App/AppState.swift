import SwiftUI
import Combine

enum AuthState {
    case unauthenticated
    case authenticated(User)
    case onboarding(User)
}

final class AppState: ObservableObject {
    @Published var authState: AuthState = .unauthenticated
    @Published var isOffline: Bool = false

    // Injected services — set these before use (done at app launch)
    var authService: AuthServiceProtocol = AuthService()
    var firestoreService: FirestoreServiceProtocol = FirestoreService()
    var networkService: NetworkServiceProtocol = NetworkService()
    var locationService: LocationServiceProtocol = LocationService()

    private var cancellables = Set<AnyCancellable>()

    init() {
        startNetworkMonitoring()
        // Auth listener wired here after Firebase SDK is available in Xcode
        // authService.addAuthStateListener { [weak self] user in
        //     Task { await self?.handleAuthStateChange(user) }
        // }
    }

    @MainActor
    func handleAuthStateChange(_ firebaseUser: Any?) async {
        guard let uid = (firebaseUser as? (any Identifiable)) else {
            authState = .unauthenticated
            return
        }
        // Check if user has completed onboarding
        if let user = try? await firestoreService.fetchUser(uid: "\(uid.id)") {
            authState = user.onboardingComplete ? .authenticated(user) : .onboarding(user)
        } else {
            // New user — create skeleton, route to onboarding
            authState = .unauthenticated
        }
    }

    func signOut() {
        try? authService.signOut()
        authState = .unauthenticated
    }

    private func startNetworkMonitoring() {
        // NWPathMonitor wired in NetworkService; it publishes isConnected
        networkService.isConnectedPublisher
            .receive(on: DispatchQueue.main)
            .map { !$0 }
            .assign(to: &$isOffline)
    }
}
