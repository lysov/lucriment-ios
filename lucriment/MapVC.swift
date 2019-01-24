//
//  MapVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-08.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import GoogleMaps

class MapVC: UIViewController {
	
	fileprivate var camera: GMSCameraPosition!
	fileprivate var mapView: GMSMapView!
	fileprivate var marker: GMSMarker!
	fileprivate var circle: GMSCircle!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let postalCode = UserManager.shared.postalCode {
			
			LocationManager.forwardGeocoding(address: postalCode) { (latitude, longitude, error) in
				if let error = error {
					print(error.localizedDescription)
					return
				} else if let latitude = latitude, let longitude = longitude {
					print("lat = \(latitude), lon = \(longitude)")
					self.camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 10.0)
					self.mapView = GMSMapView.map(withFrame: CGRect.zero, camera: self.camera)
					self.view = self.mapView
					
					// Creates a marker in the center of the map.
					self.marker = GMSMarker()
					self.marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
					self.marker.map = self.mapView
					
					self.circle = GMSCircle()
					self.circle.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
					self.circle.radius = 600
					self.circle.strokeColor = UIColor(red:0.13, green:0.66, blue:0.88, alpha:1.0)
					self.circle.strokeWidth = 2
					self.circle.fillColor = UIColor(red:0.13, green:0.66, blue:0.88, alpha:0.5)
					self.circle.map = self.mapView
				}
			}
		}
	}
	
	func refresh() {
		if let postalCode = UserManager.shared.postalCode {
			LocationManager.forwardGeocoding(address: postalCode) { (latitude, longitude, error) in
				if let error = error {
					print(error.localizedDescription)
					return
				} else if let latitude = latitude, let longitude = longitude {
					print("lat = \(latitude), lon = \(longitude)")
					self.camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 10.0)
					self.mapView = GMSMapView.map(withFrame: CGRect.zero, camera: self.camera)
					self.view = self.mapView
					
					// Creates a marker in the center of the map.
					self.marker = GMSMarker()
					self.marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
					self.marker.map = self.mapView
					
					self.circle = GMSCircle()
					self.circle.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
					self.circle.radius = 600
					self.circle.strokeColor = UIColor(red:0.13, green:0.66, blue:0.88, alpha:1.0)
					self.circle.strokeWidth = 2
					self.circle.fillColor = UIColor(red:0.13, green:0.66, blue:0.88, alpha:0.5)
					self.circle.map = self.mapView
				}
			}
		}
	}
}
