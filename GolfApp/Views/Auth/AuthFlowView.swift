import SwiftUI

struct AuthFlowView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            SignInView()
        }
    }
}
