//
//  FacebookRegistrationVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-30.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class FacebookRegistrationVC: UIViewController {
	
	@IBOutlet weak var scrollView: UIScrollView!
	
	// views
	@IBOutlet weak var emailView: UIView!
	
	// image views
	@IBOutlet weak var emailImageView: UIImageView!
	
	// text fields
	@IBOutlet weak var emailTextField: AuthenticationTextField!
	
	internal var activityIndicator: MBProgressHUD!
	internal var activeTextField: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureViews()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.registerKeyboardNotifications()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.view.endEditing(true)
		self.deRegisterKeyboardNotifications()
	}
	
	@IBAction func cancelButtonDidPress(_ sender: Any) {
		let alert = UIAlertController(title: "Cancel Registration", message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertaction) in
			self.displayActivityIndicatorView()
			AuthManager.shared.delegate = self as ActivityIndicatorDelegate
			AuthManager.shared.deleteFacebookAuthAccount()
			AuthManager.shared.logOut()
		}))
		self.present(alert, animated: true, completion: nil)
	}
	@IBAction func doneButtonButtonDidPress(_ sender: Any) {
		if let email = self.emailTextField.text {
			guard Format.isValidFor(email: email) else {
				self.presentAlert(title: "Invalid Email Address", message: nil)
				return
			}
			if ReachabilityManager.shared().reachabilityStatus == .notReachable {
				self.presentAlert(title: "No Internet Connection", message: "Please check your Internet connection.")
			} else {
				AuthManager.shared.delegate = self as ActivityIndicatorDelegate
				self.displayActivityIndicatorView()
				DispatchQueue.main.async{
					AuthManager.shared.delegate = self as ActivityIndicatorDelegate
					AuthManager.shared.addEmailToAccountCreatedWithFacebook(email: email, completion: {
						self.dismiss(animated: false, completion: nil)
					})
				}
			}
		}
	}
}

// MARK: - Configuration

extension FacebookRegistrationVC: ActivityIndicatorDelegate {
	internal func presentAlert(title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	internal func displayActivityIndicatorView() -> () {
		self.activityIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
		self.activityIndicator.label.text = "Loading..."
		self.view.isUserInteractionEnabled = false
	}
	
	internal func hideActivityIndicatorView() -> () {
		self.view.isUserInteractionEnabled = true
		DispatchQueue.main.async {
			self.activityIndicator.hide(animated: true)
		}
	}
}

// configure views
extension FacebookRegistrationVC {
	internal func configureViews() {
		self.emailView.layer.cornerRadius = 10
	}
}

// keyboard methods
extension FacebookRegistrationVC {
	internal func registerKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(FacebookRegistrationVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(FacebookRegistrationVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	internal func deRegisterKeyboardNotifications() {
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide, object: nil)
	}
	internal func keyboardWillShow(notification: NSNotification) {
		if let activeTextField = activeTextField {
			let info: NSDictionary = notification.userInfo! as NSDictionary
			let value: NSValue = info.value(forKey: UIKeyboardFrameBeginUserInfoKey) as! NSValue
			let keyboardSize: CGSize = value.cgRectValue.size
			let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
			self.scrollView.contentInset = contentInsets
			self.scrollView.scrollIndicatorInsets = contentInsets
			
			// if active text field is hidden by keyboard, scrolls so it's visible
			var aRect: CGRect = self.view.frame
			aRect.size.height -= keyboardSize.height
			let activeTextFieldRect: CGRect? = activeTextField.frame
			let activeTextFieldOrigin: CGPoint? = activeTextFieldRect?.origin
			if (!aRect.contains(activeTextFieldOrigin!)) {
				self.scrollView.scrollRectToVisible(activeTextFieldRect!, animated:true)
			}
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		let contentInsets: UIEdgeInsets = .zero
		self.scrollView.contentInset = contentInsets
		self.scrollView.scrollIndicatorInsets = contentInsets
	}
}

// textField methods
extension FacebookRegistrationVC: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		textField.endEditing(true)
		
		return true
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		self.activeTextField = textField
		self.scrollView.isScrollEnabled = true
	}
	
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		self.activeTextField = nil
		self.scrollView.isScrollEnabled = false
	}
	
	// Change icon when editing begins
	@IBAction func textFieldEditingDidBegin(_ sender: Any) {
		self.emailImageView.image = #imageLiteral(resourceName: "Email Filled")
	}
	
	// Change icon when editing ends
	@IBAction func textFieldEditingDidEnd(_ sender: Any) {
		let textField = (sender as! UITextField)
		
		if textField.text == "" {
			self.emailImageView.image = #imageLiteral(resourceName: "Email")
		}
	}
}
