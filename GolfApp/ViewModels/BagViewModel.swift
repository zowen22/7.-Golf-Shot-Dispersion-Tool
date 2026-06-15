import Foundation
import SwiftUI

@MainActor
final class BagViewModel: ObservableObject {
    @Published var bag: Bag?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var onBagChanged: ((Bag) -> Void)?

    private let firestoreService: FirestoreServiceProtocol
    private let userId: String

    init(appState: AppState, userId: String) {
        self.firestoreService = appState.firestoreService
        self.userId = userId
    }

    var sortedClubs: [Club] {
        bag?.sortedClubs ?? []
    }

    var hasAnyClubs: Bool { bag?.hasAnyClubs ?? false }
    var hasAllDistances: Bool { bag?.hasAllDistances ?? false }
    var hasAllDispersions: Bool { bag?.hasAllDispersions ?? false }

    var progressText: String {
        let entered = sortedClubs.filter { $0.hasDistance }.count
        let total = sortedClubs.filter { !$0.clubType.isPutter }.count
        return "\(entered) of \(total) clubs with distances"
    }

    var unlockHintText: String {
        if hasAllDispersions { return "Custom dispersion active" }
        if hasAllDistances { return "Club suggestions active — add dispersion widths for custom shape" }
        if hasAnyClubs { return "Add distances to all clubs to unlock club suggestions" }
        return "Add your clubs to get personalized dispersion"
    }

    func loadBag() {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                var loaded = try await firestoreService.fetchBag(userId: userId)
                if loaded.clubs.isEmpty {
                    loaded.clubs = Club.defaultClubs(bagId: loaded.id)
                    try await firestoreService.saveBag(loaded)
                }
                bag = loaded
            } catch {
                // Create new bag for first-time user
                let newBag = Bag(id: UUID().uuidString, userId: userId, clubs: Club.defaultClubs(bagId: UUID().uuidString))
                try? await firestoreService.saveBag(newBag)
                bag = newBag
            }
        }
    }

    func updateClub(_ club: Club) {
        guard var currentBag = bag else { return }
        if let idx = currentBag.clubs.firstIndex(where: { $0.id == club.id }) {
            currentBag.clubs[idx] = club
        }
        // Re-sort by distance (nulls last)
        currentBag.clubs.sort {
            switch ($0.distanceYards, $1.distanceYards) {
            case (.some(let a), .some(let b)): return a > b
            case (.some, .none): return true
            case (.none, .some): return false
            case (.none, .none): return $0.sortOrder < $1.sortOrder
            }
        }
        bag = currentBag
        saveBag(currentBag)
    }

    func deleteClub(id: String) {
        guard var currentBag = bag else { return }
        currentBag.clubs.removeAll { $0.id == id }
        bag = currentBag
        saveBag(currentBag)
    }

    func addClub(type: Club.ClubType, name: String) {
        guard var currentBag = bag else { return }
        let newClub = Club(
            id: UUID().uuidString, bagId: currentBag.id,
            clubType: type, clubName: name,
            distanceYards: nil, dispersionWidth: nil,
            sortOrder: currentBag.clubs.count
        )
        currentBag.clubs.append(newClub)
        bag = currentBag
        saveBag(currentBag)
    }

    private func saveBag(_ bagToSave: Bag) {
        Task {
            do {
                try await firestoreService.saveBag(bagToSave)
                if let updated = bag {
                    onBagChanged?(updated)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
