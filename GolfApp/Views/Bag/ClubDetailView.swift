import SwiftUI

struct ClubDetailView: View {
    @State var club: Club
    @ObservedObject var vm: BagViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var distanceText = ""
    @State private var dispersionText = ""
    @State private var showDispersionInfo = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Club") {
                    Text(club.clubName).font(.headline)
                }

                Section("Distance (yards)") {
                    TextField("e.g. 175", text: $distanceText)
                        .keyboardType(.numberPad)

                    if let hdcp = vm.bag?.clubs.first(where: { $0.id == club.id }).map({ _ in 10.0 }) {
                        let width = DispersionEngine.calculateWidth(distanceYards: Double(distanceText) ?? 150, handicap: hdcp)
                        Text("Typical dispersion for your handicap: ±\(Int(width)) yds")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    HStack {
                        TextField("e.g. 12 (optional)", text: $dispersionText)
                            .keyboardType(.numberPad)
                        Button {
                            showDispersionInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Dispersion Width (yards) — Optional")
                } footer: {
                    Text("How far left or right your shots typically spread. Entering this for all clubs unlocks the custom dispersion shape on the map.")
                        .font(.caption)
                }
            }
            .navigationTitle("Edit Club")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                distanceText = club.distanceYards.map { "\(Int($0))" } ?? ""
                dispersionText = club.dispersionWidth.map { "\(Int($0))" } ?? ""
            }
            .alert("What is dispersion?", isPresented: $showDispersionInfo) {
                Button("Got it", role: .cancel) {}
            } message: {
                Text("Dispersion width is how far your shots spread left and right. For example, if your 7-iron typically lands within 10 yards of your target line, enter 10.")
            }
        }
    }

    private func save() {
        var updated = club
        updated.distanceYards = Double(distanceText)
        updated.dispersionWidth = dispersionText.isEmpty ? nil : Double(dispersionText)
        vm.updateClub(updated)
        dismiss()
    }
}
