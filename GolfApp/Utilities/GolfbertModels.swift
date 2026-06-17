import Foundation
import CoreLocation

// MARK: - Shared primitive

struct GolfbertPoint: Decodable {
    let lat: Double
    let long: Double  // API returns "long" not "lng"
}

// MARK: - Address

struct GolfbertAddress: Decodable {
    let city: String?
    let state: String?
    let zip: String?
    let street: String?
    let country: String?
}

// MARK: - Course
// GET /v1/courses/{id}  returns this object directly (no wrapper)
// GET /v1/courses       returns GolfbertListResponse<GolfbertCourse>

struct GolfbertCourse: Decodable {
    let id: Int
    let name: String
    let address: GolfbertAddress?
    let coordinates: GolfbertPoint?

    func toCourse(teeboxes: [GolfbertCourseTeebox] = [], cachedAt: Date = Date()) -> Course {
        Course(
            id: String(id),
            name: name,
            city: address?.city ?? "",
            state: address?.state ?? "",
            numHoles: 18,
            tees: teeboxes.compactMap { tb in
                guard let color = tb.color else { return nil }
                return Course.Tee(name: tb.teeboxType ?? color, color: color, totalYardage: 0)
            },
            cachedAt: cachedAt
        )
    }

    func toSearchResult(userLocation: CLLocation? = nil) -> CourseSearchResult {
        var distance: Double?
        if let userLoc = userLocation, let coords = coordinates {
            distance = userLoc.distance(from: CLLocation(latitude: coords.lat, longitude: coords.long))
        }
        return CourseSearchResult(
            id: String(id),
            name: name,
            city: address?.city ?? "",
            state: address?.state ?? "",
            numHoles: 18,
            distanceFromUser: distance
        )
    }
}

// MARK: - Course teebox
// GET /v1/courses/{id}/teeboxes returns GolfbertListResponse<GolfbertCourseTeebox>

struct GolfbertCourseTeebox: Decodable {
    let color: String?
    let slope: Double?
    let rating: Double?
    let teeboxType: String?

    enum CodingKeys: String, CodingKey {
        case color, slope, rating
        case teeboxType = "teeboxtype"
    }
}

// MARK: - Hole
// GET /v1/holes/{id}          returns this object directly (no wrapper)
// GET /v1/courses/{id}/holes  returns GolfbertListResponse<GolfbertHole>

struct GolfbertHole: Decodable {
    let id: Int
    let number: Int
    let courseId: Int
    let flagCoords: GolfbertPoint?
    let rotation: Double?

    enum CodingKeys: String, CodingKey {
        case id, number, rotation
        case courseId   = "courseid"
        case flagCoords = "flagcoords"
    }

    func toHole(teeboxes: [GolfbertHoleTeebox], polygons: [GolfbertHolePolygon]) -> Hole {
        let green = flagCoords.map { Coordinate(latitude: $0.lat, longitude: $0.long) }
                    ?? Coordinate(latitude: 0, longitude: 0)

        let fairwayPolygon = polygons.first { $0.surfaceType?.lowercased() == "fairway" }

        return Hole(
            id: String(id),
            courseId: String(courseId),
            holeNumber: number,
            teeBoxes: teeboxes.compactMap { tb in
                guard let color = tb.color, let coords = tb.coordinates else { return nil }
                return Hole.TeeBox(
                    color: color,
                    yardage: tb.length ?? 0,
                    coordinate: Coordinate(latitude: coords.lat, longitude: coords.long)
                )
            },
            greenCenterCoordinate: green,
            fairwayGeometry: fairwayPolygon.flatMap { poly -> GeoJSONGeometry? in
                guard let pts = poly.polygon, !pts.isEmpty else { return nil }
                // GeoJSON stores coordinates as [longitude, latitude]
                return GeoJSONGeometry(type: "Polygon", coordinates: pts.map { [$0.long, $0.lat] })
            },
            hazardsGeometry: nil
        )
    }
}

// MARK: - Hole teebox
// GET /v1/holes/{id}/teeboxes returns GolfbertListResponse<GolfbertHoleTeebox>

struct GolfbertHoleTeebox: Decodable {
    let holeId: Int
    let holeNumber: Int?
    let color: String?
    let length: Int?      // yardage
    let par: Int?
    let handicap: Int?
    let coordinates: GolfbertPoint?
    let teeboxType: String?

    enum CodingKeys: String, CodingKey {
        case color, length, par, handicap, coordinates
        case holeId     = "holeid"
        case holeNumber = "holenumber"
        case teeboxType = "teeboxtype"
    }
}

// MARK: - Hole polygon
// GET /v1/holes/{id}/polygons returns GolfbertListResponse<GolfbertHolePolygon>

struct GolfbertHolePolygon: Decodable {
    let holeId: Int
    let surfaceType: String?
    let polygon: [GolfbertPoint]?

    enum CodingKeys: String, CodingKey {
        case polygon
        case holeId     = "holeid"
        case surfaceType = "surfacetype"
    }
}

// MARK: - Envelope wrappers

// All list endpoints return { "resources": [...] }
struct GolfbertListResponse<T: Decodable>: Decodable {
    let resources: [T]
}

// Single-resource endpoints (GET /v1/courses/{id}, GET /v1/holes/{id}) return the object directly.
