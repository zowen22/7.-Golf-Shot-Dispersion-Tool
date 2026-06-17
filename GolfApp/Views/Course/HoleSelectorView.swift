import SwiftUI

struct HoleSelectorView: View {
    let course: Course
    let teeColor: String
    let mode: CourseMode
    let appState: AppState

    @StateObject private var roundVM: ActiveRoundViewModel
    @State private var prefetchedHoles: [Int: Hole] = [:]

    init(course: Course, teeColor: String, mode: CourseMode, appState: AppState) {
        self.course = course
        self.teeColor = teeColor
        self.mode = mode
        self.appState = appState
        _roundVM = StateObject(wrappedValue: ActiveRoundViewModel(firestoreService: appState.firestoreService))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Hole")
                .font(.title2.bold())
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(1...max(1, course.numHoles), id: \.self) { holeNum in
                        NavigationLink(destination: HoleMapView(
                            courseId: course.id,
                            holeNumber: holeNum,
                            teeColor: teeColor,
                            totalHoles: course.numHoles,
                            roundVM: roundVM,
                            appState: appState
                        )) {
                            holeCard(number: holeNum)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            Spacer()
        }
        .navigationTitle(course.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let userId = appState.authState.currentUser?.id ?? ""
            roundVM.start(courseId: course.id, userId: userId, teeColor: teeColor, mode: mode)
            await prefetchAllHoles()
        }
    }

    private func holeCard(number: Int) -> some View {
        VStack(spacing: 6) {
            Text("\(number)")
                .font(.title.bold())
                .foregroundColor(.white)
            if let hole = prefetchedHoles[number],
               let tb = hole.teeBox(forColor: teeColor) {
                Text("\(tb.yardage)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            } else {
                ProgressView().tint(.white).scaleEffect(0.6)
            }
        }
        .frame(width: 70, height: 90)
        .background(Color.green.opacity(0.85))
        .cornerRadius(12)
    }

    // MARK: - Hole prefetch

    private func prefetchAllHoles() async {
        guard course.numHoles > 0 else { return }

        // Step 1: parallel Firestore cache check for all holes
        let cached = await withTaskGroup(of: (Int, Hole?).self) { group in
            for n in 1...course.numHoles {
                group.addTask {
                    let h = try? await appState.firestoreService.fetchHole(courseId: course.id, holeNumber: n)
                    return (n, h)
                }
            }
            var acc: [Int: Hole] = [:]
            for await (n, hole) in group {
                if let h = hole { acc[n] = h }
            }
            return acc
        }
        prefetchedHoles = cached

        // Step 2: batch-fetch uncached holes — 1 API call for hole list + N×2 parallel calls,
        // instead of N×3 calls that individual fetchHole would require.
        let missing = Set(1...course.numHoles).subtracting(cached.keys)
        guard !missing.isEmpty,
              let allFetched = try? await appState.networkService.fetchAllHoles(courseId: course.id)
        else { return }

        for hole in allFetched where missing.contains(hole.holeNumber) {
            prefetchedHoles[hole.holeNumber] = hole
            Task { try? await appState.firestoreService.saveHole(hole, courseId: course.id) }
        }
    }
}
