import SwiftUI

struct ReferralCodeView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "gift.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text("Got a referral code?")
                .font(.largeTitle.bold())

            VStack(spacing: 12) {
                TextField("Enter code", text: $vm.referralCode)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.allCharacters)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)

                if let error = vm.referralError {
                    Text(error).foregroundColor(.red).font(.caption)
                }

                if vm.referralApplied {
                    Label("Code applied!", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }

                Button(vm.isLoading ? "Applying..." : "Apply Code") {
                    vm.applyReferralCode()
                }
                .buttonStyle(.bordered)
                .tint(.green)
                .disabled(vm.referralCode.isEmpty || vm.isLoading)
            }

            Spacer()

            VStack(spacing: 12) {
                Button("Continue") { vm.advance() }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .font(.headline)

                Button("Skip") { vm.advance() }
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
        .padding(28)
    }
}
