import SwiftUI

struct DistanceUnitView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("Distance units")
                .font(.largeTitle.bold())

            HStack(spacing: 16) {
                unitCard(unit: .yards, label: "Yards", subtitle: "Used in US, UK")
                unitCard(unit: .meters, label: "Meters", subtitle: "International")
            }

            Spacer()
        }
        .padding(28)
    }

    @ViewBuilder
    private func unitCard(unit: User.DistanceUnit, label: String, subtitle: String) -> some View {
        Button {
            vm.distanceUnit = unit
            vm.advance()
        } label: {
            VStack(spacing: 12) {
                Text(unit == .yards ? "yds" : "m")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(vm.distanceUnit == unit ? .white : .green)
                Text(label).font(.headline)
                Text(subtitle).font(.caption).foregroundColor(vm.distanceUnit == unit ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(vm.distanceUnit == unit ? Color.green : Color(.systemGray6))
            .cornerRadius(16)
        }
        .foregroundColor(vm.distanceUnit == unit ? .white : .primary)
    }
}
