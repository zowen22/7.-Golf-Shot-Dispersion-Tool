import Foundation
import Combine
import Network

protocol NetworkServiceProtocol {
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }
    func searchCourses(query: String) async throws -> [CourseSearchResult]
    func nearbyCourses(latitude: Double, longitude: Double) async throws -> [CourseSearchResult]
    func fetchCourseDetail(id: String) async throws -> Course
    func fetchHole(courseId: String, holeNumber: Int) async throws -> Hole
}

final class NetworkService: NetworkServiceProtocol {
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "network.monitor")
    private let isConnectedSubject = CurrentValueSubject<Bool, Never>(true)

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnectedSubject.send(path.status == .satisfied)
        }
        monitor.start(queue: monitorQueue)
    }

    func searchCourses(query: String) async throws -> [CourseSearchResult] {
        let url = URL(string: "\(Constants.API.golfbertBaseURL)/courses?search=\(query.urlEncoded)")!
        return try await request(url: url)
    }

    func nearbyCourses(latitude: Double, longitude: Double) async throws -> [CourseSearchResult] {
        let url = URL(string: "\(Constants.API.golfbertBaseURL)/courses?lat=\(latitude)&lng=\(longitude)&radius=\(Constants.Map.nearbyCoursesRadius)")!
        return try await request(url: url)
    }

    func fetchCourseDetail(id: String) async throws -> Course {
        let url = URL(string: "\(Constants.API.golfbertBaseURL)/courses/\(id)")!
        return try await request(url: url)
    }

    func fetchHole(courseId: String, holeNumber: Int) async throws -> Hole {
        let url = URL(string: "\(Constants.API.golfbertBaseURL)/courses/\(courseId)/holes/\(holeNumber)")!
        return try await request(url: url)
    }

    // MARK: - Generic request with retry

    private func request<T: Decodable>(url: URL, retryCount: Int = 1) async throws -> T {
        var lastError: Error = NetworkError.unknown
        for attempt in 0...retryCount {
            do {
                var req = URLRequest(url: url)
                req.setValue("Bearer \(Constants.API.golfbertAPIKey)", forHTTPHeaderField: "Authorization")
                req.timeoutInterval = 15
                let (data, response) = try await URLSession.shared.data(for: req)
                guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                    throw NetworkError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)
                }
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                lastError = error
                if attempt < retryCount {
                    try await Task.sleep(nanoseconds: 1_000_000_000)  // 1s before retry
                }
            }
        }
        throw lastError
    }
}

enum NetworkError: LocalizedError {
    case httpError(Int)
    case decodingFailed
    case offline
    case unknown

    var errorDescription: String? {
        switch self {
        case .httpError(let code): return "Server error \(code). Please try again."
        case .decodingFailed: return "Unexpected response from server."
        case .offline: return "No internet connection."
        case .unknown: return "Something went wrong. Please try again."
        }
    }
}

private extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
