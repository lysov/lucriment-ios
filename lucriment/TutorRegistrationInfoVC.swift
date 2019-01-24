//
//  TutorRegistrationInfoVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-02.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import InputMask

protocol TutorRegistrationInfoDelegate {
	var rate: String { get }
	var phoneNumber: String! { get }
	var street: String! { get }
	var city: String! { get }
	var province: String { get }
	var postalCode: String! { get }
}

class TutorRegistrationInfoVC: UITableViewController, TutorRegistrationInfoDelegate {
	
	@IBOutlet weak var phoneNumberTextField: UITextField!
	@IBOutlet weak var streetTextField: UITextField!
	@IBOutlet weak var cityTextField: UITextField!
	@IBOutlet weak var postalCodeTextField: UITextField!
	
	@IBOutlet weak var nextButton: UIBarButtonItem!
	@IBOutlet weak var rateLabel: UILabel!
	@IBOutlet weak var provinceLabel: UILabel!
	@IBOutlet weak var ratePicker: UIPickerView!
	@IBOutlet weak var provincePicker: UIPickerView!
	fileprivate var isRatePickerOn = false
	fileprivate var isProvincePickerOn = false
	var phoneNumberMaskedDelegate: MaskedTextFieldDelegate!
	var streetMaskedDelegate: MaskedTextFieldDelegate!
	var postalCodeMaskedDelegate: MaskedTextFieldDelegate!
	var cityMaskedDelegate: MaskedTextFieldDelegate!
	
	// TutorInfoDelegate implementation
	var rate = "25"
	var phoneNumber: String!
	var street: String!
	var city: String!
	var province = "AB"
	var postalCode: String!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.ratePicker.selectRow(10, inComponent: 0, animated: false)
		self.provincePicker.selectRow(0, inComponent: 0, animated: false)
		
		// configure phone number cell
		self.phoneNumberMaskedDelegate = MaskedTextFieldDelegate(format: "([000]) [000]-[0000]")
		self.phoneNumberMaskedDelegate.listener = self
		self.postalCodeMaskedDelegate = MaskedTextFieldDelegate(format: "[___] [___]")
		self.postalCodeMaskedDelegate.listener = self
		
		self.tableView.tableFooterView = UIView()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// phone number
		var indexPath = IndexPath(row: 2, section: 0)
		let phoneNumberCell = self.tableView.cellForRow(at: indexPath) as! TextFieldCell
		phoneNumberCell.textField.delegate = self.phoneNumberMaskedDelegate
		
		// postal code
		indexPath = IndexPath(row: 7, section: 0)
		let postalCodeCell = self.tableView.cellForRow(at: indexPath) as! TextFieldCell
		postalCodeCell.textField.delegate = self.postalCodeMaskedDelegate
	}
}

// navigation controller buttons
extension TutorRegistrationInfoVC {
	@IBAction func cancelButtonDidPress() {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func nextButtonDidPress() {
		self.presentTutorRegistrationClassesVC()
	}
}

extension TutorRegistrationInfoVC: MaskedTextFieldDelegateListener {
	internal func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
		
		switch textField.tag {
		case 0:
			if let phoneNumber = textField.text {
				var formattedPhoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
				formattedPhoneNumber = formattedPhoneNumber.replacingOccurrences(of: "(", with: "")
				formattedPhoneNumber = formattedPhoneNumber.replacingOccurrences(of: ")", with: "")
				formattedPhoneNumber = formattedPhoneNumber.replacingOccurrences(of: "-", with: "")
				self.phoneNumber = formattedPhoneNumber
			}
		case 3:
			if let postalCode = textField.text {
				let formattedPostalCode = postalCode.replacingOccurrences(of: " ", with: "")
				self.postalCode = formattedPostalCode
			}
		default:
			break
		}
		
		if let phoneNumber = self.phoneNumber, let street = self.street, let city = self.city, let postalCode = self.postalCode {
			
			if !Format.isValidFor(phoneNumber: phoneNumber) {
				self.nextButton.isEnabled = false
				return
			}
			if !Format.isValidFor(address: street) {
				self.nextButton.isEnabled = false
				return
			}
			if !Format.isValidFor(city: city) {
				self.nextButton.isEnabled = false
				return
			}
			if !Format.isValidFor(postalCode: postalCode) {
				self.nextButton.isEnabled = false
				return
			}
			self.nextButton.isEnabled = true
		}
	}
}

// MARK:- UITableViewDataSource
extension TutorRegistrationInfoVC {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		let cellIndex = indexPath.row
		
		switch cellIndex {
		case 0:
			self.isRatePickerOn = !self.isRatePickerOn
			self.isProvincePickerOn = false
		case 2, 3, 4, 7:
			self.isRatePickerOn = false
			self.isProvincePickerOn = false
		case 5:
			self.isRatePickerOn = false
			self.isProvincePickerOn = !self.isProvincePickerOn
		default:
			return
		}
		self.tableView.reloadRows(at: [indexPath], with: .automatic)
		self.tableView.reloadData()
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let cellIndex = indexPath.row
		switch cellIndex {
		case 1:
			if self.isRatePickerOn {
				self.rateLabel.textColor = UIColor(red:0.13, green:0.66, blue:0.88, alpha:1.0)
				return 216
			} else {
				self.rateLabel.textColor = UIColor(red:0.18, green:0.20, blue:0.20, alpha:1.0)
				return 0
			}
		case 6:
			if self.isProvincePickerOn {
				self.provinceLabel.textColor = UIColor(red:0.13, green:0.66, blue:0.88, alpha:1.0)
				return 216
			} else {
				self.provinceLabel.textColor = UIColor(red:0.18, green:0.20, blue:0.20, alpha:1.0)
				return 0
			}
		default:
			return super.tableView(tableView, heightForRowAt: indexPath)
		}
	}
}

extension TutorRegistrationInfoVC: UIPickerViewDelegate, UIPickerViewDataSource {
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		switch pickerView.tag {
		case 0:
			self.rate = "\(Rate.shared.rates[row])"
			self.rateLabel.text = "$\(Rate.shared.rates[row])"
		default:
			self.province = Province.shared.abbreviations[row]
			self.provinceLabel.text = "\(Province.shared.abbreviations[row])"
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch pickerView.tag {
		case 0:
			return "$\(Rate.shared.rates[row])"
		default:
			return "\(Province.shared.provinces[row])"
		}
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch pickerView.tag {
		case 0:
			return Rate.shared.rates.count
		default:
			return Province.shared.provinces.count
		}
	}
}

// textField methods
extension TutorRegistrationInfoVC: UITextFieldDelegate {
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		self.isRatePickerOn = false
		self.isProvincePickerOn = false
		self.tableView.beginUpdates()
		self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
		self.tableView.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .automatic)
		tableView.endUpdates()
		return true
	}
	
	@IBAction func textFieldEditingChanged(_ sender: Any) {
		let textField = sender as! UITextField
		
		switch textField.tag {
		case 1:
			if let street = textField.text {
				self.street = street
			}
		case 2:
			if let city = textField.text {
				self.city = city
			}
		default:
			break
		}
		
		if let phoneNumber = self.phoneNumber, let street = self.street, let city = self.city, let postalCode = self.postalCode {
			
			if !Format.isValidFor(phoneNumber: phoneNumber) {
				self.nextButton.isEnabled = false
				return
			}
			if !Format.isValidFor(address: street) {
				self.nextButton.isEnabled = false
				return
			}
			if !Format.isValidFor(city: city) {
				self.nextButton.isEnabled = false
				return
			}
			if !Format.isValidFor(postalCode: postalCode) {
				self.nextButton.isEnabled = false
				return
			}
			self.nextButton.isEnabled = true
		}
	}
}

extension TutorRegistrationInfoVC {
	fileprivate func presentAlert(title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}

extension TutorRegistrationInfoVC {
	// presents TutorRegistrationClassesVC
	fileprivate func presentTutorRegistrationClassesVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentProfile", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "TutorRegistrationClassesVC") as! TutorRegistrationClassesVC
		vc.tutorInfoDelegate = self as TutorRegistrationInfoDelegate
		self.navigationController?.pushViewController(vc, animated: true)
	}
}
