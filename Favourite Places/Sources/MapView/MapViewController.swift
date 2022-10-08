//
//  MapViewController.swift
//  Favourite Places
//
//  Created by User on 26.09.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewDelegate {
    func setAddressOfPlace(_ address: String?)
}

class MapViewController: UIViewController {

    // MARK: - Properties

    var mapViewDelegate: MapViewDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionPerimeter = 4000.0
    var placeCoordinate: CLLocationCoordinate2D?
    var locationReceived = false

    // MARK: - Outlets

    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.delegate = self
        return map
    }()

    private lazy var userLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "userlocation"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(centerViewInUserLocation), for: .touchUpInside)
        return button
    }()

    lazy var placeLocationAddress: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .black
        return label
    }()

    lazy var userPin: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeLocation")
        return imageView
    }()

    lazy var userAddressSetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        return button
    }()

    lazy var routeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "compass"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(routeButtonPressed), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        checkLocationServices()
    }

    // MARK: - Setup view

    private func setupHierarchy() {
        view.addSubview(mapView)
        view.addSubview(placeLocationAddress)
        view.addSubview(userPin)
        view.addSubview(userAddressSetButton)
        view.addSubview(userLocationButton)
        view.addSubview(routeButton)
    }

    private func setupLayout() {
        mapView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(view)
        }

        userLocationButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-45)
            make.right.equalTo(view.snp.right).offset(-30)
            make.width.height.equalTo(50)
        }

        userPin.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY).offset(14)
            make.width.height.equalTo(40)
        }

        placeLocationAddress.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY).multipliedBy(0.4)
            make.width.equalTo(view.snp.width).multipliedBy(0.9)
        }

        userAddressSetButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.snp.bottom).offset(-45)
        }

        routeButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-45)
            make.left.equalTo(view.snp.left).offset(30)
            make.width.height.equalTo(50)
        }
        
    }

    // Alert function
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default)
        alert.addAction(actionOK)
        present(alert, animated: true)
    }


    // Setup place address point function
    func setupPlaceMark() {
        guard let location = place.location else { return }

        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }

            let placemark = placemarks.first

            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type

            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }

    func configurePlacemark(with place: Place) {
        self.place.name = place.name
        self.place.location = place.location
        self.place.type = place.type
        self.place.imageData = place.imageData
    }

    // Check geolocation services function
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location services are disable",
                               message: "You need to go to Settings and turn On")
            }
        }
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // Check location authorization
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            showUserLocation()
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location services are disable",
                               message: "You need to go to Settings and turn On")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }


    @objc func centerViewInUserLocation() {
        showUserLocation()
    }


    // Set place address
    @objc func doneButtonPressed() {
        mapViewDelegate?.setAddressOfPlace(placeLocationAddress.text)
        navigationController?.popViewController(animated: true)
    }

    // Show route to place
    @objc func routeButtonPressed() {
        getDirections()
    }

    // Show current user location
    func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionPerimeter,
                                            longitudinalMeters: regionPerimeter)
            mapView.setRegion(region, animated: true)
        }
    }

    // Get center map location function
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    // Get route to place function
    private func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Route is not available")
                return
            }
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeOfRoute = String(route.expectedTravelTime / 60)
                print("Distanse is \(distance) km, time is \(timeOfRoute) min")
            }
        }
    }

    // Create direction request function
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        return request
    }

}

// MARK: - Extensions

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil}
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationIdentifier") as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "annotationIdentifier")
            annotationView?.canShowCallout = true
        }
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.placeLocationAddress.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.placeLocationAddress.text = "\(streetName!)"
                } else {
                    self.placeLocationAddress.text = ""
                }
            }
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .systemRed
        return render
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locationReceived {
            checkLocationAuthorization()
            locationReceived = true
        }
    }
}

