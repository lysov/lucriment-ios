//
//  SessionRequestDetailsVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-04.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import GooglePlacePicker

class SessionRequestDetailsVC: UITableViewController {

	// cells
	@IBOutlet weak var tutorCell: TutorCell!
	@IBOutlet weak var subjectLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var locationLabel: UILabel!
	
	var delegate: SessionRequestDetailsDelegate!
	var parentVC: SessionRequestDetailsController!
	
	var price: Double!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Session Request Details"
		self.tableView.tableFooterView = UIView()
		
		// configure cells
		
		// tutor cell
		self.tutorCell.nameLabel.text = self.delegate.tutor.fullName
		
		self.tutorCell.profileImageView.isHidden = true
		self.tutorCell.profileImageView.image = nil
		// downloads profile image
		if let profileImageReference = self.delegate.tutor.profileImage {
			let url = URL(string: "\(profileImageReference)")
			
			self.tutorCell.profileImageView.isHidden = false
			self.tutorCell.profileImageView.sd_setImage(with: url, placeholderImage: nil)
		}
		
		if let headline = self.delegate.tutor.headline {
			self.tutorCell.headlineLabel.text = headline
		} else {
			self.tutorCell.headlineLabel.text = ""
		}
		
		if let rating = self.delegate.tutor.rating {
			self.tutorCell.ratingLabel.text = "\(rating.rounded(toPlaces: 1))"
		}
		
		self.tutorCell.rateLabel.text = "$\(self.delegate.tutor.rate)/h"
		
		self.tutorCell.cityLabel.text = self.delegate.tutor.address ?? self.delegate.tutor.postalCode
		
		
		
		// subject cell
		self.subjectLabel.text = self.delegate.subject
		
		// time cell
		let dayFormatter = DateFormatter()
		dayFormatter.dateFormat = "MMMM d"
		
		let timeFormatter = DateFormatter()
		timeFormatter.dateFormat = "h:mm a"
		
		let day = dayFormatter.string(from: self.delegate.timeslot.from.day())
		let from = timeFormatter.string(from: self.delegate.timeslot.from)
		let to = timeFormatter.string(from: self.delegate.timeslot.to)
		self.timeLabel.text = "\(day), \(from) - \(to)"
		
		// total label
		let minutes = (self.delegate.timeslot.to.timeIntervalSince1970 - self.delegate.timeslot.from.timeIntervalSince1970) / 60
		let total = ( (Double(self.delegate.tutor.rate) * minutes / 60) + (Double(self.delegate.tutor.rate) * minutes / 60) * 0.029 + 0.30 ).rounded(toPlaces: 2)
		self.price = total
		
		self.parentVC.totalLabel.text = "$\(total) for \(Int(minutes)) minutes"
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		self.tableView.deselectRow(at: indexPath, animated: true)
		
		let row = indexPath.row
		
		switch row {
		case 1:
			self.presentSessionRequestDetailsSubjectsVC()
		case 3:
			self.presentPlacePicker()
		default:
			break
		}
	}
	
}

extension SessionRequestDetailsVC {
	// presents SessionRequestDetailsSubjectsVC
	fileprivate func presentSessionRequestDetailsSubjectsVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentSearch", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "SessionRequestDetailsSubjectsVC") as! SessionRequestDetailsSubjectsVC
		vc.id = self.delegate.tutor.id
		vc.selectedSubject = self.delegate.subject
		vc.parentVC = self
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	// presents GMSAutocompleteVC
	fileprivate func presentPlacePicker() {
		
		if let address = self.locationLabel.text, address != "Choose Location" {
			LocationManager.forwardGeocoding(address: address) { (latitude, longitude, error) in
				if let error = error {
					print(error.localizedDescription)
				} else if let latitude = latitude, let longitude = longitude {
					let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
					let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001,
														   longitude: center.longitude + 0.001)
					let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001,
														   longitude: center.longitude - 0.001)
					let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
					let config = GMSPlacePickerConfig(viewport: viewport)
					UINavigationBar.appearance().tintColor = LUCColor.blue
					UINavigationBar.appearance().barTintColor = .white
					UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: LUCColor.black]
					let placePicker = GMSPlacePickerViewController(config: config)
					placePicker.delegate = self
					self.present(placePicker, animated: true, completion: nil)
				}
			}
		} else {
			let config = GMSPlacePickerConfig(viewport: nil)
			UINavigationBar.appearance().tintColor = LUCColor.blue
			UINavigationBar.appearance().barTintColor = .white
			UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: LUCColor.black]
			let placePicker = GMSPlacePickerViewController(config: config)
			placePicker.delegate = self
			self.present(placePicker, animated: true, completion: nil)
		}
		
	}
}

extension SessionRequestDetailsVC: GMSPlacePickerViewControllerDelegate {
	
	func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
		
		UINavigationBar.appearance().tintColor = .white
		UINavigationBar.appearance().barTintColor = LUCColor.blue
		UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
		
		// Dismiss the place picker, as it cannot dismiss itself.
		if let address = place.formattedAddress {
			self.locationLabel.text = address
		}
		
		viewController.dismiss(animated: true, completion: nil)
	}
	
	func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
		
		UINavigationBar.appearance().tintColor = .white
		UINavigationBar.appearance().barTintColor = LUCColor.blue
		UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
		
		// Dismiss the place picker, as it cannot dismiss itself.
		viewController.dismiss(animated: true, completion: nil)
	}
	
}

