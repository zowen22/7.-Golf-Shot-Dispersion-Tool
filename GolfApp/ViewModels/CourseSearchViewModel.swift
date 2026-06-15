import Foundation
import SwiftUI
import Combine
import CoreLocation

enum CourseMode {
    case round   // GPS nearby + manual search; sequential holes
    case study   // manual search primary; free navigation
}

@MainActor
final class CourseSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [CourseSearchResult] = []
    @Published var selectedCourse: Course?
    @Published var selectedTeeColor: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let mode: CourseMode

    private let networkService: NetworkServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(appState: AppState, mode: CourseMode) {
        self.networkService = appState.networkService
        self.firestoreService = appState.firestoreService
        self.locationService = appState.locationService
        self.mode = mode

        setupSearchDebounce()
    }

    func onAppear() {
        if mode == .round {
            fetchNearby()
        }
    }

    func selectCourse(_ result: CourseSearchResult) {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                if let cached = try? await firestoreService.fetchCourse(id: result.id),
                   Calendar.current.dateComponents([.day], from: cached.cachedAt, to: Date()).day ?? 0 < Constants.API.golfbertCacheExpiryDays {
                    selectedCourse = cached
                } else {
                    let fetched = try await networkService.fetchCourseDetail(id: result.id)
                    selectedCourse = fetched
                    try? await firestoreService.saveCourse(fetched)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func fetchNearby() {
        guard let loc = locationService.currentLocation else { return }
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                results = try await networkService.nearbyCourses(latitude: loc.latitude, longitude: loc.longitude)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .seconds(Constants.Map.searchDebounceSeconds), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] query in
                self?.search(query: query)
            }
            .store(in: &cancellables)
    }

    private func search(query: String) {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                results = try await networkService.searchCourses(query: query)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
