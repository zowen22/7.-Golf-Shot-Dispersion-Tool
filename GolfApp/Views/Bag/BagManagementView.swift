import SwiftUI

struct BagManagementView: View {
    let userId: String
    @EnvironmentObject var appState: AppState
    @StateObject private var vm: BagViewModel
    @State private var showAddClub = false
    @State private var selectedClub: Club?
    @State private var clubToDelete: Club?
    @State private var showDeleteConfirm = false

    init(userId: String) {
        self.userId = userId
        _vm = StateObject(wrappedValue: BagViewModel(appState: AppState(), userId: userId))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress header
                VStack(spacing: 6) {
                    Text(vm.progressText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(vm.unlockHintText)
                        .font(.caption)
                        .foregroundColor(vm.hasAllDistances ? .green : .secondary)
                        .multilineTextAlignment(.center)

                    // Progress bar
                    let entered = vm.sortedClubs.filter { $0.hasDistance }.count
                    let total = max(vm.sortedClubs.filter { !$0.clubType.isPutter }.count, 1)
                    ProgressView(value: Double(entered), total: Double(total))
                        .tint(.green)
                }
                .padding()
                .background(Color(.systemGray6))

                AsyncContentView(isLoading: vm.isLoading, errorMessage: vm.errorMessage) {
                    vm.loadBag()
                } content: {
                    List {
                        ForEach(vm.sortedClubs) { club in
                            Button { selectedClub = club } label: {
                                ClubRowView(club: club)
                            }
                            .foregroundColor(.primary)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    clubToDelete = club
                                    showDeleteConfirm = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }

                        Button {
                            showAddClub = true
                        } label: {
                            Label("Add Club", systemImage: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Bag")
            .onAppear { vm.loadBag() }
            .sheet(item: $selectedClub) { club in
                ClubDetailView(club: club, vm: vm)
            }
            .sheet(isPresented: $showAddClub) {
                AddClubView(vm: vm)
            }
            .confirmationDialog("Delete \(clubToDelete?.clubName ?? "club")?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    if let club = clubToDelete { vm.deleteClub(id: club.id) }
                }
            }
        }
    }
}

struct ClubRowView: View {
    let club: Club

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(club.clubName).font(.body.weight(.medium))
                if let dist = club.distanceYards {
                    Text("\(Int(dist)) yds").font(.caption).foregroundColor(.secondary)
                } else {
                    Text("Add distance →").font(.caption).foregroundColor(.green)
                }
            }
            Spacer()
            if club.hasDistance {
                Image(systemName: club.hasDispersion ? "checkmark.seal.fill" : "checkmark.circle")
                    .foregroundColor(club.hasDispersion ? .green : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddClubView: View {
    @ObservedObject var vm: BagViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: Club.ClubType = .iron
    @State private var customName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Club Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(Club.ClubType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                Section("Club Name") {
                    TextField("e.g. 5 Iron, GW", text: $customName)
                }
            }
            .navigationTitle("Add Club")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        vm.addClub(type: selectedType, name: customName.isEmpty ? selectedType.rawValue.capitalized : customName)
                        dismiss()
                    }
                    .disabled(customName.isEmpty && selectedType == .iron)
                }
            }
        }
    }
}
