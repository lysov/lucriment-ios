//
//  TutorRegistrationPayoutVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-05.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import InputMask
import SwiftMessages

class TutorRegistrationPayoutVC: UITableViewController {
	
	var doneButton: UIBarButtonItem!
	@IBOutlet weak var dateOfBirthLabel: UILabel!
	fileprivate var isDateOfBirthPickerOn = false
	@IBOutlet weak var dateOfBirthPicker: UIDatePicker!
	
	// model
	fileprivate var transit: String!
	fileprivate var institution: String!
	fileprivate var account: String!
	fileprivate var dayOfBirth: String!
	fileprivate var monthOfBirth: String!
	fileprivate var yearOfBirth: String!
	fileprivate var sin: String!
	
	var tutorInfoDelegate: TutorRegistrationInfoDelegate!
	var tutorCoursesDelegate: TutorCoursesDelegate!
	
	var transitMaskedDelegate: MaskedTextFieldDelegate!
	var institutionMaskedDelegate: MaskedTextFieldDelegate!
	var accountMaskedDelegate: MaskedTextFieldDelegate!
	var sinMaskedDelegate: MaskedTextFieldDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(TutorRegistrationPayoutVC.doneButtonDidPress))
		self.navigationItem.rightBarButtonItem = doneButton
		
		self.transitMaskedDelegate = MaskedTextFieldDelegate(format: "[00000]")
		self.transitMaskedDelegate.listener = self
		self.institutionMaskedDelegate = MaskedTextFieldDelegate(format: "[000]")
		self.institutionMaskedDelegate.listener = self
		self.accountMaskedDelegate = MaskedTextFieldDelegate(format: "[000000099999]")
		self.accountMaskedDelegate.listener = self
		self.sinMaskedDelegate = MaskedTextFieldDelegate(format: "[000] [000] [000]")
		self.sinMaskedDelegate.listener = self
		
		self.doneButton.isEnabled = false
		self.tableView.tableFooterView = UIView()
		
		self.dateOfBirthPicker.addTarget(self, action: #selector(TutorRegistrationPayoutVC.dateOfBirthPickerDidChange), for: .valueChanged)
		self.configureDateOfBirthPicker()
    }
	
	func configureDateOfBirthPicker() {
		
		// configures self.dateOfBirthLabel
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "d MMMM yyyy"
		let dateOfBirth = dateFormatter.string(from: self.dateOfBirthPicker.date)
		self.dateOfBirthLabel.text = dateOfBirth
		
		// configures self.dayOfBirth, self.monthOfBirth, self.yearOfBirth
		let dayFormatter = DateFormatter()
		dayFormatter.dateFormat = "d"
		self.dayOfBirth = dayFormatter.string(from: self.dateOfBirthPicker.date)
		
		let monthFormatter = DateFormatter()
		monthFormatter.dateFormat = "M"
		self.monthOfBirth = monthFormatter.string(from: self.dateOfBirthPicker.date)
		
		let yearFormatter = DateFormatter()
		yearFormatter.dateFormat = "y"
		self.yearOfBirth = yearFormatter.string(from: self.dateOfBirthPicker.date)
	}
	
	func dateOfBirthPickerDidChange(datePicker: UIDatePicker) {
		// configures self.dateOfBirthLabel
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "d MMMM y"
		let dateOfBirth = dateFormatter.string(from: datePicker.date)
		self.dateOfBirthLabel.text = dateOfBirth
		
		// configures self.dayOfBirth, self.monthOfBirth, self.yearOfBirth
		let dayFormatter = DateFormatter()
		dayFormatter.dateFormat = "d"
		self.dayOfBirth = dayFormatter.string(from: datePicker.date)
		
		let monthFormatter = DateFormatter()
		monthFormatter.dateFormat = "M"
		self.monthOfBirth = monthFormatter.string(from: datePicker.date)
		
		let yearFormatter = DateFormatter()
		yearFormatter.dateFormat = "y"
		self.yearOfBirth = yearFormatter.string(from: datePicker.date)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// transit
		var indexPath = IndexPath(row: 0, section: 0)
		let transitCell = self.tableView.cellForRow(at: indexPath) as! TextFieldCell
		transitCell.textField.delegate = self.transitMaskedDelegate
		
		// institution
		indexPath = IndexPath(row: 1, section: 0)
		let institutionCell = self.tableView.cellForRow(at: indexPath) as! TextFieldCell
		institutionCell.textField.delegate = self.institutionMaskedDelegate
		
		// account
		indexPath = IndexPath(row: 2, section: 0)
		let accountCell = self.tableView.cellForRow(at: indexPath) as! TextFieldCell
		accountCell.textField.delegate = self.accountMaskedDelegate
		
		// sin
		indexPath = IndexPath(row: 5, section: 0)
		let sinCell = self.tableView.cellForRow(at: indexPath) as! TextFieldCell
		sinCell.textField.delegate = self.sinMaskedDelegate
	}
	
	func doneButtonDidPress() {
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.showNoNetworkNotification()
		} else {
			// terms of service acceptance
			var tos_acceptance = [String: Any]()
			tos_acceptance["ip"] = ReachabilityManager.shared().IPAddress
			tos_acceptance["date"] = Int(Date().timeIntervalSince1970)
			
			// birthday
			var dob = [String: Int]()
			dob["day"] = Int(self.dayOfBirth)
			dob["month"] = Int(self.monthOfBirth)
			dob["year"] = Int(self.yearOfBirth)
			
			// address
			var address = [String: Any]()
			address["city"] = self.tutorInfoDelegate.city
			address["country"] = "CA"
			address["line1"] = self.tutorInfoDelegate.street
			address["postal_code"] = self.tutorInfoDelegate.postalCode
			address["state"] = self.tutorInfoDelegate.province
			
			// legal entity
			var legal_entity = [String: Any]()
			legal_entity["address"] = address
			legal_entity["dob"] = dob
			legal_entity["first_name"] = UserManager.shared.firstName
			legal_entity["last_name"] = UserManager.shared.lastName
			legal_entity["personal_id_number"] = self.sin
			legal_entity["type"] = "individual"
			
			// external_account
			var external_account = [String: String]()
			external_account["object"] = "bank_account"
			external_account["account_number"] = self.account
			external_account["country"] = "CA"
			external_account["currency"] = "CAD"
			external_account["routing_number"] = self.transit + "-" + self.institution
			
			// stripe connected
			var stripe_connected = [String: Any]()
			stripe_connected["tos_acceptance"] = tos_acceptance
			stripe_connected["legal_entity"] = legal_entity
			stripe_connected["external_account"] = external_account
			
			// tutor
			var tutor = [String: Any]()
			tutor["phoneNumber"] = self.tutorInfoDelegate.phoneNumber
			tutor["postalCode"] = self.tutorInfoDelegate.postalCode
			if let profileImage = UserManager.shared.profileImage {
				tutor["profileImage"] = profileImage
			}
			tutor["rate"] = Int(self.tutorInfoDelegate.rate)
			if let courses = self.tutorCoursesDelegate.courses {
				
				tutor["subjects"] = courses.toDictionary()
				
				for course in courses {
					tutor[course] = true
				}
			}
			
			UserManager.shared.updateStripePayoutInfo(with: stripe_connected) { (error) in
				if let error = error {
					print(error.localizedDescription)
					self.dismiss(animated: true, completion: nil)
				} else {
					UserManager.shared.updateCurrent(.tutor, with: tutor) { (error) in
						if let error = error {
							print(error.localizedDescription)
							self.dismiss(animated: true, completion: nil)
						} else {
							// geocoding
							let postalCode = address["postal_code"] as! String
							LocationManager.addressFor(postalCode) { (address, error) in
								if let error = error {
									print(error.localizedDescription)
								} else if let address = address {
									UserManager.shared.updateCurrent(.tutor, with: ["address": address]) { (error) in
										if let error = error {
											print(error.localizedDescription)
										}
									}
								}
							}
							
							self.dismiss(animated: true, completion: {
								self.presentTutorBarController()
							})
						}
					}
				}
			}
		}
	}
	
	func showNoNetworkNotification() {
		let notificationView: MessageView = try! SwiftMessages.viewFromNib(named: "NoNetworkNotification")
		notificationView.preferredHeight = 35
		var config = SwiftMessages.Config()
		config.duration = .seconds(seconds: 3)
		
		SwiftMessages.show(config: config, view: notificationView)
	}
}

// MARK:- UITableViewDataSource
extension TutorRegistrationPayoutVC {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		let cellIndex = indexPath.row
		
		switch cellIndex {
		case 3:
			self.isDateOfBirthPickerOn = !self.isDateOfBirthPickerOn
		case 0, 1, 2, 5:
			self.isDateOfBirthPickerOn = false
		default:
			return
		}
		self.tableView.reloadRows(at: [indexPath], with: .automatic)
		self.tableView.reloadData()
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let cellIndex = indexPath.row
		switch cellIndex {
		case 4:
			if self.isDateOfBirthPickerOn {
				self.dateOfBirthLabel.textColor = UIColor(red:0.13, green:0.66, blue:0.88, alpha:1.0)
				return 216
			} else {
				self.dateOfBirthLabel.textColor = UIColor(red:0.18, green:0.20, blue:0.20, alpha:1.0)
				return 0
			}
		default:
			return super.tableView(tableView, heightForRowAt: indexPath)
		}
	}
}

extension TutorRegistrationPayoutVC: MaskedTextFieldDelegateListener {
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		self.isDateOfBirthPickerOn = false
		self.tableView.beginUpdates()
		self.tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
		tableView.endUpdates()
		return true
	}
	
	internal func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
		
		switch textField.tag {
		case 0:
			if let transit = textField.text {
				self.transit = transit
			}
		case 1:
			if let institution = textField.text {
				self.institution = institution
			}
		case 2:
			if let account = textField.text {
				self.account = account
			}
		case 3:
			if let sin = textField.text {
				let formattedSIN = sin.replacingOccurrences(of: " ", with: "")
				self.sin = formattedSIN
			}
		default:
			break
		}
		
		if let transit = self.transit, let institution = self.institution, let account = self.account, let sin = self.sin {
			if !(transit.characters.count == 5) {
				self.doneButton.isEnabled = false
				return
			}
			if !(institution.characters.count == 3) {
				self.doneButton.isEnabled = false
				return
			}
			if account.characters.count >= 7 {
				if !(account.characters.count <= 12) {
					self.doneButton.isEnabled = false
					return
				}
			} else {
				self.doneButton.isEnabled = false
				return
			}
			if !Format.isValidFor(sin: sin) {
				self.doneButton.isEnabled = false
				return
			}
			self.doneButton.isEnabled = true
		}
	}
}

extension TutorRegistrationPayoutVC {
	// presents TutorBarController
	fileprivate func presentTutorBarController() {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		appDelegate.presentTutorBarController()
	}
}
