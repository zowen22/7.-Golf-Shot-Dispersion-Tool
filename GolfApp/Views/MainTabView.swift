import SwiftUI

struct MainTabView: View {
    let user: User
    let appState: AppState

    var body: some View {
        TabView {
            HomeView(user: user, appState: appState)
                .tabItem { Label("Home", systemImage: "house.fill") }

            CourseSearchView(mode: .round, appState: appState)
                .tabItem { Label("Round", systemImage: "flag.fill") }

            BagManagementView(userId: user.id, appState: appState)
                .tabItem { Label("Bag", systemImage: "bag.fill") }

            ProfileView(user: user, appState: appState)
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .accentColor(.green)
    }
}
