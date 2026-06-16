import SwiftUI

/// Interactive demo on Pebble Beach hole 1.
/// Mapbox SDK must be wired in Xcode for the real map. This view provides the surrounding UI scaffold.
struct DispersionDemoView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var hasDragged = false

    var body: some View {
        ZStack {
            // Map placeholder — replace with MapboxMapView after SDK wiring
            Color.black.opacity(0.85).ignoresSafeArea()
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.green.opacity(0.15))
                .overlay(
                    Text("🗺 Mapbox Satellite\n(Pebble Beach Hole 1)")
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                )

            // Demo dispersion ellipse (static for now)
            Ellipse()
                .fill(Color.yellow.opacity(0.35))
                .stroke(Color.yellow, lineWidth: 2)
                .frame(width: 80, height: 180)
                .offset(y: -40)

            // Drag instruction overlay
            if !hasDragged {
                VStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "hand.draw.fill")
                            .font(.largeTitle)
                            .foregroundColor(.yellow)
                        Text("Drag the yellow shape to aim your shot")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(16)
                    .padding(.bottom, 120)
                    .onTapGesture { hasDragged = true }  // simulate drag for onboarding flow
                }
            }

            // CTA after first drag
            if hasDragged {
                VStack {
                    Spacer()
                    Button("I get it, let's go!") { vm.advance() }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .font(.headline)
                        .padding(28)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { _ in hasDragged = true }
        )
    }
}
