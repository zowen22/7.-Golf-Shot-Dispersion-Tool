import SwiftUI

struct ForgotPasswordView: View {
    let appState: AppState
    @StateObject private var viewModel: AuthViewModel
    @State private var sent = false

    init(appState: AppState) {
        self.appState = appState
        _viewModel = StateObject(wrappedValue: AuthViewModel(appState: appState))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

                Image(systemName: "envelope.open.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.green)

                Text("Reset Password")
                    .font(.largeTitle.bold())

                Text("Enter your email and we'll send a reset link.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                if sent {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green).font(.title)
                        Text("Check your inbox for a reset link.")
                            .multilineTextAlignment(.center)
                    }
                } else {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)

                    Button {
                        viewModel.sendPasswordReset()
                        sent = true
                    } label: {
                        Text("Send Reset Link")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(viewModel.email.isEmpty)

                    if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red).font(.caption)
                    }
                }
            }
            .padding(.horizontal, 28)
        }
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
    }
}
