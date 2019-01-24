//
//  SignUpVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-23.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import MBProgressHUD

class SignUpVC: UIViewController, URLDelegate {
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var legalTextView: UITextView!
	
	// views
	@IBOutlet weak var firstNameView: UIView!
	@IBOutlet weak var lastNameView: UIView!
	@IBOutlet weak var emailView: UIView!
	@IBOutlet weak var passwordView: UIView!
	
	// image views
	@IBOutlet weak var firstNameImageView: UIImageView!
	@IBOutlet weak var lastNameImageView: UIImageView!
	@IBOutlet weak var emailImageView: UIImageView!
	@IBOutlet weak var passwordImageView: UIImageView!
	
	// text fields
	@IBOutlet weak var firstNameTextField: AuthenticationTextField!
	@IBOutlet weak var lastNameTextField: AuthenticationTextField!
	@IBOutlet weak var emailTextField: AuthenticationTextField!
	@IBOutlet weak var passwordTextField: AuthenticationTextField!
	
	// buttons
	@IBOutlet weak var facebookSignUpButton: UIButton!
	@IBOutlet weak var googleSignUpButton: UIButton!
	@IBOutlet weak var signUpButton: UIButton!
	
	internal var activityIndicator: MBProgressHUD!
	internal var facebookSignInView: FBSDKLoginButton!
	internal var googleSignInView: GIDSignInButton!
	internal var activeTextField: UITextField!
	
	internal let termsOfUse = URL(string: "https://lucriment.com/tos.html")
	internal let privacyPolicy = URL(string: "https://lucriment.com/privacy.html")
	var url: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
		
		self.configureViews()
		self.configureFacebookSignUpButton()
		self.configureGoogleSignUpButton()
		self.configureSignUpButton()
		self.configureLegalTextView()
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
}

// MARK: - Configuration
// faster transition of bar tint color
extension SignUpVC {
	override func willMove(toParentViewController parent: UIViewController?) {
		self.navigationController?.navigationBar.barTintColor = .white
	}
}

extension SignUpVC: ActivityIndicatorDelegate {
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
extension SignUpVC {
	internal func configureViews() {
		self.firstNameView.layer.cornerRadius = 10
		self.lastNameView.layer.cornerRadius = 10
		self.emailView.layer.cornerRadius = 10
		self.passwordView.layer.cornerRadius = 10
	}
}

// configures buttons
extension SignUpVC: GIDSignInUIDelegate {
	internal func configureFacebookSignUpButton() {
		self.facebookSignUpButton.layer.cornerRadius = 20
		self.facebookSignUpButton.setBackgroundColor(color: UIColor(red:0.23, green:0.35, blue:0.6, alpha:1), forState: .highlighted)
		self.facebookSignInView = FBSDKLoginButton()
		self.facebookSignInView.readPermissions = ["public_profile", "email"]
		self.facebookSignInView.delegate = AuthManager.shared as FBSDKLoginButtonDelegate
	}
	
	internal func configureGoogleSignUpButton() {
		self.googleSignUpButton.layer.cornerRadius = 20
		self.googleSignUpButton.layer.borderWidth = 1
		self.googleSignUpButton.layer.borderColor = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1).cgColor
		self.googleSignUpButton.setBackgroundColor(color: UIColor(red:0.85, green:0.85, blue:0.85, alpha:1), forState: .highlighted)
		GIDSignIn.sharedInstance().uiDelegate = self
		self.googleSignInView = GIDSignInButton()
	}
	
	internal func configureSignUpButton() {
		self.signUpButton.layer.cornerRadius = 20
		self.signUpButton.setBackgroundColor(color: UIColor(red:0.13, green:0.66, blue:0.88, alpha:1), forState: .highlighted)
		self.signUpButton.disable()
	}

	@IBAction func signUpButtonDidPress(_ sender: Any) {
		if let firstName = self.firstNameTextField.text, let lastName = self.lastNameTextField.text, let email = self.emailTextField.text, let password = self.passwordTextField.text {
			guard Format.isValidFor(name: firstName) else {
				self.presentAlert(title: "Invalid First Name", message: "First name should contain only English letter and be less than 20 characters long.")
				return
			}
			guard Format.isValidFor(name: lastName) else {
				self.presentAlert(title: "Invalid Last Name", message: "Last name should contain only English letter and be less than 20 characters long.")
				return
			}
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
					AuthManager.shared.createUser(withEmail: email, password: password, firstName: firstName, lastName: lastName)
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

// configures textView
extension SignUpVC: UITextViewDelegate  {
	internal func configureLegalTextView() {
		let attributedString = NSMutableAttributedString(string: "By signing up, you agree to Lucriment’s Terms and conditions of Use and Privacy Policy.")
		attributedString.addAttribute(NSLinkAttributeName, value: "https://lucriment.com/tos.html", range: NSRange(location: 40, length: 27))
		attributedString.addAttribute(NSLinkAttributeName, value: "https://lucriment.com/privacy.html", range: NSRange(location: 72, length: 14))
		
		self.legalTextView.attributedText = attributedString
		self.legalTextView.textAlignment = .center
		self.legalTextView.textColor = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1)
		self.legalTextView.tintColor = UIColor(red:0.13, green:0.66, blue:0.88, alpha:1)
	}
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		let vc = storyboard?.instantiateViewController(withIdentifier: "LegalVC") as! LegalVC
		vc.delegate = self as URLDelegate
		switch characterRange.length {
		case 27:
			vc.title = "Terms and Conditions of Use"
			self.url = self.termsOfUse
		default:
			vc.title = "Privacy Policy"
			self.url = self.privacyPolicy
		}
		
		self.navigationController?.pushViewController(vc, animated: true)
		return false
	}
}

// keyboard methods
extension SignUpVC {
	internal func registerKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(SignUpVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(SignUpVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
extension SignUpVC: UITextFieldDelegate {
	@IBAction func textFieldEditingChanged(_ sender: Any) {
		
		if let firstNameLength = self.firstNameTextField.text?.characters.count, let lastNameLength = self.lastNameTextField.text?.characters.count, let emailLength = self.emailTextField.text?.characters.count, let passwordLength = self.passwordTextField.text?.characters.count {
			if firstNameLength > 0 && lastNameLength > 0 && emailLength >= 6 && emailLength <= 128 && passwordLength >= 6 && passwordLength <= 128 {
				self.signUpButton.enable()
			} else {
				self.signUpButton.disable()
			}
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		switch textField.tag {
		case 0: self.lastNameTextField.becomeFirstResponder()
		case 1: self.emailTextField.becomeFirstResponder()
		case 2: self.passwordTextField.becomeFirstResponder()
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
		case 0: self.firstNameImageView.image = #imageLiteral(resourceName: "Name Filled")
		case 1: self.lastNameImageView.image = #imageLiteral(resourceName: "Name Filled")
		case 2: self.emailImageView.image = #imageLiteral(resourceName: "Email Filled")
		case 3: self.passwordImageView.image = #imageLiteral(resourceName: "Password Filled")
		default: return
		}
	}
	
	// Change icon when editing ends
	@IBAction func textFieldEditingDidEnd(_ sender: Any) {
		let textField = (sender as! UITextField)
		
		if textField.text == "" {
			switch textField.tag {
			case 0: self.firstNameImageView.image = #imageLiteral(resourceName: "Name")
			case 1: self.lastNameImageView.image = #imageLiteral(resourceName: "Name")
			case 2: self.emailImageView.image = #imageLiteral(resourceName: "Email")
			case 3: self.passwordImageView.image = #imageLiteral(resourceName: "Password")
			default: return
			}
		}
	}
}

// overrides text padding in UITextField
class AuthenticationTextField: UITextField {
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		let insets = UIEdgeInsets.init(top: 0, left: 36, bottom: 0, right: 10)
		return UIEdgeInsetsInsetRect(bounds, insets)
	}
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		let insets = UIEdgeInsets.init(top: 0, left: 36, bottom: 0, right: 10)
		return UIEdgeInsetsInsetRect(bounds, insets)
	}
	
}

// disables button
extension UIButton {
	func disable() {
		self.isEnabled = false
		self.alpha = 0.5
	}
	func enable() {
		self.isEnabled = true
		self.alpha = 1
	}
}
