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
        manager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.last?.coordinate else { return }
        locationSubject.send(coord)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
}
