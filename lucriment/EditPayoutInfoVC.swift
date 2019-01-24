//
//  EditPayoutInfoVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-15.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import InputMask
import SwiftMessages

class EditPayoutInfoVC: UITableViewController {
	
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	// model
	fileprivate var transit: String!
	fileprivate var institution: String!
	fileprivate var account: String!
	
	var transitMaskedDelegate: MaskedTextFieldDelegate!
	var institutionMaskedDelegate: MaskedTextFieldDelegate!
	var accountMaskedDelegate: MaskedTextFieldDelegate!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.transitMaskedDelegate = MaskedTextFieldDelegate(format: "[00000]")
		self.transitMaskedDelegate.listener = self
		self.institutionMaskedDelegate = MaskedTextFieldDelegate(format: "[000]")
		self.institutionMaskedDelegate.listener = self
		self.accountMaskedDelegate = MaskedTextFieldDelegate(format: "[000000099999]")
		self.accountMaskedDelegate.listener = self
		
		self.doneButton.isEnabled = false
		self.tableView.tableFooterView = UIView()
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
	}
	
	@IBAction func cancelButtonDidPress(_ sender: Any) {
		self.navigationController?.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func doneButtonDidPress(_ sender: Any) {
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.showNoNetworkNotification()
		} else {
			// external_account
			var external_account = [String: AnyObject]()
			external_account["object"] = "bank_account" as AnyObject
			external_account["account_number"] = self.account as AnyObject
			external_account["country"] = "CA" as AnyObject
			external_account["currency"] = "CAD" as AnyObject
			external_account["routing_number"] = self.transit + "-" + self.institution as AnyObject
			
			DatabaseManager.shared.updatePayoutInfo(external_account) { (error) in
				if let error = error {
					print(error.localizedDescription)
					self.presentAlert(title: "Unknown Error", message: nil)
				} else {
					let alert = UIAlertController(title: "Payout method has been successfully updated", message: nil, preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
						self.navigationController?.dismiss(animated: true, completion: nil)
					}))
					self.navigationController?.present(alert, animated: true, completion: nil)
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
	
	internal func presentAlert(title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.navigationController?.present(alert, animated: true, completion: nil)
	}
}

// MARK:- UITableViewDataSource
extension EditPayoutInfoVC {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension EditPayoutInfoVC: MaskedTextFieldDelegateListener {
	
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
		default:
			break
		}
		
		if let transit = self.transit, let institution = self.institution, let account = self.account {
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
			self.doneButton.isEnabled = true
		}
	}
}
