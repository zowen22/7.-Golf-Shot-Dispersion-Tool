import SwiftUI

struct TeeSelectionView: View {
    let course: Course
    let mode: CourseMode
    let appState: AppState
    @State private var selectedTee: Course.Tee?

    var body: some View {
        VStack(spacing: 0) {
            Text("Select Tees")
                .font(.title2.bold())
                .padding()

            List(course.tees, id: \.name) { tee in
                Button {
                    selectedTee = tee
                } label: {
                    HStack {
                        Circle()
                            .fill(teeColor(for: tee.color))
                            .frame(width: 16, height: 16)
                        Text(tee.name).font(.headline)
                        Spacer()
                        Text("\(tee.totalYardage) yds").foregroundColor(.secondary)
                        if selectedTee?.name == tee.name {
                            Image(systemName: "checkmark").foregroundColor(.green)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .listStyle(.plain)

            if let tee = selectedTee {
                NavigationLink(destination: HoleSelectorView(course: course, teeColor: tee.color, mode: mode, appState: appState)) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(20)
            }
        }
        .navigationTitle(course.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func teeColor(for colorName: String) -> Color {
        switch colorName.lowercased() {
        case "white": return .white
        case "blue", "championship": return .blue
        case "red": return .red
        case "gold", "yellow": return .yellow
        default: return .gray
        }
    }
}
