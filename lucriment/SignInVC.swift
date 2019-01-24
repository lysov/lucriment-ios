//
//  SignInVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-23.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import MBProgressHUD

class SignInVC: UIViewController {
	
	@IBOutlet weak var scrollView: UIScrollView!
	
	// views
	@IBOutlet weak var emailView: UIView!
	@IBOutlet weak var passwordView: UIView!
	
	// image views
	@IBOutlet weak var emailImageView: UIImageView!
	@IBOutlet weak var passwordImageView: UIImageView!
	
	// text fields
	@IBOutlet weak var emailTextField: AuthenticationTextField!
	@IBOutlet weak var passwordTextField: AuthenticationTextField!
	
	// buttons
	@IBOutlet weak var facebookSignInButton: UIButton!
	@IBOutlet weak var googleSignInButton: UIButton!
	@IBOutlet weak var signInButton: UIButton!
	
	internal var activityIndicator: MBProgressHUD!
	internal var facebookSignInView: FBSDKLoginButton!
	internal var googleSignInView: GIDSignInButton!
	internal var activeTextField: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.topItem?.title = ""
		
		self.configureViews()
		self.configureFacebookSignInButton()
		self.configureGoogleSignInButton()
		self.configureSignInButton()
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
}

// MARK: - Configuration
// faster transition of bar tint color
extension SignInVC {
	override func willMove(toParentViewController parent: UIViewController?) {
		self.navigationController?.navigationBar.barTintColor = .white
	}
}

extension SignInVC: ActivityIndicatorDelegate {
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
extension SignInVC {
	internal func configureViews() {
		self.emailView.layer.cornerRadius = 10
		self.passwordView.layer.cornerRadius = 10
	}
}

// configures buttons
extension SignInVC: GIDSignInUIDelegate {
	internal func configureFacebookSignInButton() {
		self.facebookSignInButton.layer.cornerRadius = 20
		self.facebookSignInButton.setBackgroundColor(color: UIColor(red:0.23, green:0.35, blue:0.6, alpha:1), forState: .highlighted)
		self.facebookSignInView = FBSDKLoginButton()
		self.facebookSignInView.readPermissions = ["public_profile", "email"]
		self.facebookSignInView.delegate = AuthManager.shared as FBSDKLoginButtonDelegate
	}
	
	internal func configureGoogleSignInButton() {
		self.googleSignInButton.layer.cornerRadius = 20
		self.googleSignInButton.layer.borderWidth = 1
		self.googleSignInButton.layer.borderColor = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1).cgColor
		self.googleSignInButton.setBackgroundColor(color: UIColor(red:0.85, green:0.85, blue:0.85, alpha:1), forState: .highlighted)
		GIDSignIn.sharedInstance().uiDelegate = self
		self.googleSignInView = GIDSignInButton()
	}
	
	internal func configureSignInButton() {
		self.signInButton.layer.cornerRadius = 20
		self.signInButton.setBackgroundColor(color: UIColor(red:0.13, green:0.66, blue:0.88, alpha:1), forState: .highlighted)
		self.signInButton.disable()
	}
	
	@IBAction func signInButtonDidPress(_ sender: Any) {
		if let email = self.emailTextField.text, let password = self.passwordTextField.text {
			guard Format.isValidFor(email: email) else {
				self.presentAlert(title: "Invalid Email Address", message: nil)
				return
			}
			guard Format.isValidFor(password: password) else {
				self.presentAlert(title: "Invalid Password", message: nil)
				return
			}
			if ReachabilityManager.shared().reachabilityStatus == .notReachable {
				self.presentAlert(title: "No Internet Connection", message: "Please check your Internet connection.")
			} else {
				AuthManager.shared.delegate = self as ActivityIndicatorDelegate
				self.displayActivityIndicatorView()
				DispatchQueue.main.async{
					AuthManager.shared.signIn(withEmail: email, password: password)
				}
			}
		}
	}
	
	@IBAction func facebookSignInButtonDidPress(_ sender: Any) {
		AuthManager.shared.delegate = self as ActivityIndicatorDelegate
		self.displayActivityIndicatorView()
		DispatchQueue.main.async{
			self.facebookSignInView.sendActions(for: .touchUpInside)
		}
	}
	
	@IBAction func googleSignInButtonDidPress(_ sender: Any) {
		AuthManager.shared.delegate = self as ActivityIndicatorDelegate
		self.displayActivityIndicatorView()
		DispatchQueue.main.async{
			self.googleSignInView.sendActions(for: .touchUpInside)
		}
	}
}

// keyboard methods
extension SignInVC {
	internal func registerKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(SignInVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(SignInVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
extension SignInVC: UITextFieldDelegate {
	@IBAction func textFieldEditingChanged(_ sender: Any) {
		
		if let emailLength = self.emailTextField.text?.characters.count, let passwordLength = self.passwordTextField.text?.characters.count {
			if emailLength >= 6 && emailLength <= 128 && passwordLength >= 6 && passwordLength <= 128 {
				self.signInButton.enable()
			} else {
				self.signInButton.disable()
			}
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		switch textField.tag {
		case 0: self.passwordTextField.becomeFirstResponder()
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
		case 0: self.emailImageView.image = #imageLiteral(resourceName: "Email Filled")
		case 1: self.passwordImageView.image = #imageLiteral(resourceName: "Password Filled")
		default: return
		}
	}
	
	// Change icon when editing ends
	@IBAction func textFieldEditingDidEnd(_ sender: Any) {
		let textField = (sender as! UITextField)
		
		if textField.text == "" {
			switch textField.tag {
			case 0: self.emailImageView.image = #imageLiteral(resourceName: "Email")
			case 1: self.passwordImageView.image = #imageLiteral(resourceName: "Password")
			default: return
			}
		}
	}
}
