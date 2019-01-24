//
//  EditTutorProfileVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-10.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import InputMask
import SwiftMessages

protocol EditCoursesDelegate {
	var changedCourses: [String]! { get set }
}

class EditTutorProfileVC: UITableViewController, EditCoursesDelegate {

	@IBOutlet weak var profileCell: EditTutorProfileImageCell!
	@IBOutlet weak var activityView: UIView!
	@IBOutlet weak var noNetworkConnectionLabel: UILabel!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var firstNameTextField: UITextField!
	@IBOutlet weak var lastNameTextField: UITextField!
	@IBOutlet weak var headlineTextView: UITextView!
	@IBOutlet weak var aboutTextView: UITextView!
	@IBOutlet weak var subjectsLabel: UILabel!
	@IBOutlet weak var postalCodeTextField: UITextField!
	
	
	// properties
	fileprivate var initialProfileImage: UIImage!
	fileprivate var changedProfileImage: UIImage!
	fileprivate var initialFirstName: String!
	fileprivate var changedFirstName: String!
	fileprivate var initialLastName: String!
	fileprivate var changedLastName: String!
	fileprivate var initialHeadline: String!
	fileprivate var changedHeadline: String!
	fileprivate var initialAbout: String!
	fileprivate var changedAbout: String!
	fileprivate var initialCourses: [String]!
	var changedCourses: [String]!
	fileprivate var initialRate: Int!
	fileprivate var changedRate: Int!
	fileprivate var initialPostalCode: String!
	fileprivate var changedPostalCode: String!
	
	@IBOutlet weak var rateLabel: UILabel!
	@IBOutlet weak var ratePicker: UIPickerView!
	var isRatePickerOn = false
	var postalCodeMaskedDelegate: MaskedTextFieldDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
		
		self.profileCell.delegate = self
		
		self.tableView.tableFooterView = UIView()
		self.tableView.estimatedRowHeight = 44.0
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(EditTutorProfileVC.refresh), for: .valueChanged)
		self.refreshControl?.layoutIfNeeded()
		
		self.postalCodeMaskedDelegate = MaskedTextFieldDelegate(format: "[___] [___]")
		self.postalCodeMaskedDelegate.listener = self
		self.postalCodeTextField.delegate = self.postalCodeMaskedDelegate
		self.presentActivityView()

    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable, self.activityView.isHidden == false {
			self.presentNoNetworkActivityView()
		}
		else if ReachabilityManager.shared().reachabilityStatus == .notReachable{
			self.showNoNetworkNotification()
		} else if self.initialProfileImage == nil, self.initialFirstName == nil, self.initialLastName == nil, self.initialHeadline == nil, self.initialAbout == nil, self.initialRate == nil, self.initialPostalCode == nil {
				DispatchQueue.main.async {
					// download profile image
					if let profileImage = UserManager.shared.cashedProfileImage.object(forKey: "profileImage") {
						self.profileImage.image = profileImage
						self.profileImage.isHidden = false
						self.tableView.reloadData()
					} else {
						StorageManager.shared.downloadProfileImageFor(UserManager.shared.id) { (profileImage, error) in
							if let error = error {
								print(error.localizedDescription)
							} else {
								if let profileImage = profileImage {
									UserManager.shared.cashedProfileImage.setObject(profileImage, forKey: "profileImage")
									self.profileImage.image = profileImage
									self.profileImage.isHidden = false
									self.tableView.reloadData()
								}
							}
						}
					}
					
					// download data
					UserManager.shared.refresh { (error) in
						if error == nil {
							
							// First Name Cell
							self.firstNameTextField.text = UserManager.shared.firstName
							self.initialFirstName = UserManager.shared.firstName
							
							// Last Name Cell
							self.lastNameTextField.text = UserManager.shared.lastName
							self.initialLastName = UserManager.shared.lastName
							
							// Headline Cell
							if let headline = UserManager.shared.tutorHeadline, headline != "" {
								self.headlineTextView.text = headline
								self.headlineTextView.textColor = UIColor(red:0.18, green:0.20, blue:0.20, alpha:1.0)
								self.initialHeadline = headline
							}
							
							// About Cell
							if let about = UserManager.shared.about, about != "" {
								self.aboutTextView.text = about
								self.aboutTextView.textColor = UIColor(red:0.18, green:0.20, blue:0.20, alpha:1.0)
								self.initialAbout = about
							}
							
							// Subjects Cell
							if self.changedCourses == nil, let subjects = UserManager.shared.subjects {
								
								self.initialCourses = subjects
								var subjectsString = ""
								for subject in subjects {
									subjectsString += subject + ", "
								}
								
								// adds dot to the end of the text
								if subjectsString.characters.count >= 3 {
									let endIndex = subjectsString.index(subjectsString.endIndex, offsetBy: -2)
									subjectsString = subjectsString.substring(to: endIndex)
									subjectsString += "."
								}
								
								self.subjectsLabel.text = subjectsString
							} else {
								self.subjectsLabel.text = ""
							}
							
							// Rate Cell
							self.initialRate = UserManager.shared.rate
							self.rateLabel.text = "$" + String(self.initialRate)
							
							// Rate Picker
							let row = self.initialRate - 15
							self.ratePicker.selectRow(row, inComponent: 0, animated: false)
							
							// Postal Code Cell
							self.initialPostalCode = UserManager.shared.postalCode
							self.postalCodeTextField.text = self.initialPostalCode.substring(from: 0, to: 2) + " " + self.initialPostalCode.substring(from: 3, to: 5)
							
							UIApplication.shared.isNetworkActivityIndicatorVisible = false
							self.tableView.reloadData()
							self.dismissActivityView()
						}
					}
				}
		} else if let changedCourses = self.changedCourses {
			DispatchQueue.main.async {
				
				var subjectsString = ""
				for subject in changedCourses {
					subjectsString += subject + ", "
				}
				
				// adds dot to the end of the text
				if subjectsString.characters.count >= 3 {
					let endIndex = subjectsString.index(subjectsString.endIndex, offsetBy: -2)
					subjectsString = subjectsString.substring(to: endIndex)
					subjectsString += "."
				}
				
				self.subjectsLabel.text = subjectsString
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				self.tableView.reloadData()
			}
		}
	}

	func refresh(sender: Any) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable, self.activityView.isHidden == true {
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.refreshControl?.endRefreshing()
			self.showNoNetworkNotification()
		} else if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.refreshControl?.endRefreshing()
		} else {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			DispatchQueue.main.async{
				// download profile image
				if let profileImage = UserManager.shared.cashedProfileImage.object(forKey: "profileImage") {
					self.profileImage.image = profileImage
					self.profileImage.isHidden = false
					self.tableView.reloadData()
				} else {
					StorageManager.shared.downloadProfileImageFor(UserManager.shared.id) { (profileImage, error) in
						if let error = error {
							print(error.localizedDescription)
						} else {
							if let profileImage = profileImage {
								UserManager.shared.cashedProfileImage.setObject(profileImage, forKey: "profileImage")
								self.profileImage.image = profileImage
								self.profileImage.isHidden = false
								self.tableView.reloadData()
							}
						}
						
					}
				}
				
				// download data
				UserManager.shared.refresh { (error) in
					if error == nil {
						
						// First Name Cell
						self.firstNameTextField.text = UserManager.shared.firstName
						self.initialFirstName = UserManager.shared.firstName
						
						// Last Name Cell
						self.lastNameTextField.text = UserManager.shared.lastName
						self.initialLastName = UserManager.shared.lastName
						
						// Headline Cell
						if let headline = UserManager.shared.tutorHeadline, headline != "" {
							self.headlineTextView.text = headline
							self.headlineTextView.textColor = UIColor(red:0.18, green:0.20, blue:0.20, alpha:1.0)
							self.initialHeadline = headline
						}
						
						// About Cell
						if let about = UserManager.shared.about, about != "" {
							self.aboutTextView.text = about
							self.aboutTextView.textColor = UIColor(red:0.18, green:0.20, blue:0.20, alpha:1.0)
							self.initialAbout = about
						}
						
						// Subjects Cell
						if let subjects = UserManager.shared.subjects, self.changedCourses == nil {
							
							self.initialCourses = subjects
							var subjectsString = ""
							for subject in subjects {
								subjectsString += subject + ", "
							}
							
							// adds dot to the end of the text
							if subjectsString.characters.count >= 3 {
								let endIndex = subjectsString.index(subjectsString.endIndex, offsetBy: -2)
								subjectsString = subjectsString.substring(to: endIndex)
								subjectsString += "."
							}
							
							self.subjectsLabel.text = subjectsString
						} else {
							self.subjectsLabel.text = ""
						}
						
						// Rate Cell
						self.initialRate = UserManager.shared.rate
						self.rateLabel.text = "$" + String(self.initialRate)
						
						// Rate Picker
						let row = self.initialRate - 15
						self.ratePicker.selectRow(row, inComponent: 0, animated: false)
						
						// Postal Code Cell
						self.initialPostalCode = UserManager.shared.postalCode
						self.postalCodeTextField.text = self.initialPostalCode.substring(from: 0, to: 2) + " " + self.initialPostalCode.substring(from: 3, to: 5)
						
						self.dismissActivityView()
						self.refreshControl?.endRefreshing()
						UIApplication.shared.isNetworkActivityIndicatorVisible = false
						self.tableView.reloadData()
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
	
	@IBAction func cancelButtonDidPress(_ sender: Any) {
		if self.changedFirstName != nil, self.changedFirstName != self.initialFirstName {
			self.presentDismissChangesAlert()
		} else if self.changedLastName != nil, self.changedLastName != self.initialFirstName {
			self.presentDismissChangesAlert()
		} else if self.changedAbout != nil, self.changedAbout != self.initialAbout {
			self.presentDismissChangesAlert()
		} else if self.changedHeadline != nil, self.changedHeadline != self.initialHeadline {
			self.presentDismissChangesAlert()
		} else if self.changedCourses != nil, self.changedCourses != self.initialCourses {
			self.presentDismissChangesAlert()
		} else if self.changedRate != nil, self.changedRate != self.initialRate {
			self.presentDismissChangesAlert()
		} else if self.changedPostalCode != nil, self.changedPostalCode != self.initialPostalCode {
			self.presentDismissChangesAlert()
		} else {
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	func presentDismissChangesAlert() {
		let alert = UIAlertController(title: "Dismiss changes?", message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
			self.dismiss(animated: true, completion: nil)
		}))
		self.present(alert, animated: true, completion: nil)
	}
	
	@IBAction func saveButtonDidPress(_ sender: Any) {
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.showNoNetworkNotification()
		} else {
			self.tableView.endEditing(true)
			var values = [String: Any]()
			if self.changedFirstName != nil, self.changedFirstName != self.initialFirstName {
				guard Format.isValidFor(name: self.changedFirstName) else {
					self.presentAlert(title: "Invalid First Name", message: "First name should contain only English letters and be less than 20 characters long.")
					return
				}
				values["firstName"] = self.changedFirstName
			}
			if self.changedLastName != nil, self.changedLastName != self.initialLastName {
				guard Format.isValidFor(name: self.changedLastName) else {
					self.presentAlert(title: "Invalid First Name", message: "First name should contain only English letters and be less than 20 characters long.")
					return
				}
				values["lastName"] = self.changedLastName
			}
			if self.changedFirstName != nil, self.changedFirstName != self.initialFirstName || self.changedLastName != nil, self.changedLastName != self.initialLastName {
				let changedFirstName = self.changedFirstName ?? self.initialFirstName
				let changedLastName = self.changedLastName ?? self.initialLastName
				values["fullName"] = changedFirstName! + " " + changedLastName!
			}
			if self.changedHeadline != nil, self.changedHeadline != self.initialHeadline, self.changedHeadline != "" {
				guard Format.isValidFor(headline: self.changedHeadline) else {
					self.presentAlert(title: "Invalid Headline", message: "Headline should be less than 60 characters long.")
					return
				}
				values["headline"] = self.changedHeadline
			}
			if self.changedAbout != nil, self.changedAbout != self.initialAbout, self.changedAbout != "" {
				guard Format.isValidFor(about: self.changedAbout) else {
					self.presentAlert(title: "Invalid About", message: "Headline should be less than 500 characters long.")
					return
				}
				values["about"] = self.changedAbout
			}
			if self.changedPostalCode != nil, self.changedPostalCode != self.initialPostalCode {
				guard Format.isValidFor(postalCode: self.changedPostalCode) else {
					self.presentAlert(title: "Invalid Postal Code", message: "Postal Code should should contain only English letters and digits and be 6 characters long.")
					return
				}
				values["postalCode"] = self.changedPostalCode
			}
			
			if self.changedRate != nil, self.changedRate != self.initialRate {
				values["rate"] = self.changedRate
			}
			
			if self.changedCourses != nil, self.changedCourses != self.initialCourses {
				guard self.changedCourses.count != 0 else {
					self.presentAlert(title: "You must have at least on subject to teach", message: "Please add subjects")
					return
				}
				
				for subject in self.initialCourses {
					values[subject] = NSNull.init()
				}

				for subject in self.changedCourses {
					values[subject] = true
				}
				values["subjects"] = self.changedCourses
			}
			
			// uploads a profile image in the database
			if let profileImage = self.changedProfileImage {
				UserManager.shared.cashedProfileImage.setObject(self.changedProfileImage, forKey: "profileImage")
				DispatchQueue.main.async {
					UIApplication.shared.isNetworkActivityIndicatorVisible = true
					StorageManager.shared.upload(profileImage: profileImage) { (profileImagePath, error) in
						if error != nil {
							print(error.debugDescription)
							return
						} else {
							if let profileImagePath = profileImagePath {
								if values.count != 0 {
									UserManager.shared.updateCurrent(.tutor, with: values) { (result) in }
								}
								UserManager.shared.updateCurrent(.student, with: ["profileImage": profileImagePath]) { (error) in }
								UserManager.shared.updateCurrent(.tutor, with: ["profileImage": profileImagePath]) { (error) in }
								UIApplication.shared.isNetworkActivityIndicatorVisible = false
							}
						}
					}
				}
			} else {
				if values.count != 0 {
					DispatchQueue.main.async {
						UIApplication.shared.isNetworkActivityIndicatorVisible = true
						UserManager.shared.updateCurrent(.tutor, with: values) { (result) in }
						UIApplication.shared.isNetworkActivityIndicatorVisible = false
					}
				}
			}
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		let cellIndex = indexPath.row
		
		switch cellIndex {
		case 5:
			self.isRatePickerOn = false
			self.presentSubjectsVC()
		case 6:
			self.isRatePickerOn = !self.isRatePickerOn
			self.tableView.reloadRows(at: [indexPath], with: .automatic)
			self.tableView.reloadData()
		case 7:
			return
		default:
			self.isRatePickerOn = false
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let cellIndex = indexPath.row
		
		switch cellIndex {
		case 7:
			if self.isRatePickerOn {
				self.rateLabel.textColor = UIColor(red:0.13, green:0.66, blue:0.88, alpha:1.0)
				return 216
			} else {
				self.rateLabel.textColor = UIColor(red:0.18, green:0.20, blue:0.20, alpha:1.0)
				return 0
			}
		default:
			return UITableViewAutomaticDimension
		}
	}
}

extension EditTutorProfileVC {
	internal func presentAlert(title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}

extension EditTutorProfileVC: UIPickerViewDelegate, UIPickerViewDataSource {
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		self.changedRate = Rate.shared.rates[row]
		self.rateLabel.text = "$\(Rate.shared.rates[row])"
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return "$\(Rate.shared.rates[row])"
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return Rate.shared.rates.count
	}
}

// textView methods
extension EditTutorProfileVC: UITextViewDelegate {
	
	func textViewDidChange(_ textView: UITextView) {
		let currentOffset = tableView.contentOffset
		UIView.setAnimationsEnabled(false)
		tableView.beginUpdates()
		tableView.endUpdates()
		UIView.setAnimationsEnabled(true)
		tableView.setContentOffset(currentOffset, animated: false)
		switch textView.tag {
		case 0:
			self.changedHeadline = textView.text
		default:
			self.changedAbout = textView.text
		}
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		
		switch textView.tag {
		case 0:
			// Combine the textView text and the replacement text to
			// create the updated text string
			let currentText = textView.text as NSString
			let updatedText = currentText.replacingCharacters(in: range, with: text)
			
			// If updated text view will be empty, add the placeholder
			// and set the cursor to the beginning of the text view
			if updatedText.isEmpty {
				
				textView.text = "60 maximum allowed characters."
				self.changedHeadline = ""
				textView.textColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0)
				
				textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
				
				return false
			}
				
				// Else if the text view's placeholder is showing and the
				// length of the replacement string is greater than 0, clear
				// the text view and set its color to black to prepare for
				// the user's entry
			else if textView.textColor == UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0) && !text.isEmpty {
				textView.text = nil
				textView.textColor = .black
			}
			
			return true
		default:
			// Combine the textView text and the replacement text to
			// create the updated text string
			let currentText = textView.text as NSString
			let updatedText = currentText.replacingCharacters(in: range, with: text)
			
			// If updated text view will be empty, add the placeholder
			// and set the cursor to the beginning of the text view
			if updatedText.isEmpty {
				
				textView.text = "500 maximum allowed characters."
				self.changedAbout = ""
				textView.textColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0)
				
				textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
				
				return false
			}
				
				// Else if the text view's placeholder is showing and the
				// length of the replacement string is greater than 0, clear
				// the text view and set its color to black to prepare for
				// the user's entry
			else if textView.textColor == UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0) && !text.isEmpty {
				textView.text = nil
				textView.textColor = .black
			}
			
			return true
		}
		
		
	}
	
	func textViewDidChangeSelection(_ textView: UITextView) {
		if self.view.window != nil {
			if textView.textColor == UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0) {
				textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
			}
		}
	}
}


// textField methods
extension EditTutorProfileVC: UITextFieldDelegate, MaskedTextFieldDelegateListener {
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		switch textField.tag {
		case 0:
			self.changedFirstName = textField.text
		case 1:
			self.changedLastName = textField.text
		default:
			if let postalCode = textField.text {
				let formattedPostalCode = postalCode.replacingOccurrences(of: " ", with: "")
				self.changedPostalCode = formattedPostalCode
			}
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch textField.tag {
		case 0:
			self.lastNameTextField.becomeFirstResponder()
			return true
		case 1:
			self.headlineTextView.becomeFirstResponder()
			return false
		default:
			self.view.endEditing(true)
			return true
		}
	}
	
	func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
		
		
	}
}

extension EditTutorProfileVC {
	func presentActivityView() {
		self.activityView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
		self.activityIndicatorView.color = LUCColor.gray
		self.activityIndicatorView.startAnimating()
		self.activityIndicatorView.isHidden = false
		self.view.addSubview(self.activityView)
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	
	func dismissActivityView() {
		self.noNetworkConnectionLabel.isHidden = false
		self.activityIndicatorView.stopAnimating()
		self.activityView.isHidden = true
		self.activityView.removeFromSuperview()
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
	
	func presentNoNetworkActivityView() {
		self.activityIndicatorView.stopAnimating()
		self.activityIndicatorView.isHidden = true
		self.noNetworkConnectionLabel.isHidden = false
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
}

extension EditTutorProfileVC: TutorProfileImageDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func choosePhoto() {
		let imagePickerController = UIImagePickerController()
		imagePickerController.delegate = self
		
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
			imagePickerController.sourceType = .camera
			self.present(imagePickerController, animated: true, completion: nil)
		}))
		actionSheet.addAction(UIAlertAction(title: "Choose from Photo Library", style: .default, handler: { (action) in
			imagePickerController.sourceType = .photoLibrary
			self.present(imagePickerController, animated: true, completion: nil)
		}))
		actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		self.present(actionSheet, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let image = info[UIImagePickerControllerOriginalImage] as! UIImage
		let compressedProfileImage = image.compress()
		self.changedProfileImage = compressedProfileImage
		
		// Change Profile Photo Cell
		DispatchQueue.main.async {
			self.profileImage.image = self.changedProfileImage
			self.profileImage.isHidden = false
			self.tableView.reloadData()
		}
		
		picker.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}

extension EditTutorProfileVC {
	func presentSubjectsVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "TutorProfile", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "SubjectsVC") as! SubjectsVC
		vc.delegate = self as EditCoursesDelegate
		self.navigationController?.pushViewController(vc, animated: true)
	}
}
