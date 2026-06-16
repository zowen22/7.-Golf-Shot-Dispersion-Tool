import SwiftUI

/// Generic three-state wrapper: loading → content | error
struct AsyncContentView<Content: View>: View {
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: (() -> Void)?
    @ViewBuilder let content: () -> Content

    var body: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = errorMessage {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text(error)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                if let retry = onRetry {
                    Button("Try Again", action: retry)
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            content()
        }
    }
}
