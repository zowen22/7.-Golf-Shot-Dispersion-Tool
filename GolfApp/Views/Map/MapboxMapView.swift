import SwiftUI
import CoreLocation

/// UIViewRepresentable wrapper for Mapbox MapView.
/// Requires Mapbox Maps SDK added via SPM in Xcode before this compiles.
/// The coordinator handles gesture delegation and annotation drag.
///
/// Import block (uncomment after adding SPM dependency in Xcode):
/// import MapboxMaps

struct MapboxMapView: UIViewRepresentable {
    @Binding var shotCoordinate: CLLocationCoordinate2D?
    let hole: Hole
    let selectedTeeColor: String
    let dispersionEllipse: [CLLocationCoordinate2D]
    let onShotMoved: (CLLocationCoordinate2D) -> Void

    func makeUIView(context: Context) -> UIView {
        // TODO (Xcode): Replace UIView placeholder with MapView(mapInitOptions:)
        // let options = MapInitOptions(styleURI: .satellite)
        // let mapView = MapView(frame: .zero, mapInitOptions: options)
        // mapView.mapboxMap.setCamera(to: CameraOptions(center: holeCenterCoordinate, zoom: 15))
        // context.coordinator.setup(mapView: mapView)
        // return mapView

        let placeholder = UIView()
        placeholder.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        let label = UILabel()
        label.text = "🗺 Map loads here\n(Mapbox SDK — add via SPM in Xcode)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        placeholder.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: placeholder.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: placeholder.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: placeholder.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: placeholder.trailingAnchor, constant: -20)
        ])
        return placeholder
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // TODO (Xcode): Update dispersion FillLayer source on every ellipse update
        // context.coordinator.updateDispersionEllipse(dispersionEllipse)
        // context.coordinator.moveShotMarker(to: shotCoordinate)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onShotMoved: onShotMoved)
    }

    class Coordinator: NSObject {
        let onShotMoved: (CLLocationCoordinate2D) -> Void

        init(onShotMoved: @escaping (CLLocationCoordinate2D) -> Void) {
            self.onShotMoved = onShotMoved
        }

        // TODO (Xcode): Implement Mapbox gesture delegate methods
        // func setupDragGesture(on mapView: MapView) { ... }
        // func updateDispersionEllipse(_ coords: [CLLocationCoordinate2D]) { ... }
    }

    private var holeCenterCoordinate: CLLocationCoordinate2D {
        hole.greenCenterCoordinate.clLocation
    }
}
