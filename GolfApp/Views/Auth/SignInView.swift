import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: AuthViewModel

    init() {
        // viewModel requires appState — initialized in body via workaround
        _viewModel = StateObject(wrappedValue: AuthViewModel(appState: AppState()))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 60)

                // Logo / wordmark
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

                // Social sign-in
                VStack(spacing: 12) {
                    // Sign in with Apple — ASAuthorizationAppleIDButton wrapped in UIViewRepresentable
                    AppleSignInButton()
                        .frame(height: 50)
                        .onTapGesture { viewModel.signInWithApple() }

                    Button {
                        viewModel.signInWithGoogle()
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                            Text("Sign in with Google")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .buttonStyle(.bordered)
                }

                // Divider
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.secondary.opacity(0.3))
                    Text("or").foregroundColor(.secondary).font(.caption)
                    Rectangle().frame(height: 1).foregroundColor(.secondary.opacity(0.3))
                }

                // Email sign-in
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
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(!viewModel.canSignIn || viewModel.isLoading)

                    NavigationLink("Forgot password?", destination: ForgotPasswordView())
                        .font(.caption)
                }

                // Error
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 24)

                // Sign up link
                NavigationLink(destination: SignUpView()) {
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
        .overlay {
            if viewModel.isLoading { ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.black.opacity(0.1)) }
        }
    }
}

/// Wraps ASAuthorizationAppleIDButton for SwiftUI.
/// Full delegate implementation goes in AuthService / a coordinator class.
struct AppleSignInButton: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    }
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
}
