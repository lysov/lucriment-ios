//
//  AuthManager.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-24.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import FBSDKLoginKit

protocol ActivityIndicatorDelegate {
	func displayActivityIndicatorView() -> Void
	func hideActivityIndicatorView() -> Void
	func presentAlert(title: String, message: String?)
}

protocol EmailForFacebookAccountDelegate {
	func presentFacebookEmailVC()
}

class AuthManager: NSObject {
	private static var authManager: AuthManager!
	
	fileprivate let firebaseDatabaseRef = Database.database().reference()
	fileprivate let firebaseAuth = Auth.auth()
	var delegate: ActivityIndicatorDelegate!
	
	override init() {
		super.init()
		GIDSignIn.sharedInstance().delegate = self
	}
	
	class var shared: AuthManager {
		struct Static {
			static let instance = AuthManager()
		}
		return Static.instance
	}
}

// MARK:- Email
extension AuthManager {
	// creates an email account in Firebase Auth
	func createUser(withEmail: String, password: String, firstName: String, lastName: String) {
		Auth.auth().createUser(withEmail: withEmail, password: password) { (user, error) in
			if let error = error {
				print(error.localizedDescription)
				self.delegate.hideActivityIndicatorView()
				if let errorCode = AuthErrorCode(rawValue: error._code) {
					switch errorCode {
					case .emailAlreadyInUse:
						self.delegate.presentAlert(title: "An account with this email already exists", message: "Try to log in.")
					default:
						break
					}
				} else {
					// unknown error
					self.delegate.presentAlert(title: "Something went wrong, please try again later.", message: nil)
				}
				return
			}
			
			// creates user profile in the database
			let id = user!.uid
			let fullName = "\(firstName) \(lastName)"
			UserManager.shared.addUser(withEmail: withEmail, firstName: firstName, fullName: fullName, id: id, lastName: lastName)
			
			// update user's display name in the database
			let changeRequest = user!.createProfileChangeRequest()
			changeRequest.displayName = fullName
			changeRequest.commitChanges(completion: { error in
				if error != nil {
					print("Error: The user name hasn't been changed in Firebase Auth.")
					self.delegate.presentAlert(title: "Something went wrong, please try again later.", message: nil)
				} else {
					print("The user name has been changed in Firebase Auth.")
					// send confirmation email
					Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
						if error != nil {
							print("Error: Confirmation email hasn't been sent to \(withEmail).")
						} else {
							print("Confirmation email has been sent to \(withEmail).")
						}
					})
				}
				return
			})
			self.delegate.hideActivityIndicatorView()
		}
	}
	
	// signs in to Firebase Auth
	func signIn(withEmail email: String, password: String) {
		let credential = EmailAuthProvider.credential(withEmail: email, password: password)
		Auth.auth().signIn(with: credential) { (user, error) in
			if let error = error {
				self.delegate.hideActivityIndicatorView()
				if let errorCode = AuthErrorCode(rawValue: error._code) {
					switch errorCode {
					case .userNotFound, .wrongPassword, .invalidEmail:
						self.delegate.presentAlert(title: "Unable to Sign In", message: "Either email or password is incorrect.")
					default:
						self.delegate.presentAlert(title: "Something went wrong, please try again later.", message: nil)
					}
				}
				else {
					// unknown error
					self.delegate.presentAlert(title: "Something went wrong, please try again later.", message: nil)
				}
				return
			}
			self.delegate.hideActivityIndicatorView()
		}
	}
}

// MARK:- Google
extension AuthManager: GIDSignInDelegate {
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
		if error != nil {
			// logs out from Google
			if GIDSignIn.sharedInstance().currentUser != nil {
				GIDSignIn.sharedInstance().signOut()
			}
			self.delegate.hideActivityIndicatorView()
			return
		}
		
		let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
		let googleUser = user
		
		// signs in to Firebase
		Auth.auth().signIn(with: credential) { (user, error) in
			if error != nil {
				// logs out from Google
				if GIDSignIn.sharedInstance().currentUser != nil {
					GIDSignIn.sharedInstance().signOut()
				}
				self.delegate.hideActivityIndicatorView()
				// unknown error
				self.delegate.presentAlert(title: "Something went wrong, please try again later.", message: nil)
				return
			}
			
			// checks if user has a profile in the database
			// TODO: check if user has a snapshot under "users"
			UserManager.shared.userExists { (userHasProfile) in
				if !userHasProfile {
					if let withEmail = googleUser?.profile.email, let firstName = googleUser?.profile.givenName, let fullName = googleUser?.profile.name, let id = user?.uid, let lastName = googleUser?.profile?.familyName {
						UserManager.shared.addUser(withEmail: withEmail, firstName: firstName, fullName: fullName, id: id, lastName: lastName)
					}
					print("Profile in database has been created for the user who signed in with Google.")
				} else {
					print("User with Google account already have an account in database.")
				}
				print("Successful Firebase log in using Google.")
				self.delegate.hideActivityIndicatorView()
			}
		}
	}
	
	func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
		self.logOut()
	}
}

// MARK:- Facebook
extension AuthManager: FBSDKLoginButtonDelegate {
	func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
		if error != nil {
			self.delegate.hideActivityIndicatorView()
			self.delegate.presentAlert(title: "Something went wrong, please try again later.", message: nil)
			return
		}
		if result.isCancelled {
			self.delegate.hideActivityIndicatorView()
			return
		}
		
		let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
		
		// signs in to Firebase
		Auth.auth().signIn(with: credential) { (user, error) in
			if let error = error {
				// logs out from Facebook
				if (FBSDKAccessToken.current() != nil) {
					FBSDKLoginManager().logOut()
					
					// clears out the profile and token
					FBSDKAccessToken.setCurrent(nil)
					FBSDKProfile.setCurrent(nil)
				}
				self.delegate.hideActivityIndicatorView()
				if let errorCode = AuthErrorCode(rawValue: error._code) {
					switch errorCode {
					case .accountExistsWithDifferentCredential:
						self.delegate.presentAlert(title: "The email associated with this Facebook account is already registered.", message: nil)
					default:
						break
					}
				} else {
					// unknown error
					self.delegate.presentAlert(title: "Something went wrong, please try again later.", message: nil)
				}
				return
			}
			
			// checks if facebook account has an email
			if user?.email == nil {
				self.delegate.hideActivityIndicatorView()
				// TODO
				//self.delegate.presentFacebookEmailRegistration()
				return
			}
			
			// checks if user has a profile in the database
			// TODO: check if user has a snapshot under "users"
			UserManager.shared.userExists { (userHasProfile) in
				if !userHasProfile {
					if let email = user?.email, let firstName = user?.displayName?.components(separatedBy: " ")[0], let fullName = user?.displayName, let id = user?.uid, let lastName = user?.displayName?.components(separatedBy: " ")[1] {
						UserManager.shared.addUser(withEmail: email, firstName: firstName, fullName: fullName, id: id, lastName: lastName)
					}
					print("Profile in database has been created for the user who signed in with Facebook.")
				} else {
					print("User with Facebook account already have an account in database.")
				}
				print("Successful Firebase log in using Google.")
				self.delegate.hideActivityIndicatorView()
			}
		}
	}
	
	func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
		return true
	}
	
	func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
	}
	
	// adds account to an account created with Facebook
	func addEmailToAccountCreatedWithFacebook(email: String, completion: @escaping () -> ()) {
		if let user = Auth.auth().currentUser {
			user.updateEmail(to: email, completion: { error in
				if let error = error {
					// logs out from Facebook
					if (FBSDKAccessToken.current() != nil) {
						FBSDKLoginManager().logOut()
						
						// clears out the profile and token
						FBSDKAccessToken.setCurrent(nil)
						FBSDKProfile.setCurrent(nil)
					}
					self.delegate.hideActivityIndicatorView()
					if let errorCode = AuthErrorCode(rawValue: error._code) {
						switch errorCode {
						case .emailAlreadyInUse:
							self.delegate.presentAlert(title: "An account with this email already exists", message: "Try to log in.")
						default:
							break
						}
					} else {
						// unknown error
						self.delegate.presentAlert(title: "Something went wrong, please try again later.", message: nil)
					}
					return
				}else {
					print("The user name has been changed in Firebase Auth.")
					// sends email confirmation
					Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
						if error != nil {
							print("Confirmation email hasn't been sent to \(email).")
						} else {
							print("Confirmation email has been sent to \(email).")
						}
					})
					// checks for user profile in database
					// TODO: check if user has a snapshot under "users"
					UserManager.shared.userExists { (userHasProfile) in
						print("Facebook user has an account in database: \(userHasProfile)")
						if !userHasProfile {
							let id = user.uid
							if let firstName = user.displayName?.components(separatedBy: " ")[0], let fullName = user.displayName, let lastName = user.displayName?.components(separatedBy: " ")[1] {
								UserManager.shared.addUser(withEmail: email, firstName: firstName, fullName: fullName, id: id, lastName: lastName)
							}
							print("Profile in database has been created for the user who signed in with Facebook.")
						} else {
							print("User with Facebook account already have an account in database.")
						}
					}
					// success
					if self.delegate != nil {
						self.delegate.hideActivityIndicatorView()
						completion()
					}
				}
			})
		}
	}
}

extension AuthManager {
	// Logs out of Firebase Auth
	func logOut() {
		do {
			try self.firebaseAuth.signOut()
		} catch _ as NSError {
			self.delegate.hideActivityIndicatorView()
			self.delegate.presentAlert(title: "Something went wrong, please try again later.", message: nil)
			return
		}
		
		// checks if the user signed in with Facebook
		if (FBSDKAccessToken.current() != nil) {
			// logs out of facebook
			let manager = FBSDKLoginManager()
			manager.logOut()
			
			// clears out the profile and token
			FBSDKAccessToken.setCurrent(nil)
			FBSDKProfile.setCurrent(nil)
		}
		
		// checks if the user signed in with Google
		if GIDSignIn.sharedInstance() != nil {
			GIDSignIn.sharedInstance().signOut()
		}
		
		// removes profile image from cache
		UserManager.shared.cashedProfileImage.removeAllObjects()
		
		print("Successful Auth account log out.")
		self.delegate.hideActivityIndicatorView()
	}
	
	func deleteFacebookAuthAccount() {
		// checks if the user signed in with Facebook
		if (FBSDKAccessToken.current() != nil) {
			// logs out of facebook
			FBSDKLoginManager().logOut()
			
			// clears out the profile and token
			FBSDKAccessToken.setCurrent(nil)
			FBSDKProfile.setCurrent(nil)
		}
		
		// checks if the user signed in with Google
		if GIDSignIn.sharedInstance() != nil {
			GIDSignIn.sharedInstance().signOut()
		}
		
		Auth.auth().currentUser?.delete { error in
			if error != nil {
				print("Error: The user hasn't been deleted from Firebase Auth.")
			} else {
				print("The user has been successfully deleted from Firebase Auth.")
			}
		}
	}
}
