import SwiftUI

struct NameEntryView: View {
    @ObservedObject var vm: OnboardingViewModel
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("What should we call you?")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            TextField("Your first name", text: $vm.name)
                .textFieldStyle(.roundedBorder)
                .textContentType(.givenName)
                .autocapitalization(.words)
                .focused($focused)
                .font(.title3)

            Spacer()

            Button("Continue") { vm.advance() }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .font(.headline)
                .disabled(vm.name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(28)
        .onAppear { focused = true }
    }
}
