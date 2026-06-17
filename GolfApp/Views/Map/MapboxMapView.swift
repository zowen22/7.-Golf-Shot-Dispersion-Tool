// Requires Mapbox Maps SDK via SPM: MapboxMaps
// Add package in Xcode → File → Add Package Dependencies
// then uncomment the import below.
//
// import MapboxMaps

import SwiftUI
import CoreLocation

// MARK: - SwiftUI wrapper

struct MapboxMapView: UIViewRepresentable {
    @Binding var shotCoordinate: CLLocationCoordinate2D?
    let hole: Hole
    let selectedTeeColor: String
    let dispersionEllipse: [CLLocationCoordinate2D]
    let onShotMoved: (CLLocationCoordinate2D) -> Void

    func makeUIView(context: Context) -> UIView {
        // ── Uncomment after adding Mapbox SPM package ──────────────────────────
        //
        // let options = MapInitOptions(styleURI: .satellite)
        // let mapView = MapView(frame: .zero, mapInitOptions: options)
        // mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //
        // mapView.mapboxMap.onNext(event: .mapLoaded) { [weak context] _ in
        //     context?.coordinator.setupLayers(on: mapView, hole: self.hole)
        //     context?.coordinator.fitCamera(mapView: mapView, hole: self.hole)
        //     context?.coordinator.placeShotMarker(mapView: mapView,
        //         at: self.hole.teeBox(forColor: self.selectedTeeColor)?.coordinate.clLocation
        //             ?? self.hole.greenCenterCoordinate.clLocation)
        // }
        // context.coordinator.mapView = mapView
        // return mapView
        // ───────────────────────────────────────────────────────────────────────

        return placeholderView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // ── Uncomment after adding Mapbox SPM package ──────────────────────────
        // guard let mapView = context.coordinator.mapView else { return }
        // context.coordinator.updateDispersionEllipse(dispersionEllipse, on: mapView)
        // if let coord = shotCoordinate {
        //     context.coordinator.updateShotMarkerPosition(coord, on: mapView)
        // }
        // ───────────────────────────────────────────────────────────────────────
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onShotMoved: onShotMoved)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject {
        let onShotMoved: (CLLocationCoordinate2D) -> Void
        // var mapView: MapView?   // uncomment with Mapbox import

        // Layer / source IDs — keep as constants so updates don't recreate them
        private let fairwaySourceID    = "fairway-source"
        private let fairwayLayerID     = "fairway-layer"
        private let greenSourceID      = "green-source"
        private let greenLayerID       = "green-layer"
        private let dispersionSourceID = "dispersion-source"
        private let dispersionLayerID  = "dispersion-layer"
        private let markerAnnotationID = "shot-marker"

        init(onShotMoved: @escaping (CLLocationCoordinate2D) -> Void) {
            self.onShotMoved = onShotMoved
        }

        // ── All methods below uncomment after adding Mapbox SPM package ────────

        // func setupLayers(on mapView: MapView, hole: Hole) {
        //     addFairwayLayer(on: mapView, hole: hole)
        //     addGreenLayer(on: mapView, hole: hole)
        //     addDispersionLayer(on: mapView)
        //     addTeeAnnotation(on: mapView, hole: hole)
        //     addGreenAnnotation(on: mapView, hole: hole)
        // }

        // MARK: Camera

        // func fitCamera(mapView: MapView, hole: Hole) {
        //     guard let teeBox = hole.teeBoxes.first else { return }
        //     let tee = teeBox.coordinate.clLocation
        //     let green = hole.greenCenterCoordinate.clLocation
        //     let bounds = CoordinateBounds(
        //         southwest: CLLocationCoordinate2D(
        //             latitude: min(tee.latitude, green.latitude),
        //             longitude: min(tee.longitude, green.longitude)
        //         ),
        //         northeast: CLLocationCoordinate2D(
        //             latitude: max(tee.latitude, green.latitude),
        //             longitude: max(tee.longitude, green.longitude)
        //         )
        //     )
        //     let camera = mapView.mapboxMap.camera(for: bounds, padding: UIEdgeInsets(top: 80, left: 40, bottom: 160, right: 40), bearing: nil, pitch: nil)
        //     mapView.camera.ease(to: camera, duration: 0.5)
        // }

        // MARK: Fairway layer

        // func addFairwayLayer(on mapView: MapView, hole: Hole) {
        //     guard let geometry = hole.fairwayGeometry else { return }
        //     var source = GeoJSONSource(id: fairwaySourceID)
        //     source.data = .feature(Feature(geometry: .polygon(geoJSONPolygon(from: geometry))))
        //     try? mapView.mapboxMap.addSource(source)
        //
        //     var layer = FillLayer(id: fairwayLayerID, source: fairwaySourceID)
        //     layer.fillColor = .constant(StyleColor(UIColor.systemGreen.withAlphaComponent(0.25)))
        //     layer.fillOutlineColor = .constant(StyleColor(UIColor.systemGreen.withAlphaComponent(0.6)))
        //     try? mapView.mapboxMap.addLayer(layer)
        // }

        // MARK: Green layer

        // func addGreenLayer(on mapView: MapView, hole: Hole) {
        //     // Small circle around green center (~20m radius polygon)
        //     let greenCoord = hole.greenCenterCoordinate.clLocation
        //     let greenCircle = buildCirclePolygon(center: greenCoord, radiusMeters: 15, pointCount: 32)
        //
        //     var source = GeoJSONSource(id: greenSourceID)
        //     source.data = .feature(Feature(geometry: .polygon(Polygon([greenCircle.map { [$0.longitude, $0.latitude] }]))))
        //     try? mapView.mapboxMap.addSource(source)
        //
        //     var layer = FillLayer(id: greenLayerID, source: greenSourceID)
        //     layer.fillColor = .constant(StyleColor(UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 0.5)))
        //     try? mapView.mapboxMap.addLayer(layer)
        // }

        // MARK: Dispersion ellipse layer

        // func addDispersionLayer(on mapView: MapView) {
        //     var source = GeoJSONSource(id: dispersionSourceID)
        //     source.data = .feature(Feature(geometry: .polygon(Polygon([[]]))))
        //     try? mapView.mapboxMap.addSource(source)
        //
        //     var layer = FillLayer(id: dispersionLayerID, source: dispersionSourceID)
        //     layer.fillColor = .constant(StyleColor(UIColor(red: 1, green: 1, blue: 0, alpha: 0.35)))
        //     layer.fillOutlineColor = .constant(StyleColor(UIColor.yellow))
        //     try? mapView.mapboxMap.addLayer(layer)
        // }

        // func updateDispersionEllipse(_ coords: [CLLocationCoordinate2D], on mapView: MapView) {
        //     guard !coords.isEmpty else { return }
        //     let ring = coords.map { [$0.longitude, $0.latitude] }
        //     let polygon = Polygon([ring])
        //     let feature = Feature(geometry: .polygon(polygon))
        //     try? mapView.mapboxMap.updateGeoJSONSource(withId: dispersionSourceID, geoJSON: .feature(feature))
        // }

        // MARK: Shot marker (draggable point annotation)

        // func placeShotMarker(mapView: MapView, at coordinate: CLLocationCoordinate2D) {
        //     var annotation = PointAnnotation(coordinate: coordinate)
        //     annotation.image = .init(image: UIImage(systemName: "circle.fill")!
        //         .withTintColor(.systemYellow, renderingMode: .alwaysOriginal), name: "shot-marker")
        //     annotation.isDraggable = true
        //
        //     let manager = mapView.annotations.makePointAnnotationManager()
        //     manager.annotations = [annotation]
        //     manager.delegate = self
        // }

        // func updateShotMarkerPosition(_ coord: CLLocationCoordinate2D, on mapView: MapView) {
        //     // Only update if position differs significantly (avoids loop feedback)
        //     // Annotation manager delegate fires onShotMoved which updates MapViewModel
        //     // which publishes new dispersionEllipse → updateUIView → updateDispersionEllipse
        // }

        // MARK: Static annotations

        // func addTeeAnnotation(on mapView: MapView, hole: Hole) {
        //     guard let tee = hole.teeBoxes.first else { return }
        //     var annotation = PointAnnotation(coordinate: tee.coordinate.clLocation)
        //     annotation.image = .init(image: UIImage(systemName: "t.square.fill")!
        //         .withTintColor(.white, renderingMode: .alwaysOriginal), name: "tee-marker")
        //     mapView.annotations.makePointAnnotationManager(id: "tee").annotations = [annotation]
        // }

        // func addGreenAnnotation(on mapView: MapView, hole: Hole) {
        //     var annotation = PointAnnotation(coordinate: hole.greenCenterCoordinate.clLocation)
        //     annotation.image = .init(image: UIImage(systemName: "flag.fill")!
        //         .withTintColor(.green, renderingMode: .alwaysOriginal), name: "green-marker")
        //     mapView.annotations.makePointAnnotationManager(id: "green").annotations = [annotation]
        // }

        // MARK: Helpers

        // private func geoJSONPolygon(from geometry: GeoJSONGeometry) -> Polygon {
        //     let ring = geometry.coordinates.map { [$0[0], $0[1]] }
        //     return Polygon([ring])
        // }

        // private func buildCirclePolygon(center: CLLocationCoordinate2D, radiusMeters: Double, pointCount: Int) -> [CLLocationCoordinate2D] {
        //     (0..<pointCount).map { i in
        //         let angle = (Double(i) / Double(pointCount)) * 2 * .pi
        //         let dLat = (radiusMeters * cos(angle)) / 111_320
        //         let dLon = (radiusMeters * sin(angle)) / (111_320 * cos(center.latitude * .pi / 180))
        //         return CLLocationCoordinate2D(latitude: center.latitude + dLat, longitude: center.longitude + dLon)
        //     }
        // }
    }

    // MARK: - Placeholder (shown until Mapbox SPM is added)

    private func placeholderView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        let label = UILabel()
        label.text = "Satellite map loads here\nAdd Mapbox Maps SDK via SPM in Xcode"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        return view
    }
}

// MARK: - PointAnnotationManagerDelegate (drag handler)
// Uncomment after adding Mapbox SPM package:
//
// extension MapboxMapView.Coordinator: AnnotationInteractionDelegate {
//     func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {}
// }
//
// extension MapboxMapView.Coordinator: PointAnnotationManagerDelegate {
//     func annotationManager(_ manager: PointAnnotationManager, didDragAnnotation annotation: PointAnnotation) {
//         onShotMoved(annotation.point.coordinates)
//     }
// }
