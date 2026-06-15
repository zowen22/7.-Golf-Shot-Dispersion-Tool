import SwiftUI

struct GPSPermissionView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "location.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text("Enable Location")
                .font(.largeTitle.bold())

            VStack(spacing: 16) {
                benefitRow(icon: "mappin.and.ellipse", text: "Auto-detects the nearest golf course when you start a round")
                benefitRow(icon: "arrow.up.arrow.down", text: "Calculates exact distance from tee to pin")
                benefitRow(icon: "lock.fill", text: "Location is never stored or shared")
            }

            Spacer()

            VStack(spacing: 12) {
                Button("Enable Location") {
                    vm.requestGPSPermission()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .font(.headline)

                Button("Not Now") { vm.advance() }
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
        .padding(28)
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 24)
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}
