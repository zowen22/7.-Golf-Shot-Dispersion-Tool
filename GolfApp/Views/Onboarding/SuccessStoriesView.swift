import SwiftUI

struct SuccessStoriesView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var currentIndex = 0

    private let stories = [
        ("Dropped 4 strokes in 2 rounds just by using the dispersion shape to pick safer landing zones.", "Mike T., 14 hdcp"),
        ("Finally broke 90 after using this for club selection on par 4s. Game changer.", "Sarah K., 18 hdcp"),
        ("The visual approach completely changed how I think about risk on approach shots.", "James R., 7 hdcp"),
        ("I used to aim at the flag every time. Now I aim at the fat part of the green. Scoring went from 98 to 91.", "Dan W., 22 hdcp")
    ]

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Golfers are already scoring lower")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            TabView(selection: $currentIndex) {
                ForEach(Array(stories.enumerated()), id: \.offset) { index, story in
                    storyCard(quote: story.0, attribution: story.1)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 200)

            Spacer()

            Button("Continue") { vm.advance() }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .font(.headline)
        }
        .padding(28)
        .onAppear { autoScroll() }
    }

    private func storyCard(quote: String, attribution: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "quote.opening")
                .foregroundColor(.green)
            Text(quote)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            Text("— \(attribution)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private func autoScroll() {
        Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
            withAnimation { currentIndex = (currentIndex + 1) % stories.count }
        }
    }
}
