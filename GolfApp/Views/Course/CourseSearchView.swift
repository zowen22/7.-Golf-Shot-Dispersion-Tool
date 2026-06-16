import SwiftUI

struct CourseSearchView: View {
    let mode: CourseMode
    @EnvironmentObject var appState: AppState
    @StateObject private var vm: CourseSearchViewModel
    @State private var navigateToHoleSelector = false

    init(mode: CourseMode) {
        self.mode = mode
        _vm = StateObject(wrappedValue: CourseSearchViewModel(appState: AppState(), mode: mode))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Search courses", text: $vm.searchText)
                        .autocapitalization(.words)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                AsyncContentView(isLoading: vm.isLoading, errorMessage: vm.errorMessage) {
                    vm.onAppear()
                } content: {
                    if vm.results.isEmpty && vm.searchText.isEmpty {
                        emptyStateView
                    } else {
                        resultsList
                    }
                }
            }
            .navigationTitle(mode == .round ? "Start a Round" : "Study Course")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { vm.onAppear() }
            .navigationDestination(item: $vm.selectedCourse) { course in
                TeeSelectionView(course: course, mode: mode)
            }
        }
    }

    private var resultsList: some View {
        List(vm.results) { result in
            Button { vm.selectCourse(result) } label: {
                CourseRowView(result: result)
            }
            .foregroundColor(.primary)
        }
        .listStyle(.plain)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: mode == .round ? "location.slash" : "magnifyingglass")
                .font(.largeTitle).foregroundColor(.secondary)
            Text(mode == .round ? "Looking for nearby courses..." : "Search for a course above")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct CourseRowView: View {
    let result: CourseSearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(result.name).font(.headline)
            HStack {
                Text("\(result.city), \(result.state)").font(.subheadline).foregroundColor(.secondary)
                Spacer()
                if let dist = result.distanceDisplay {
                    Text(dist).font(.caption).foregroundColor(.secondary)
                }
                Text("\(result.numHoles) holes").font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
