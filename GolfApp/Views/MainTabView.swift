import SwiftUI

struct MainTabView: View {
    let user: User
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            HomeView(user: user)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            CourseSearchView(mode: .round)
                .tabItem {
                    Label("Round", systemImage: "flag.fill")
                }

            BagManagementView(userId: user.id)
                .tabItem {
                    Label("Bag", systemImage: "bag.fill")
                }

            ProfileView(user: user)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.green)
    }
}
