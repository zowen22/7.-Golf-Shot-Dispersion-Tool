import Foundation
import CoreLocation

struct Hole: Codable, Identifiable {
    let id: String
    let courseId: String
    var holeNumber: Int
    var teeBoxes: [TeeBox]
    var greenCenterCoordinate: Coordinate
    var fairwayGeometry: GeoJSONGeometry?
    var hazardsGeometry: GeoJSONGeometry?   // optional for MVP

    struct TeeBox: Codable {
        var color: String
        var yardage: Int
        var coordinate: Coordinate
    }

    func teeBox(forColor color: String) -> TeeBox? {
        teeBoxes.first { $0.color.lowercased() == color.lowercased() }
    }

    func yardage(forTeeColor color: String) -> Int? {
        teeBox(forColor: color)?.yardage
    }
}

struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double

    var clLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct GeoJSONGeometry: Codable {
    var type: String
    var coordinates: [[Double]]           // simplified; real GeoJSON may be nested
}
