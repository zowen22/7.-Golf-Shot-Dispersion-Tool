import SwiftUI

struct ClubSuggestionView: View {
    let primaryClub: String
    let alternateClub: String?
    let distanceYards: Double

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bag.fill")
                .foregroundColor(.green)
                .font(.subheadline)

            VStack(alignment: .leading, spacing: 2) {
                Text(primaryClub)
                    .font(.headline)
                    .accessibilityLabel("Suggested club: \(primaryClub)")
                if let alt = alternateClub {
                    Text("or \(alt)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text("\(Int(distanceYards)) yds")
                .font(.subheadline.monospacedDigit())
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}
