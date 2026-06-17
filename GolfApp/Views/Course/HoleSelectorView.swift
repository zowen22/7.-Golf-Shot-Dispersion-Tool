import SwiftUI

struct HoleSelectorView: View {
    let course: Course
    let teeColor: String
    let mode: CourseMode
    let appState: AppState
    @State private var prefetchedHoles: [Int: Hole] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Hole")
                .font(.title2.bold())
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(1...course.numHoles, id: \.self) { holeNum in
                        NavigationLink(destination: HoleMapView(
                            courseId: course.id,
                            holeNumber: holeNum,
                            teeColor: teeColor,
                            totalHoles: course.numHoles,
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
        .task { await prefetchAllHoles() }
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

    private func prefetchAllHoles() async {
        await withTaskGroup(of: (Int, Hole?).self) { group in
            for n in 1...course.numHoles {
                group.addTask {
                    let cached = try? await appState.firestoreService.fetchHole(courseId: course.id, holeNumber: n)
                    if let hole = cached { return (n, hole) }
                    let fetched = try? await appState.networkService.fetchHole(courseId: course.id, holeNumber: n)
                    if let hole = fetched {
                        try? await appState.firestoreService.saveHole(hole, courseId: course.id)
                    }
                    return (n, fetched)
                }
            }
            for await (n, hole) in group {
                if let h = hole {
                    await MainActor.run { prefetchedHoles[n] = h }
                }
            }
        }
    }
}
