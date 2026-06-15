import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: AuthViewModel

    init() {
        _viewModel = StateObject(wrappedValue: AuthViewModel(appState: AppState()))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: 40)

                Text("Create Account")
                    .font(.largeTitle.bold())

                Text("We'll send a verification email before you can sign in.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.newPassword)

                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.newPassword)

                    if !viewModel.password.isEmpty && !viewModel.confirmPassword.isEmpty
                        && viewModel.password != viewModel.confirmPassword {
                        Text("Passwords don't match")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                Button {
                    viewModel.signUpWithEmail()
                } label: {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(!viewModel.canSignUp || viewModel.isLoading)

                if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red).font(.caption).multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 28)
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}
