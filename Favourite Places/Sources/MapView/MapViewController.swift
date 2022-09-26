//
//  MapViewController.swift
//  Favourite Places
//
//  Created by User on 26.09.2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var place: Place!

    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupPlaceMark()
    }

    private func setupHierarchy() {
        view.addSubview(mapView)
    }

    private func setupLayout() {
        mapView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(view)
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

}
