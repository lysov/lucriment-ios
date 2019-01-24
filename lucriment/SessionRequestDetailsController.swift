//
//  SessionRequestDetailsController.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-05.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class SessionRequestDetailsController: UIViewController {

	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var buttonsView: UIView!
	var delegate: SessionRequestDetailsDelegate!
	var childVC: SessionRequestDetailsVC!
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.buttonsView.layer.cornerRadius = 20
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		self.title = "Session Request Details"
		
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "SessionRequestDetailsVC") {
			let vc = segue.destination as! SessionRequestDetailsVC
			vc.parentVC = self
			vc.delegate = self.delegate
			self.childVC = vc
		}
	}
	
	@IBAction func bookSessionButtonDidPress(_ sender: Any) {
		if self.childVC.locationLabel.text == "Choose Location" {
			self.presentAlert(title: "Choose Location", message: nil)
		} else {
			let alert = UIAlertController(title: "Session Confirmation", message: "Would you like to confirm booking a scheduled session with \(self.delegate.tutor.firstName)?", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (UIAlertAction) in
				self.bookSession()
			}))
			alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
			
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	func bookSession() {
		
		let location = self.childVC.locationLabel.text!
		let price = self.childVC.price!
		let studentId = UserManager.shared.id!
		let studentName = UserManager.shared.fullName!
		let subject = self.childVC.subjectLabel.text!
		let time = self.delegate.timeslot!
		let tutorId = self.delegate.tutor.id
		let tutorName = self.delegate.tutor.fullName
		
		var session = [String: Any]()
		session["confirmed"] = false
		session["location"] = location
		session["price"] = price
		session["sessionCancelled"] = false
		session["sessionDeclined"] = false
		session["studentId"] = studentId
		session["studentName"] = studentName
		session["subject"] = subject
		session["time"] = time.toDictionary()
		session["tutorId"] = tutorId
		session["tutorName"] = tutorName
		
		DatabaseManager.shared.request(session) {
			let alert = UIAlertController(title: "Session has been successfully booked", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
				self.navigationController?.popToRootViewController(animated: true)
			}))
			self.present(alert, animated: true, completion: nil)
		}
	}
}

extension SessionRequestDetailsController {
	internal func presentAlert(title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}
