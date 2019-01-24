//
//  EditPaymentInfoVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-28.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import InputMask
import MBProgressHUD
import Stripe

class EditPaymentInfoVC: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
	fileprivate var cardNumber: String!
	fileprivate var expires: String!
	fileprivate var cvv: String!

	var cardNumberMaskedDelegate: MaskedTextFieldDelegate!
	var expiresMaskedDelegate: MaskedTextFieldDelegate!
	var cvvMaskedDelegate: MaskedTextFieldDelegate!
	
	internal var activityIndicator: MBProgressHUD!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.tableFooterView = UIView()
		
		self.cardNumberMaskedDelegate = MaskedTextFieldDelegate(format: "[0000] [0000] [0000] [0000] [000]")
		self.expiresMaskedDelegate = MaskedTextFieldDelegate(format: "[00]/[00]")
		self.cvvMaskedDelegate = MaskedTextFieldDelegate(format: "[000]")
		
		self.cardNumberMaskedDelegate.listener = self
		self.expiresMaskedDelegate.listener = self
		self.cvvMaskedDelegate.listener = self
	}
	
	@IBAction func cancelButtonDidPress(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func doneButtonDidPress(_ sender: Any) {
		
		if let cardNumber = self.cardNumber, let expires = self.expires, let cvv = self.cvv {
			let formattedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
			guard Format.isValidFor(cardNumber: formattedCardNumber) else {
				self.presentAlert(title: "Invalid Card Number", message: nil)
				return
			}
			let formattedExpires = expires.replacingOccurrences(of: "/", with: "")
			guard Format.isValidFor(expires: formattedExpires) else {
				self.presentAlert(title: "Invalid Expiry Date", message: nil)
				return
			}
			guard Format.isValidFor(cvv: cvv) else {
				self.presentAlert(title: "Invalid CVV", message: nil)
				return
			}
			if ReachabilityManager.shared().reachabilityStatus == .notReachable {
				self.presentAlert(title: "No Internet Connection", message: "Please check your Internet connection.")
			} else {
				print("credit card is valid")
			}
			
			// update credit card info
			let month = formattedExpires.substring(from: 0, to: 1)
			let year = formattedExpires.substring(from: 2, to: 3)
			
			var cardDictionary = [String: AnyObject]()
			cardDictionary["object"] = "card" as AnyObject
			cardDictionary["number"] = formattedCardNumber as AnyObject
			cardDictionary["exp_month"] = month as AnyObject
			cardDictionary["exp_year"] = year as AnyObject
			
			// Stripe Card Validation
			
			let isValidNumber = STPCardValidator.validationState(forNumber: formattedCardNumber, validatingCardBrand: true)
			if isValidNumber == .invalid {
				self.presentAlert(title: "Invalid Credit Card Info", message: nil)
				return
			}
			
			let cardBrand = STPCardValidator.brand(forNumber: formattedCardNumber)
			if !(cardBrand == .visa || cardBrand == .masterCard || cardBrand == .amex) {
				self.presentAlert(title: "Invalid Credit Card Info", message: nil)
				return
			}
			
			let isValidCVV = STPCardValidator.validationState(forCVC: self.cvv, cardBrand: cardBrand)
			if isValidCVV == .invalid {
				self.presentAlert(title: "Invalid Credit Card Info", message: nil)
				return
			}
			
			let isValidExpirationYear = STPCardValidator.validationState(forExpirationYear: year, inMonth: month) // last two digits of the year
			if isValidExpirationYear == .invalid {
				self.presentAlert(title: "Invalid Credit Card Info", message: nil)
				return
			}
			
			DatabaseManager.shared.updatePaymentInfo(cardDictionary) { (error) in
				if let error = error {
					print(error.localizedDescription)
					self.presentAlert(title: "Unknown Error", message: nil)
				} else {
					let alert = UIAlertController(title: "Payment method has been successfully updated", message: nil, preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
						self.navigationController?.dismiss(animated: true, completion: nil)
					}))
					self.navigationController?.present(alert, animated: true, completion: nil)
				}
			}
		} else {
			// upload user profile info
			self.presentAlert(title: "Please Enter Your Credit Card Information", message: nil)
			return
		}
		
		
	}
}

extension EditPaymentInfoVC: MaskedTextFieldDelegateListener {
	func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
		if let text = textField.text {
			switch textField.tag {
			case 0:
				self.cardNumber = text
			case 1:
				self.expires = text
			default:
				self.cvv = text
			}
		}
	}
}

extension EditPaymentInfoVC: ActivityIndicatorDelegate {
	internal func presentAlert(title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.navigationController?.present(alert, animated: true, completion: nil)
	}
	
	internal func displayActivityIndicatorView() -> () {
		self.activityIndicator = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
		self.activityIndicator.label.text = "Loading..."
		self.navigationController?.view.isUserInteractionEnabled = false
	}
	
	internal func hideActivityIndicatorView() -> () {
		self.navigationController?.view.isUserInteractionEnabled = true
		DispatchQueue.main.async {
			self.activityIndicator.hide(animated: true)
		}
	}
}

// MARK: - Table View
extension EditPaymentInfoVC: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let row = indexPath.row
		
		if row == 3 {
			let cell = self.tableView.dequeueReusableCell(withIdentifier: "stripe")!
			return cell
		}
		
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as! TextFieldCell
		
		switch indexPath.row {
		case 0:
			cell.textLabel?.text = "Number"
			cell.textField?.tag = 0
			cell.textField?.placeholder = "1234 1234 1234 1234"
			cell.textField.delegate = self.cardNumberMaskedDelegate

		case 1:
			cell.textLabel?.text = "Expires"
			cell.textField?.tag = 1
			cell.textField?.placeholder = "MM/YY"
			cell.textField.delegate = self.expiresMaskedDelegate
		default:
			cell.textLabel?.text = "CVV"
			cell.textField?.tag = 2
			cell.textField?.placeholder = "123"
			cell.textField.delegate = self.cvvMaskedDelegate
		}
		
		return cell
	}
}
