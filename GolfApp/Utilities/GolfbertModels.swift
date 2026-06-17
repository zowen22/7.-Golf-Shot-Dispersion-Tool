import Foundation

// MARK: - Golfbert API response shapes
// These decode the raw API JSON and convert to our internal domain models.
// Field names here must match exactly what Golfbert returns.
// Verify against a real API response and adjust if needed.
// Our JSONDecoder uses .convertFromSnakeCase so snake_case → camelCase is automatic.

struct GolfbertCourseResponse: Decodable {
    let id: String
    let name: String
    let city: String
    let state: String
    let numHoles: Int
    let tees: [GolfbertTee]

    struct GolfbertTee: Decodable {
        let name: String
        let color: String
        let totalYardage: Int
    }

    func toCourse(cachedAt: Date = Date()) -> Course {
        Course(
            id: id,
            name: name,
            city: city,
            state: state,
            numHoles: numHoles,
            tees: tees.map { Course.Tee(name: $0.name, color: $0.color, totalYardage: $0.totalYardage) },
            cachedAt: cachedAt
        )
    }
}

struct GolfbertCourseSearchResponse: Decodable {
    let id: String
    let name: String
    let city: String
    let state: String
    let numHoles: Int

    func toSearchResult(distanceFromUser: Double? = nil) -> CourseSearchResult {
        CourseSearchResult(
            id: id,
            name: name,
            city: city,
            state: state,
            numHoles: numHoles,
            distanceFromUser: distanceFromUser
        )
    }
}

struct GolfbertHoleResponse: Decodable {
    let id: String
    let courseId: String
    let holeNumber: Int
    let tees: [GolfbertHoleTee]
    let green: GolfbertPoint
    let fairway: GolfbertGeoJSON?
    let hazards: GolfbertGeoJSON?

    struct GolfbertHoleTee: Decodable {
        let color: String
        let yardage: Int
        let lat: Double
        let lng: Double
    }

    struct GolfbertPoint: Decodable {
        let lat: Double
        let lng: Double
    }

    struct GolfbertGeoJSON: Decodable {
        let type: String
        let coordinates: [[Double]]
    }

    func toHole() -> Hole {
        Hole(
            id: id,
            courseId: courseId,
            holeNumber: holeNumber,
            teeBoxes: tees.map {
                Hole.TeeBox(
                    color: $0.color,
                    yardage: $0.yardage,
                    coordinate: Coordinate(latitude: $0.lat, longitude: $0.lng)
                )
            },
            greenCenterCoordinate: Coordinate(latitude: green.lat, longitude: green.lng),
            fairwayGeometry: fairway.map { GeoJSONGeometry(type: $0.type, coordinates: $0.coordinates) },
            hazardsGeometry: hazards.map { GeoJSONGeometry(type: $0.type, coordinates: $0.coordinates) }
        )
    }
}
