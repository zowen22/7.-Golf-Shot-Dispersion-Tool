import SwiftUI

struct GoalSelectionView: View {
    @ObservedObject var vm: OnboardingViewModel

    private let goals: [(GolfProfile.Goal, String, String)] = [
        (.breakScore, "Break a score", "flag"),
        (.winMoneyMatches, "Win money matches", "dollarsign.circle"),
        (.lowerHandicap, "Lower my handicap", "chart.line.downtrend.xyaxis"),
        (.playMoreConsistently, "Play more consistently", "waveform.path"),
        (.justHaveFun, "Just have more fun", "face.smiling")
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("What's your main goal?")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 48)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(goals, id: \.0) { goal, label, icon in
                        Button {
                            vm.goal = goal
                            vm.advance()
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(.green)
                                    .frame(width: 32)
                                Text(label)
                                    .font(.body.weight(.medium))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .background(vm.goal == goal ? Color.green.opacity(0.1) : Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(vm.goal == goal ? Color.green : Color.clear, lineWidth: 2)
                            )
                        }
                        .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 28)
            }
        }
        .padding(.horizontal, 28)
    }
}
