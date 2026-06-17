import SwiftUI
import AuthenticationServices

struct SignInView: View {
    let appState: AppState
    @StateObject private var viewModel: AuthViewModel

    init(appState: AppState) {
        self.appState = appState
        _viewModel = StateObject(wrappedValue: AuthViewModel(appState: appState))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 60)

                VStack(spacing: 8) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    Text("GolfIQ")
                        .font(.largeTitle.bold())
                    Text("Better decisions. Lower scores.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 32)

                VStack(spacing: 12) {
                    // Native Apple Sign In button — handles ASAuthorizationController internally
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = viewModel.prepareAppleSignIn()
                    } onCompletion: { result in
                        viewModel.handleAppleSignIn(result: result)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)

                    // Google Sign In — needs a UIViewController as presentation context
                    GoogleSignInButton(viewModel: viewModel)
                        .frame(height: 50)
                }

                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.secondary.opacity(0.3))
                    Text("or").foregroundColor(.secondary).font(.caption)
                    Rectangle().frame(height: 1).foregroundColor(.secondary.opacity(0.3))
                }

                VStack(spacing: 12) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)

                    Button {
                        viewModel.signInWithEmail()
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Sign In")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(!viewModel.canSignIn || viewModel.isLoading)

                    NavigationLink("Forgot password?", destination: ForgotPasswordView(appState: appState))
                        .font(.caption)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 24)

                NavigationLink(destination: SignUpView(appState: appState)) {
                    HStack(spacing: 4) {
                        Text("Don't have an account?").foregroundColor(.secondary)
                        Text("Sign Up").foregroundColor(.green).fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
            }
            .padding(.horizontal, 28)
        }
        .navigationBarHidden(true)
    }
}

/// Wraps GIDSignIn in a UIViewRepresentable to get a UIViewController presentation context.
/// Requires GoogleSignIn SPM package — compiles once package is added.
private struct GoogleSignInButton: UIViewRepresentable {
    let viewModel: AuthViewModel

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Sign in with Google", for: .normal)
        button.setImage(UIImage(systemName: "globe"), for: .normal)
        button.tintColor = .label
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.layer.cornerRadius = 8
        button.addTarget(context.coordinator, action: #selector(Coordinator.tapped), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(viewModel: viewModel) }

    class Coordinator: NSObject {
        let viewModel: AuthViewModel
        init(viewModel: AuthViewModel) { self.viewModel = viewModel }

        @objc func tapped(_ sender: UIButton) {
            guard let vc = sender.window?.rootViewController else { return }
            viewModel.signInWithGoogle(presentingVC: vc)
        }
    }
}
