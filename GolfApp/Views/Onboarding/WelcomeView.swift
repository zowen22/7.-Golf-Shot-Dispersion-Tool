import SwiftUI

struct WelcomeView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Hero
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 72))
                        .foregroundColor(.green)
                    Text("Better decisions.\nLower scores.")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Stop leaving strokes on the course.\nSee where your shots actually go.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                }
                .padding(40)
            }
            .frame(maxHeight: .infinity)

            // CTA
            VStack(spacing: 16) {
                Button("Get Started") { vm.advance() }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .font(.headline)

                HStack(spacing: 4) {
                    Link("Privacy Policy", destination: URL(string: "https://yourdomain.com/privacy")!)
                    Text("·").foregroundColor(.secondary)
                    Link("Terms of Service", destination: URL(string: "https://yourdomain.com/terms")!)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(28)
        }
        .ignoresSafeArea(edges: .top)
    }
}
