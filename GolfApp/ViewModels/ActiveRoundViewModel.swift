import Foundation

@MainActor
final class ActiveRoundViewModel: ObservableObject {
    @Published var round: Round?

    private let firestoreService: FirestoreServiceProtocol

    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }

    func start(courseId: String, userId: String, teeColor: String, mode: CourseMode) {
        guard round == nil else { return }
        let roundMode: Round.RoundMode = (mode == .round) ? .round : .study
        let r = Round(
            id: UUID().uuidString,
            userId: userId,
            courseId: courseId,
            teeColor: teeColor,
            startedAt: Date(),
            completedAt: nil,
            mode: roundMode,
            holesPlayed: []
        )
        round = r
        Task { try? await firestoreService.saveRound(r) }
    }

    func markHolePlayed(_ holeNumber: Int) {
        guard var r = round, !r.holesPlayed.contains(holeNumber) else { return }
        r.holesPlayed.append(holeNumber)
        round = r
        Task { try? await firestoreService.saveRound(r) }
    }
}
