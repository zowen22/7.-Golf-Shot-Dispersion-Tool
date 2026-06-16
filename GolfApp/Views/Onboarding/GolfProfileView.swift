import SwiftUI

struct GolfProfileView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Tell us about your game")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top, 48)

                // Average score
                VStack(alignment: .leading, spacing: 8) {
                    Label("Average 18-hole score", systemImage: "pencil.line")
                        .font(.subheadline.weight(.medium))
                    Stepper("\(vm.averageScore)", value: $vm.averageScore, in: 60...150)
                        .font(.title2.bold())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Driving distance
                VStack(alignment: .leading, spacing: 8) {
                    Label("Average driving distance (yards)", systemImage: "arrow.right.to.line")
                        .font(.subheadline.weight(.medium))
                    Stepper("\(vm.drivingDistance) yds", value: $vm.drivingDistance, in: 100...350, step: 5)
                        .font(.title2.bold())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Frequency
                VStack(alignment: .leading, spacing: 8) {
                    Label("How often do you play?", systemImage: "calendar")
                        .font(.subheadline.weight(.medium))
                    Picker("Frequency", selection: $vm.playFrequency) {
                        Text("Weekly+").tag(GolfProfile.PlayFrequency.oncePlusPerWeek)
                        Text("Weekly").tag(GolfProfile.PlayFrequency.oncePerWeek)
                        Text("Twice/mo").tag(GolfProfile.PlayFrequency.twicePerMonth)
                        Text("Monthly").tag(GolfProfile.PlayFrequency.oncePerMonth)
                        Text("Few/year").tag(GolfProfile.PlayFrequency.fewTimesPerYear)
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Mental game
                VStack(alignment: .leading, spacing: 8) {
                    Label("Mental game rating: \(vm.mentalGameRating)/10", systemImage: "brain.head.profile")
                        .font(.subheadline.weight(.medium))
                    Slider(value: Binding(
                        get: { Double(vm.mentalGameRating) },
                        set: { vm.mentalGameRating = Int($0) }
                    ), in: 1...10, step: 1)
                    .tint(.green)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Handedness
                VStack(alignment: .leading, spacing: 8) {
                    Label("Play", systemImage: "hand.raised")
                        .font(.subheadline.weight(.medium))
                    Picker("Handedness", selection: $vm.handedness) {
                        Text("Right-handed").tag(User.Handedness.right)
                        Text("Left-handed").tag(User.Handedness.left)
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Button("Continue") { vm.advance() }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .font(.headline)
                    .padding(.top, 8)
            }
            .padding(28)
        }
    }
}
