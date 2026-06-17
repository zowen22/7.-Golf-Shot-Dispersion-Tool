import SwiftUI

struct HomeView: View {
    let user: User
    let appState: AppState
    @StateObject private var vm: HomeViewModel

    init(user: User, appState: AppState) {
        self.user = user
        self.appState = appState
        _vm = StateObject(wrappedValue: HomeViewModel(appState: appState, user: user))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(vm.greeting)
                        .font(.largeTitle.bold())
                        .padding(.top, 8)

                    VStack(spacing: 12) {
                        NavigationLink(destination: CourseSearchView(mode: .round, appState: appState)) {
                            Label("Start a Round", systemImage: "flag.fill")
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)

                        NavigationLink(destination: CourseSearchView(mode: .study, appState: appState)) {
                            Label("Study a Course", systemImage: "map.fill")
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .font(.headline)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                    }

                    if let snapshot = vm.snapshotText {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Goal").font(.headline)
                            Text(snapshot).font(.body).foregroundColor(.secondary)
                            if let profile = vm.profile {
                                HStack {
                                    statPill(label: "Avg", value: "\(profile.averageScore)")
                                    statPill(label: "Target", value: "\(profile.dreamScore)")
                                    statPill(label: "Hdcp", value: String(format: "%.1f", profile.derivedHandicap))
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    if !vm.recentRounds.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recently Played").font(.headline)
                            ForEach(vm.recentRounds) { round in
                                recentRoundRow(round: round)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
            .onAppear { vm.load() }
        }
    }

    private func statPill(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }

    private func recentRoundRow(round: Round) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(round.courseId).font(.subheadline.weight(.medium))
                Text(round.startedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Text(round.mode == .round ? "Round" : "Study")
                .font(.caption).foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
