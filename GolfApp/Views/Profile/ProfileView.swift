import SwiftUI

struct ProfileView: View {
    let user: User
    let appState: AppState
    @StateObject private var vm: ProfileViewModel

    init(user: User, appState: AppState) {
        self.user = user
        self.appState = appState
        _vm = StateObject(wrappedValue: ProfileViewModel(appState: appState, user: user))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Name", text: $vm.user.name)
                    if var profile = vm.profile {
                        Stepper("Avg Score: \(profile.averageScore)", value: Binding(
                            get: { profile.averageScore },
                            set: { profile.averageScore = $0; vm.profile = profile }
                        ), in: 60...150)
                        Stepper("Dream Score: \(profile.dreamScore)", value: Binding(
                            get: { profile.dreamScore },
                            set: { profile.dreamScore = $0; vm.profile = profile }
                        ), in: 60...120)
                    }
                    Picker("Distance Unit", selection: $vm.user.distanceUnit) {
                        Text("Yards").tag(User.DistanceUnit.yards)
                        Text("Meters").tag(User.DistanceUnit.meters)
                    }
                    Picker("Plays", selection: $vm.user.handedness) {
                        Text("Right-handed").tag(User.Handedness.right)
                        Text("Left-handed").tag(User.Handedness.left)
                    }
                }

                Section("Account") {
                    LabeledContent("Email", value: vm.user.email)
                    if let profile = vm.profile {
                        LabeledContent("Handicap", value: String(format: "%.1f", profile.derivedHandicap))
                    }
                }

                Section {
                    NavigationLink("My Bag") {
                        BagManagementView(userId: vm.user.id, appState: appState)
                    }
                }

                Section("Referral") {
                    HStack {
                        Text(vm.user.referralCode)
                            .font(.system(.body, design: .monospaced))
                        Spacer()
                        Button(vm.referralCopied ? "Copied!" : "Copy") {
                            vm.copyReferralCode()
                        }
                        .foregroundColor(.green)
                    }
                }

                Section("Subscription") {
                    LabeledContent("Status", value: vm.user.subscriptionStatus == .paid ? "Active" : "Free")
                    if vm.user.subscriptionStatus == .paid {
                        Button("Manage in App Store") {
                            // StoreKit 2: open subscription management URL
                        }
                        .foregroundColor(.green)
                    }
                }

                Section {
                    Link("Privacy Policy", destination: URL(string: "https://yourdomain.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://yourdomain.com/terms")!)
                }

                Section {
                    Button("Sign Out", role: .destructive) { vm.signOut() }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { vm.saveUserChanges() }.fontWeight(.semibold)
                }
            }
            .onAppear { vm.load() }
        }
    }
}
