import SwiftUI

struct PaywallView: View {
    @ObservedObject var vm: OnboardingViewModel

    // StoreKit 2 product IDs — configure in App Store Connect
    private let weeklyProductID = "com.golfapp.subscription.weekly"
    private let quarterlyProductID = "com.golfapp.subscription.quarterly"

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 40)

                VStack(spacing: 8) {
                    Text("Get full access")
                        .font(.largeTitle.bold())
                    Text("Unlimited courses, all dispersion tiers,\nclub suggestions — everything.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Pricing cards
                VStack(spacing: 12) {
                    // Quarterly — conversion target
                    pricingCard(
                        title: "Quarterly",
                        price: "$25 / quarter",
                        subtext: "$8.33/month · Best value",
                        isHighlighted: true,
                        productID: quarterlyProductID
                    )

                    // Weekly — anchor price
                    pricingCard(
                        title: "Weekly",
                        price: "$15 / week",
                        subtext: "Try it this week",
                        isHighlighted: false,
                        productID: weeklyProductID
                    )
                }

                // Feature list
                VStack(alignment: .leading, spacing: 10) {
                    featureRow("All US courses — unlimited holes")
                    featureRow("Live dispersion on satellite map")
                    featureRow("Club suggestion engine")
                    featureRow("Custom dispersion from your bag data")
                    featureRow("Cancel any time")
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Button("Restore Purchases") { vm.restorePurchases() }
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Subscription auto-renews. Cancel anytime in Settings.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                if vm.isLoading {
                    ProgressView()
                }

                if let error = vm.errorMessage {
                    Text(error).foregroundColor(.red).font(.caption).multilineTextAlignment(.center)
                }
            }
            .padding(28)
        }
    }

    private func pricingCard(title: String, price: String, subtext: String, isHighlighted: Bool, productID: String) -> some View {
        Button { vm.purchase(productID: productID) } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline)
                    Text(price).font(.title2.bold())
                    Text(subtext).font(.caption).foregroundColor(isHighlighted ? .white.opacity(0.8) : .secondary)
                }
                Spacer()
                if isHighlighted {
                    Text("BEST").font(.caption.bold()).padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.white.opacity(0.3)).cornerRadius(8)
                }
            }
            .padding(20)
            .background(isHighlighted ? Color.green : Color(.systemGray6))
            .cornerRadius(16)
            .foregroundColor(isHighlighted ? .white : .primary)
        }
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            Text(text).font(.subheadline)
        }
    }
}
