import SwiftUI

struct AuthFlowView: View {
    let appState: AppState

    var body: some View {
        NavigationStack {
            SignInView(appState: appState)
        }
    }
}
