import Foundation
import CoreLocation
import Combine

protocol LocationServiceProtocol {
    var currentLocation: CLLocationCoordinate2D? { get }
    var locationPublisher: AnyPublisher<CLLocationCoordinate2D, Never> { get }
    func requestPermission()
}

final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let locationSubject = PassthroughSubject<CLLocationCoordinate2D, Never>()

    var currentLocation: CLLocationCoordinate2D? { manager.location?.coordinate }

    var locationPublisher: AnyPublisher<CLLocationCoordinate2D, Never> {
        locationSubject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            // App continues without GPS — course search falls back to manual
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.last?.coordinate else { return }
        locationSubject.send(coord)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            // No GPS available — CourseSearchViewModel will show manual search UI
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
