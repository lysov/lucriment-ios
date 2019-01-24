//
//  TutorInfoController.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-19.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class TutorInfoController: UIViewController, AddressDelegate, UserDelegate, TutorDelegate {
	
	// Network Disconnection
	@IBOutlet weak var activityView: UIView!
	@IBOutlet weak var noNetworkConnectionLabel: UILabel!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	@IBOutlet weak var buttonsView: UIView!
	var tutorDelegate: TutorDelegate!
	
	// AddressDelegate
	var address: String!
	
	// UserInfoDelegate
	var user: User!
	
	// TutorDelegate
	var tutor: Tutor!
	var image: UIImage!
	
	var subject: String!
	
	var isSavedToFavourites = false

    override func viewDidLoad() {
        super.viewDidLoad()
		self.buttonsView.layer.cornerRadius = 20
		self.title = "Tutor Info"
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
		self.presentActivityView()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable, self.activityView.isHidden == false {
			self.presentNoNetworkActivityView()
		}
		else if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.presentNoNetworkNotification()
		} else {
			DispatchQueue.main.async {
				
				// download data
				UserManager.shared.refresh { (error) in
					if let error = error {
						print(error.localizedDescription)
						self.dismissActivityView()
					} else {
						if let favourites = UserManager.shared.favourites {
							// there are favorite tutors
							let tutorId = self.tutorDelegate.tutor.id
							// the tutor is in the list of favorite tutors
							if favourites.contains(tutorId) {
								self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Nav Bar Ribbon Filled"), style: .plain, target: self, action: #selector(self.addToSavedTutorsButtonDidPress))
								self.isSavedToFavourites = true
							} else {
								// the tutor isn't in the list of favorite tutors
								self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Nav Bar Ribbon"), style: .plain, target: self, action: #selector(self.addToSavedTutorsButtonDidPress))
								self.isSavedToFavourites = true
							}
						} else {
							self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Nav Bar Ribbon"), style: .plain, target: self, action: #selector(self.addToSavedTutorsButtonDidPress))
							self.isSavedToFavourites = false
						}
						self.dismissActivityView()
					}
				}
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "TutorInfoVC") {
			let vc = segue.destination as! TutorInfoVC
			vc.tutorDelegate = self.tutorDelegate
		}
	}
	
	func addToSavedTutorsButtonDidPress() {
		switch self.isSavedToFavourites {
		case true:
			UserManager.shared.removeFromSaved(self.tutorDelegate.tutor.id) { (error) in
				if let error = error {
					print(error.localizedDescription)
				}
			}
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Nav Bar Ribbon"), style: .plain, target: self, action: #selector(self.addToSavedTutorsButtonDidPress))
			self.isSavedToFavourites = !self.isSavedToFavourites
			print(self.isSavedToFavourites)
		case false:
			UserManager.shared.addToSaved(self.tutorDelegate.tutor.id) { (error) in
				if let error = error {
					print(error.localizedDescription)
				}
			}
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Nav Bar Ribbon Filled"), style: .plain, target: self, action: #selector(self.addToSavedTutorsButtonDidPress))
			self.isSavedToFavourites = !self.isSavedToFavourites
			print(self.isSavedToFavourites)
		}
	}
}

extension TutorInfoController {
	
	// MARK:- Button methods
	
	@IBAction func contactTutorButtonDidPress(_ sender: Any) {
		self.presentUserChatVC()
	}
	
	@IBAction func requestSessionButtonDidPress(_ sender: Any) {
		self.presentSessionRequestVC()
	}
}

extension TutorInfoController {
	// presents UserChatVC
	fileprivate func presentUserChatVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentInbox", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "UserChatVC") as! UserChatVC
		self.user = User(name: self.tutorDelegate.tutor.fullName, id: self.tutorDelegate.tutor.id)
		vc.delegate = self as UserDelegate
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	// presents SessionRequestVC
	fileprivate func presentSessionRequestVC() {
		// check if the student has a credit card
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.presentNoNetworkNotification()
		} else {
			DatabaseManager.shared.checkPaymentMethod { result in
				if result {
					let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentSearch", bundle: nil)
					let vc = mainStoryboard.instantiateViewController(withIdentifier: "SessionRequestVC") as! SessionRequestVC
					self.tutor = self.tutorDelegate.tutor
					vc.delegate = self as TutorDelegate
					vc.subject = self.subject
					self.navigationController?.pushViewController(vc, animated: true)
				} else {
					let alert = UIAlertController(title: "Provide a Payment Method", message: "You can provide a payment method in your profile settings.", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
					self.present(alert, animated: true, completion: nil)
				}
			}
		}
	}
}

// MARK:- Network Disconnection
extension TutorInfoController {
	func presentActivityView() {
		self.activityView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
		self.activityIndicatorView.color = LUCColor.gray
		self.activityIndicatorView.startAnimating()
		self.activityIndicatorView.isHidden = false
		self.view.addSubview(self.activityView)
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	
	func dismissActivityView() {
		self.noNetworkConnectionLabel.isHidden = true
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
	
	func presentNoNetworkNotification() {
		let notificationView: MessageView = try! SwiftMessages.viewFromNib(named: "NoNetworkNotification")
		notificationView.preferredHeight = 35
		var config = SwiftMessages.Config()
		config.duration = .seconds(seconds: 3)
		
		SwiftMessages.show(config: config, view: notificationView)
	}
}
