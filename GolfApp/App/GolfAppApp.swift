import SwiftUI
// import Firebase  ← uncomment after adding Firebase iOS SDK via SPM in Xcode

@main
struct GolfAppApp: App {
    @StateObject private var appState = AppState()

    init() {
        // FirebaseApp.configure()  ← uncomment after adding Firebase iOS SDK via SPM in Xcode
        // Must be called before any Firebase service is used.
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
