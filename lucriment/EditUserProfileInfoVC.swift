//
//  EditUserInfoVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-31.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SwiftMessages
import MBProgressHUD
import FirebaseAuth

class EditUserProfileInfoVC: UITableViewController {
	
	@IBOutlet weak var profileImageCell: EditUserProfileImageCell!
	@IBOutlet weak var activityView: UIView!
	@IBOutlet weak var noNetworkConnectionLabel: UILabel!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var firstNameTextField: UITextField!
	@IBOutlet weak var lastNameTextField: UITextField!
	@IBOutlet weak var headlineTextView: UITextView!
	
	
	@IBOutlet weak var doneButton: UIBarButtonItem!
	fileprivate var activityIndicator: MBProgressHUD!
	
	fileprivate var initialProfileImage: UIImage!
	fileprivate var changedProfileImage: UIImage!
	fileprivate var initialFirstName: String!
	fileprivate var changedFirstName: String!
	fileprivate var initialLastName: String!
	fileprivate var changedLastName: String!
	fileprivate var initialHeadline: String!
	fileprivate var changedHeadline: String!
	
	fileprivate var values = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.profileImageCell.delegate = self
		
		self.tableView.tableFooterView = UIView()
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 44.0
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(EditUserProfileInfoVC.refresh), for: .valueChanged)
		self.refreshControl?.layoutIfNeeded()
		
		self.presentActivityView()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable, self.activityView.isHidden == false {
			self.presentNoNetworkActivityView()
		}
		else if ReachabilityManager.shared().reachabilityStatus == .notReachable{
			self.showNoNetworkNotification()
		} else {
			if self.initialProfileImage == nil, self.initialFirstName == nil, self.initialLastName == nil, self.initialHeadline == nil {
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
						if let error = error {
							print(error.localizedDescription)
						}
						
						// First Name Cell
						self.firstNameTextField.text = UserManager.shared.firstName
						self.initialFirstName = UserManager.shared.firstName
						
						// Last Name Cell
						self.lastNameTextField.text = UserManager.shared.lastName
						self.initialLastName = UserManager.shared.lastName
						
						// Headline Cell
						if let headline = UserManager.shared.headline, headline != "" {
							self.headlineTextView.text = headline
							self.headlineTextView.textColor = UIColor(red:0.18, green:0.20, blue:0.20, alpha:1.0)
							self.initialHeadline = headline
						} else {
							self.initialHeadline = ""
						}
						UIApplication.shared.isNetworkActivityIndicatorVisible = false
						self.tableView.reloadData()
						self.dismissActivityView()
					}
				}
			}
		}
	}
	
	func refresh(sender: Any) {
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable, self.activityView.isHidden == true {
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.refreshControl?.endRefreshing()
			self.showNoNetworkNotification()
		} else if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.refreshControl?.endRefreshing()
		} else {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			// download profile image
			DispatchQueue.main.async {
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
					if let error = error {
						print(error.localizedDescription)
					}
					
					// First Name Cell
					self.firstNameTextField.text = UserManager.shared.firstName
					self.initialFirstName = UserManager.shared.firstName
					
					// Last Name Cell
					self.lastNameTextField.text = UserManager.shared.lastName
					self.initialLastName = UserManager.shared.lastName
					
					// Headline Cell
					if let headline = UserManager.shared.headline, headline != "" {
						self.headlineTextView.text = headline
						self.headlineTextView.textColor = UIColor(red:0.18, green:0.20, blue:0.20, alpha:1.0)
						self.initialHeadline = headline
					} else {
						self.initialHeadline = ""
					}
					
					self.dismissActivityView()
					UIApplication.shared.isNetworkActivityIndicatorVisible = false
					self.refreshControl?.endRefreshing()
					self.tableView.reloadData()
				}
			}
		}
	}
	
	func showNoNetworkNotification() {
		let notificationView: MessageView = try! SwiftMessages.viewFromNib(named: "NoNetworkNotification")
		//let notificationView = MessageView.viewFromNib(layout: .CenteredView)
		notificationView.preferredHeight = 35
		var config = SwiftMessages.Config()
		config.duration = .seconds(seconds: 3)
		
		SwiftMessages.show(config: config, view: notificationView)
	}
	
	
	@IBAction func cancelButtonDidPress(_ sender: Any) {
		if self.changedFirstName != nil, self.changedFirstName != self.initialFirstName {
			let alert = UIAlertController(title: "Dismiss changes?", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
				self.dismiss(animated: true, completion: nil)
			}))
			self.present(alert, animated: true, completion: nil)
		} else if self.changedLastName != nil, self.changedLastName != self.initialLastName {
			let alert = UIAlertController(title: "Dismiss changes?", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
				self.dismiss(animated: true, completion: nil)
			}))
			self.present(alert, animated: true, completion: nil)
		} else if self.changedHeadline != nil, self.changedHeadline != self.initialHeadline {
			let alert = UIAlertController(title: "Dismiss changes?", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
				self.dismiss(animated: true, completion: nil)
			}))
			self.present(alert, animated: true, completion: nil)
		} else {
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	@IBAction func doneButtonDidPress(_ sender: Any) {
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.showNoNetworkNotification()
		} else {
			self.tableView.endEditing(true)

			if self.changedFirstName != nil, self.changedFirstName != self.initialFirstName {
				guard Format.isValidFor(name: changedFirstName) else {
					self.presentAlert(title: "Invalid First Name", message: "First name should contain only English letters and be less than 20 characters long.")
					return
				}
				self.values["firstName"] = self.changedFirstName
			}
			if self.changedFirstName != nil, self.changedFirstName != self.initialFirstName || self.changedLastName != nil, self.changedLastName != self.initialLastName {
				let changedFirstName = self.changedFirstName ?? self.initialFirstName
				let changedLastName = self.changedLastName ?? self.initialLastName
				values["fullName"] = changedFirstName! + " " + changedLastName!
			}
			if self.changedLastName != nil, self.changedLastName != self.initialLastName {
				guard Format.isValidFor(name: changedLastName) else {
					self.presentAlert(title: "Invalid First Name", message: "First name should contain only English letters and be less than 20 characters long.")
					return
				}
				self.values["lastName"] = self.changedLastName
			}
			if self.changedHeadline != nil, self.changedHeadline != self.initialHeadline, self.changedHeadline != "" {
				guard Format.isValidFor(headline: changedHeadline) else {
					self.presentAlert(title: "Invalid Headline", message: "Headline should be less than 60 characters long.")
				return
				}
				self.values["headline"] = self.changedHeadline
			}
			
			if self.changedProfileImage != nil {
				UserManager.shared.cashedProfileImage.setObject(self.changedProfileImage, forKey: "profileImage")
				DispatchQueue.main.async {
					UIApplication.shared.isNetworkActivityIndicatorVisible = true
					StorageManager.shared.upload(profileImage: self.changedProfileImage) { (profileImagePath, error) in
						if let error = error {
							print(error.localizedDescription)
						} else {
							if let profileImagePath = profileImagePath {
								// sets the path to that image in the user and the tutor profile
								if UserManager.shared.isTutor {
									UserManager.shared.updateCurrent(.student, with: ["profileImage": profileImagePath]) { (error) in }
									UserManager.shared.updateCurrent(.tutor, with: ["profileImage": profileImagePath]) { (error) in }
								}
									// sets the path to that image in the user profile
								else {
									self.values["profileImage"] = profileImagePath
									UserManager.shared.updateCurrent(.student, with: self.values) { (error) in
										if let error = error {
											print(error.localizedDescription)
										} else {
											UserManager.shared.updateCurrent(.student, with: self.values) { (result) in
												UIApplication.shared.isNetworkActivityIndicatorVisible = false
											}
										}
									}
								}
							}
						}
					}
				}
			} else {
				if self.values.count != 0 {
					DispatchQueue.main.async {
						UIApplication.shared.isNetworkActivityIndicatorVisible = true
						UserManager.shared.updateCurrent(.student, with: self.values) { (result) in
							UIApplication.shared.isNetworkActivityIndicatorVisible = false
						}
					}
				}
			}
			self.dismiss(animated: true, completion: nil)
		}
	}
}

// MARK: - Table View
extension EditUserProfileInfoVC {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
}

// textView methods
extension EditUserProfileInfoVC: UITextViewDelegate {
	
	func textViewDidChange(_ textView: UITextView) {
		let currentOffset = tableView.contentOffset
		UIView.setAnimationsEnabled(false)
		tableView.beginUpdates()
		tableView.endUpdates()
		UIView.setAnimationsEnabled(true)
		tableView.setContentOffset(currentOffset, animated: false)
		self.changedHeadline = textView.text
		
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		
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
extension EditUserProfileInfoVC: UITextFieldDelegate {
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		switch textField.tag {
		case 0:
			self.changedFirstName = textField.text
		default:
			self.changedLastName = textField.text
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch textField.tag {
		case 0:
			self.lastNameTextField.becomeFirstResponder()
			return true
		default:
			self.headlineTextView.becomeFirstResponder()
			return false
		}
	}
}

extension EditUserProfileInfoVC {
	internal func presentAlert(title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}

extension EditUserProfileInfoVC: UserProfileImageDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

extension EditUserProfileInfoVC {
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
