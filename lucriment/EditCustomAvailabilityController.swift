//
//  EditCustomAvailabilityController.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-28.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

protocol CustomAvailabilityDelegate {
	var defaultAvailabilties: [Timeslot]! { get }
	var selectedDay: Date! { get }
	var timeslotDelegate: (String, Timeslot)! { get }
}

class EditCustomAvailabilityController: UIViewController {

	var delegate: CustomAvailabilityDelegate!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancel))
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.done))
		
		// customize view controller
		self.title = "Edit Availability"
	}
	
	func cancel() {
		self.dismiss(animated: true, completion: nil)
	}
	
	func done() {
		let vc = self.childViewControllers.first as! EditCustomAvailabilityVC
		vc.done()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "EditCustomAvailabilityVC") {
			let vc = segue.destination as! EditCustomAvailabilityVC
			vc.delegate = self.delegate
		}
	}
	@IBAction func deleteButtonDidPress(_ sender: Any) {
		self.presentAlert()
	}
	
	func deleteCustomAvailability() {
		
		//let customAvailability = self.delegate.timeslot
		//let day = self.delegate.day
		
		// TODO: REMOVE FOR CUSTOM AVAILABILITY
		// push defaultAvailabilities
		
		//UserManager.shared.remove(defaultAvailability, for: day)
		
		// add custom slot and convert the rest of from the default av.
		
		// delete availability
		
		if let defaultAvailabilities = self.delegate.defaultAvailabilties {
			
			// deletes default availabaility and convert the rest of the default availability to custom availabilities
			UserManager.shared.deleteCustomAvailability(key: self.delegate.timeslotDelegate.0, defaultAvailabilities: defaultAvailabilities, for: self.delegate.selectedDay)
			
		} else {
			
			// deletes custom availability
			UserManager.shared.deleteCustomAvailability(key: self.delegate.timeslotDelegate.0, defaultAvailabilities: nil, for: self.delegate.selectedDay)
		}
		
		self.dismiss(animated: true, completion: nil)
	}
	
	internal func presentAlert() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Delete Availability", style: .destructive, handler: { (UIAlertAction) in
			self.deleteCustomAvailability()
		}))
		self.present(alert, animated: true, completion: nil)
	}
}
