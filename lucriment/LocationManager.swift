//
//  Geocoding
//  lucriment
//
//  Created by Anton Lysov on 2017-09-09.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation
import CoreLocation
import AddressBookUI
import Contacts

enum GeocodingError: Error {
	case network
}

class LocationManager {
	static func forwardGeocoding(address: String, _ completion: @escaping (Double?, Double?, Error?) -> ()) {
		CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			if let placemarks = placemarks {
				if placemarks.count > 0 {
					let placemark = placemarks[0]
					let location = placemark.location
					let coordinate = location?.coordinate
					print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
					completion(Double(coordinate!.latitude), Double(coordinate!.longitude), nil)
				} else {
					completion(nil, nil, GeocodingError.network)
				}
			} else {
				completion(nil, nil, GeocodingError.network)
			}
		})
	}
	
	// returns "Calgary, AB"
	static func addressFor(_ address: String, _ completion: @escaping (String?, Error?) -> ()) {
		CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			else if let placemarks = placemarks {
				if placemarks.count > 0 {
					let placemark = placemarks[0]
					if let locality = placemark.locality, let administrativeArea = placemark.administrativeArea {
						let address = "\(locality), \(administrativeArea)"
						completion(address, nil)
					} else {
						completion(nil, GeocodingError.network)
					}
				} else {
					completion(nil, GeocodingError.network)
				}
			} else {
				completion(nil, GeocodingError.network)
			}
		})
	}
}
