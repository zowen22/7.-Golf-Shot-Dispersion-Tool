import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var user: User?
    @Published var profile: GolfProfile?
    @Published var recentRounds: [Round] = []
    @Published var isLoading = false

    private let firestoreService: FirestoreServiceProtocol

    init(appState: AppState, user: User) {
        self.firestoreService = appState.firestoreService
        self.user = user
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = user?.name.split(separator: " ").first.map(String.init) ?? ""
        switch hour {
        case 0..<12:  return "Good morning\(name.isEmpty ? "" : ", \(name)")"
        case 12..<17: return "Good afternoon\(name.isEmpty ? "" : ", \(name)")"
        default:      return "Good evening\(name.isEmpty ? "" : ", \(name)")"
        }
    }

    var snapshotText: String? {
        guard let profile = profile else { return nil }
        let gap = profile.averageScore - profile.dreamScore
        return "You're \(gap) strokes from your goal"
    }

    func load() {
        guard let uid = user?.id else { return }
        isLoading = true
        Task {
            defer { isLoading = false }
            async let profileFetch = firestoreService.fetchProfile(userId: uid)
            async let roundsFetch = firestoreService.fetchRecentRounds(userId: uid, limit: 3)
            profile = try? await profileFetch
            recentRounds = (try? await roundsFetch) ?? []
        }
    }
}
