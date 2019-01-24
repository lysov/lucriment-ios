//
//  ChangePasswordVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-01.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import ReachabilitySwift
import MBProgressHUD

class ChangePasswordVC: UIViewController {

	@IBOutlet weak var doneButton: UIBarButtonItem!
	@IBOutlet weak var scrollView: UIScrollView!
	
	// views
	@IBOutlet weak var oldPasswordView: UIView!
	@IBOutlet weak var newPasswordView: UIView!
	@IBOutlet weak var confirmNewPasswordView: UIView!
	
	// image views
	@IBOutlet weak var oldPasswordImageView: UIImageView!
	@IBOutlet weak var newPasswordImageView: UIImageView!
	@IBOutlet weak var confirmNewPasswordImageView: UIImageView!
	
	// text fields
	@IBOutlet weak var oldPasswordTextField: AuthenticationTextField!
	@IBOutlet weak var newPasswordTextField: AuthenticationTextField!
	@IBOutlet weak var confirmNewPasswordTextField: AuthenticationTextField!

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
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.view.endEditing(true)
		self.deRegisterKeyboardNotifications()
	}
	
	@IBAction func cancelButtonDidPress(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func doneButtonDidPress(_ sender: Any) {
		// update the password
	}
}

extension ChangePasswordVC: ActivityIndicatorDelegate {
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
extension ChangePasswordVC {
	func configureViews() {
		self.oldPasswordView.layer.cornerRadius = 10
		self.newPasswordView.layer.cornerRadius = 10
		self.confirmNewPasswordView.layer.cornerRadius = 10
	}
}

// keyboard methods
extension ChangePasswordVC {
	internal func registerKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(ChangePasswordVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ChangePasswordVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
extension ChangePasswordVC: UITextFieldDelegate {
	@IBAction func textFieldEditingChanged(_ sender: Any) {
		
		if let oldPassword = self.oldPasswordTextField.text, let newPassword = self.newPasswordTextField.text, let confirmNewPassword = self.confirmNewPasswordTextField.text {
			if oldPassword.characters.count >= 6, oldPassword.characters.count <= 128, newPassword.characters.count >= 6, newPassword.characters.count <= 128, newPassword == confirmNewPassword {
				self.doneButton.isEnabled = true
			} else {
				self.doneButton.isEnabled = false
			}
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		switch textField.tag {
		case 0: self.newPasswordTextField.becomeFirstResponder()
		case 1: self.confirmNewPasswordTextField.becomeFirstResponder()
		default: textField.endEditing(true)
		}
		
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
		let textField = (sender as! UITextField)
		
		switch textField.tag {
		case 0: self.oldPasswordImageView.image = #imageLiteral(resourceName: "Password Filled")
		case 1: self.newPasswordImageView.image = #imageLiteral(resourceName: "Password Filled")
		case 2: self.confirmNewPasswordImageView.image = #imageLiteral(resourceName: "Password Filled")
		default: return
		}
	}
	
	// Change icon when editing ends
	@IBAction func textFieldEditingDidEnd(_ sender: Any) {
		let textField = (sender as! UITextField)
		
		if textField.text == "" {
			switch textField.tag {
			case 0: self.oldPasswordImageView.image = #imageLiteral(resourceName: "Password")
			case 1: self.newPasswordImageView.image = #imageLiteral(resourceName: "Password")
			case 2: self.confirmNewPasswordImageView.image = #imageLiteral(resourceName: "Password")
			default: return
			}
		}
	}
}
