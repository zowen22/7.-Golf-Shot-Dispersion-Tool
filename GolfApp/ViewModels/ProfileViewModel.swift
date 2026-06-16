import Foundation
import SwiftUI
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var profile: GolfProfile?
    @Published var isSaving = false
    @Published var saveError: String?
    @Published var referralCopied = false

    private let firestoreService: FirestoreServiceProtocol
    private weak var appState: AppState?

    init(appState: AppState, user: User) {
        self.appState = appState
        self.firestoreService = appState.firestoreService
        self.user = user
    }

    func load() {
        Task {
            profile = try? await firestoreService.fetchProfile(userId: user.id)
        }
    }

    func saveUserChanges() {
        isSaving = true
        Task {
            defer { isSaving = false }
            do {
                try await firestoreService.saveUser(user)
                if var p = profile {
                    p.derivedHandicap = HandicapCalculator.derivedHandicap(
                        averageScore: p.averageScore, drivingDistance: p.drivingDistance)
                    p.defaultDispersionMultiplier = DispersionEngine.handicapMultiplier(for: p.derivedHandicap)
                    try await firestoreService.saveProfile(p)
                    profile = p
                }
            } catch {
                saveError = error.localizedDescription
            }
        }
    }

    func copyReferralCode() {
        UIPasteboard.general.string = user.referralCode
        referralCopied = true
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            referralCopied = false
        }
    }

    func signOut() {
        appState?.signOut()
    }
}
