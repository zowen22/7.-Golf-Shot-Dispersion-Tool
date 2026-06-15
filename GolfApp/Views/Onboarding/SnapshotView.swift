import SwiftUI

struct SnapshotView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "chart.bar.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text("Your snapshot")
                .font(.largeTitle.bold())

            VStack(spacing: 16) {
                scoreRow(label: "Current avg", value: "\(vm.averageScore)", color: .secondary)
                scoreRow(label: "Dream score", value: "\(vm.dreamScore)", color: .green)

                Divider()

                let gap = vm.averageScore - vm.dreamScore
                Text("Gap: \(gap) strokes")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
            }
            .padding(24)
            .background(Color(.systemGray6))
            .cornerRadius(16)

            Text("Poor course management accounts for most of that gap — not your swing.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button("Show me how") { vm.advance() }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .font(.headline)
        }
        .padding(28)
    }

    private func scoreRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.title3.bold()).foregroundColor(color)
        }
    }
}
