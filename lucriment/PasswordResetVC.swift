//
//  PasswordResetVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-23.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class PasswordResetVC: UIViewController {

	@IBOutlet weak var scrollView: UIScrollView!
	
	// views
	@IBOutlet weak var emailView: UIView!
	
	// image views
	@IBOutlet weak var emailImageView: UIImageView!
	
	// text fields
	@IBOutlet weak var emailTextField: AuthenticationTextField!
	
	// button
	@IBOutlet weak var sendButton: UIButton!
	
	internal var activeTextField: UITextField!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.configureView()
		self.configureSendButton()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.registerKeyboardNotifications()
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.deRegisterKeyboardNotifications()
	}

}

// configures view
extension PasswordResetVC {
	internal func configureView() {
		self.emailView.layer.cornerRadius = 10
	}
}

// configures buttons
extension PasswordResetVC {
	internal func configureSendButton() {
		self.sendButton.layer.cornerRadius = 20
		self.sendButton.setBackgroundColor(color: UIColor(red:0.23, green:0.35, blue:0.6, alpha:1), forState: .highlighted)
		self.sendButton.disable()
	}
	
	@IBAction func sendButtonDidPress(_ sender: Any) {
		if let email = self.emailTextField.text {
			guard Format.isValidFor(email: email) else {
				self.presentAlert(title: "Invalid Email Address", message: nil)
				return
			}
			if ReachabilityManager.shared().reachabilityStatus == .notReachable {
				self.presentAlert(title: "No Internet Connection", message: "Please check your Internet connection.")
			} else {
				Auth.auth().sendPasswordReset(withEmail: email) { (error) in
					self.presentAlert(title: "Email Reset", message: "An email containing a reset link has been sent to \(email).")
				}
			}
		}
	}
}

extension PasswordResetVC {
	fileprivate func presentAlert(title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}

// keyboard methods
extension PasswordResetVC {
	internal func registerKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(PasswordResetVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(PasswordResetVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
extension PasswordResetVC: UITextFieldDelegate {
	@IBAction func textFieldEditingChanged(_ sender: Any) {
		
		if let emailLength = self.emailTextField.text?.characters.count {
			if emailLength >= 6 && emailLength <= 128 {
				self.sendButton.enable()
			} else {
				self.sendButton.disable()
			}
		}
	}
	
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
