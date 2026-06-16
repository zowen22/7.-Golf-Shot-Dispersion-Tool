import SwiftUI

struct OfflineBannerView: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "wifi.slash")
                .font(.caption)
            Text("Offline — showing cached data")
                .font(.caption)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.85))
        .clipShape(Capsule())
    }
}
