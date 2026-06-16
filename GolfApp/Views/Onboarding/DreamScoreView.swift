import SwiftUI

/// Custom scrolling bell curve score picker.
/// This is the most complex onboarding component — budget extra time when wiring in Xcode.
struct DreamScoreView: View {
    @ObservedObject var vm: OnboardingViewModel
    private let scoreRange = Array(60...120)

    var percentileText: String {
        let hdcp = HandicapCalculator.handicap(fromAverageScore: vm.dreamScore)
        switch hdcp {
        case ..<2:  return "Top 2% of all golfers"
        case ..<5:  return "Top 5% of all golfers"
        case ..<10: return "Top 15% of all golfers"
        case ..<15: return "Top 30% of all golfers"
        case ..<20: return "Top 50% of all golfers"
        default:    return "Better than most golfers"
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("What's your dream score?")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 48)

            Text("Score \(vm.dreamScore)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.green)

            Text(percentileText)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Bell curve visual (placeholder — real implementation is a custom Shape)
            BellCurveShape()
                .stroke(Color.green, lineWidth: 2)
                .frame(height: 80)
                .padding(.horizontal, 40)

            // Score picker
            Picker("Dream Score", selection: $vm.dreamScore) {
                ForEach(scoreRange, id: \.self) { score in
                    Text("\(score)").tag(score)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)

            Spacer()

            Button("That's my goal") { vm.advance() }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .font(.headline)
        }
        .padding(.horizontal, 28)
    }
}

struct BellCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = 100
        for i in 0..<points {
            let x = rect.minX + (rect.width / CGFloat(points)) * CGFloat(i)
            let t = (CGFloat(i) / CGFloat(points) - 0.5) * 6  // -3 to +3 sigma
            let gaussianY = exp(-0.5 * t * t)
            let y = rect.maxY - gaussianY * rect.height
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        return path
    }
}
