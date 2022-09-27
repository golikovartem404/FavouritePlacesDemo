//
//  MapViewController.swift
//  Favourite Places
//
//  Created by User on 26.09.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionPerimeter = 10000.0

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupPlaceMark()
        checkLocationServices()
    }

    private func setupHierarchy() {
        view.addSubview(mapView)
        view.addSubview(userLocationButton)
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
    }

    private func setupPlaceMark() {
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
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default)
        alert.addAction(actionOK)
        present(alert, animated: true)
    }

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

    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        case .denied:
            // Show alert
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            // Show alert
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }

    @objc func centerViewInUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionPerimeter,
                                            longitudinalMeters: regionPerimeter)
            mapView.setRegion(region, animated: true)
        }
    }

}

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
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
