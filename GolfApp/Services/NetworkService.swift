import Foundation
import Combine
import Network
import CoreLocation

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
    private let signer = GolfbertSigner(
        apiKey:    Constants.API.golfbertAPIKey,
        secretKey: Constants.API.golfbertSecretKey
    )

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnectedSubject.send(path.status == .satisfied)
        }
        monitor.start(queue: monitorQueue)
    }

    // MARK: - Course search

    func searchCourses(query: String) async throws -> [CourseSearchResult] {
        let url = URL(string: "\(Constants.API.golfbertBaseURL)/courses?name=\(query.urlEncoded)&limit=20")!
        let response: GolfbertListResponse<GolfbertCourse> = try await request(url: url)
        return response.resources.map { $0.toSearchResult() }
    }

    func nearbyCourses(latitude: Double, longitude: Double) async throws -> [CourseSearchResult] {
        let url = URL(string: "\(Constants.API.golfbertBaseURL)/courses?lat=\(latitude)&long=\(longitude)&limit=\(Constants.Map.maxNearbyResults)")!
        let response: GolfbertListResponse<GolfbertCourse> = try await request(url: url)
        let userLoc = CLLocation(latitude: latitude, longitude: longitude)
        return response.resources.map { $0.toSearchResult(userLocation: userLoc) }
    }

    // MARK: - Course detail (2 parallel calls: detail + teeboxes)

    func fetchCourseDetail(id: String) async throws -> Course {
        guard let courseId = Int(id) else { throw NetworkError.invalidId }
        async let courseTask: GolfbertCourse = request(
            url: URL(string: "\(Constants.API.golfbertBaseURL)/courses/\(courseId)")!
        )
        async let teeboxesTask: GolfbertListResponse<GolfbertCourseTeebox> = request(
            url: URL(string: "\(Constants.API.golfbertBaseURL)/courses/\(courseId)/teeboxes")!
        )
        let (course, teeboxes) = try await (courseTask, teeboxesTask)
        return course.toCourse(teeboxes: teeboxes.resources)
    }

    // MARK: - Hole data (3 calls: course holes list → teeboxes + polygons in parallel)

    func fetchHole(courseId: String, holeNumber: Int) async throws -> Hole {
        guard let courseIdInt = Int(courseId) else { throw NetworkError.invalidId }

        let holesURL = URL(string: "\(Constants.API.golfbertBaseURL)/courses/\(courseIdInt)/holes")!
        let holesResponse: GolfbertListResponse<GolfbertHole> = try await request(url: holesURL)
        guard let holeData = holesResponse.resources.first(where: { $0.number == holeNumber }) else {
            throw NetworkError.holeNotFound
        }

        let holeId = holeData.id
        async let teeboxesTask: GolfbertListResponse<GolfbertHoleTeebox> = request(
            url: URL(string: "\(Constants.API.golfbertBaseURL)/holes/\(holeId)/teeboxes")!
        )
        async let polygonsTask: GolfbertListResponse<GolfbertHolePolygon> = request(
            url: URL(string: "\(Constants.API.golfbertBaseURL)/holes/\(holeId)/polygons")!
        )
        let (teeboxes, polygons) = try await (teeboxesTask, polygonsTask)
        return holeData.toHole(teeboxes: teeboxes.resources, polygons: polygons.resources)
    }

    // MARK: - Generic request with one retry

    private func request<T: Decodable>(url: URL, retryCount: Int = 1) async throws -> T {
        var lastError: Error = NetworkError.unknown
        for attempt in 0...retryCount {
            do {
                var req = URLRequest(url: url)
                req.timeoutInterval = 15
                signer.sign(&req)
                let (data, response) = try await URLSession.shared.data(for: req)
                guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                    throw NetworkError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)
                }
                return try Self.decoder.decode(T.self, from: data)
            } catch {
                lastError = error
                if attempt < retryCount {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                }
            }
        }
        throw lastError
    }

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()
}

// MARK: - Error types

enum NetworkError: LocalizedError {
    case httpError(Int)
    case decodingFailed
    case offline
    case invalidId
    case holeNotFound
    case unknown

    var errorDescription: String? {
        switch self {
        case .httpError(let code): return "Server error \(code). Please try again."
        case .decodingFailed:      return "Unexpected response from server."
        case .offline:             return "No internet connection."
        case .invalidId:           return "Invalid course or hole identifier."
        case .holeNotFound:        return "Hole not found for this course."
        case .unknown:             return "Something went wrong. Please try again."
        }
    }
}

private extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
