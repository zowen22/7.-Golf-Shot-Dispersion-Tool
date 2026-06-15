import Foundation

struct Bag: Codable, Identifiable {
    let id: String
    let userId: String
    var clubs: [Club]

    var hasAnyClubs: Bool {
        clubs.contains { !$0.clubType.isPutter }
    }

    var hasAllDistances: Bool {
        let playableClubs = clubs.filter { !$0.clubType.isPutter }
        return !playableClubs.isEmpty && playableClubs.allSatisfy(\.hasDistance)
    }

    var hasAllDispersions: Bool {
        let playableClubs = clubs.filter { !$0.clubType.isPutter }
        return !playableClubs.isEmpty && playableClubs.allSatisfy(\.hasDispersion)
    }

    var sortedClubs: [Club] {
        clubs.sorted { $0.sortOrder < $1.sortOrder }
    }
}

extension Club.ClubType {
    var isPutter: Bool { self == .putter }
}
