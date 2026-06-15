import SwiftUI

struct SkewSelectorView: View {
    @Binding var skew: DispersionSkew

    var body: some View {
        HStack(spacing: 0) {
            ForEach(DispersionSkew.allCases, id: \.self) { option in
                Button {
                    skew = option
                } label: {
                    Text(option.displayLabel)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(skew == option ? Color.green : Color(.systemGray5))
                        .foregroundColor(skew == option ? .white : .primary)
                }
                .accessibilityLabel("Skew \(option.rawValue.replacingOccurrences(of: "_", with: " "))")
                if option != DispersionSkew.allCases.last {
                    Divider().frame(height: 36)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray4), lineWidth: 1))
    }
}
