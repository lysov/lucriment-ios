//
//  EditDefaultAvailabilityController.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-27.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

protocol DefaultAvailabilityDelegate {
	var day: WeekDay! { get }
	var timeslot: Timeslot! { get }
}

class EditDefaultAvailabilityController: UIViewController {

	var delegate: DefaultAvailabilityDelegate!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancel))
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.done))

		// customize view controller
		self.title = "Edit Default Availability"
    }
	
	func cancel() {
		self.dismiss(animated: true, completion: nil)
	}
	
	func done() {
		let vc = self.childViewControllers.first as! EditDefaultAvailabilityVC
		vc.done()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "EditDefaultAvailabilityVC") {
			let vc = segue.destination as! EditDefaultAvailabilityVC
			vc.delegate = self.delegate
		}
	}
	@IBAction func deleteButtonDidPress(_ sender: Any) {
		self.presentAlert()
	}
	
	func deleteDefaultAvailability() {

		let defaultAvailability = self.delegate.timeslot
		let day = self.delegate.day
		
		UserManager.shared.remove(defaultAvailability, for: day)
		
		self.dismiss(animated: true, completion: nil)
	}
	
	internal func presentAlert() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Delete Availability", style: .destructive, handler: { (UIAlertAction) in
			self.deleteDefaultAvailability()
		}))
		self.present(alert, animated: true, completion: nil)
	}
}
