//
//  UserProfileVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-24.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class UserProfileVC: UITableViewController {
	
	// Network Disconnection
	@IBOutlet weak var activityView: UIView!
	@IBOutlet weak var noNetworkConnectionLabel: UILabel!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	// Cells
	@IBOutlet weak var profileImageCell: ProfilePhotoCell!
	@IBOutlet weak var shareAppCell: UITableViewCell!
	@IBOutlet weak var becomeATutorCell: UITableViewCell!
	@IBOutlet weak var settingsCell: UITableViewCell!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
		
		self.setupTableView()
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
					} else {
						self.tableView.reloadData()
					}
					if let isTutor = UserManager.shared.isTutor {
						switch isTutor {
						case true:
							self.becomeATutorCell.textLabel?.text = "Switch to Tutoring"
						case false:
							self.becomeATutorCell.textLabel?.text = "Become a Tutor"
						}
					}
					self.dismissActivityView()
				}
				
				// download profile image
				if let profileImage = UserManager.shared.cashedProfileImage.object(forKey: "profileImage") {
					self.profileImageCell.profilePhotoImageView.image = profileImage
					self.profileImageCell.profilePhotoImageView.isHidden = false
					self.tableView.reloadData()
				} else {
					StorageManager.shared.downloadProfileImageFor(UserManager.shared.id) { (profileImage, error) in
						if let error = error {
							print(error.localizedDescription)
						} else {
							if let profileImage = profileImage {
								UserManager.shared.cashedProfileImage.setObject(profileImage, forKey: "profileImage")
								self.profileImageCell.profilePhotoImageView.image = profileImage
								self.profileImageCell.profilePhotoImageView.isHidden = false
								self.tableView.reloadData()
							}
						}
					}
				}
			}
		}
	}
	
	func refresh(sender: Any) {
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable, self.activityView.isHidden == true {
			self.refreshControl?.endRefreshing()
			self.presentNoNetworkNotification()
		} else if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.refreshControl?.endRefreshing()
		} else {
			DispatchQueue.main.async {
				
				UIApplication.shared.isNetworkActivityIndicatorVisible = true
				
				// download data
				UserManager.shared.refresh { (error) in
					if let error = error {
						print(error.localizedDescription)
					} else {
						self.tableView.reloadData()
						self.refreshControl?.endRefreshing()
						self.dismissActivityView()
					}
				}
				
				// download profile image
				if let profileImage = UserManager.shared.cashedProfileImage.object(forKey: "profileImage") {
					self.profileImageCell.profilePhotoImageView.image = profileImage
					self.profileImageCell.profilePhotoImageView.isHidden = false
					self.tableView.reloadData()
				} else {
					StorageManager.shared.downloadProfileImageFor(UserManager.shared.id) { (profileImage, error) in
						if let error = error {
							print(error.localizedDescription)
						} else {
							if let profileImage = profileImage {
								UserManager.shared.cashedProfileImage.setObject(profileImage, forKey: "profileImage")
								self.profileImageCell.profilePhotoImageView.image = profileImage
								self.profileImageCell.profilePhotoImageView.isHidden = false
								self.tableView.reloadData()
							}
						}
					}
				}
			}
		}
	}
}

// table view
extension UserProfileVC {
	func setupTableView() {
		
		// Setup refreshControl
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
		self.refreshControl?.layoutIfNeeded()
		
		// Set up tableView
		self.tableView.estimatedRowHeight = 44.0
		self.tableView.tableFooterView = UIView()
		
		// Set up Cells
		self.shareAppCell.imageView?.image = #imageLiteral(resourceName: "Share")
		self.becomeATutorCell.imageView?.image = #imageLiteral(resourceName: "Switch")
		self.settingsCell.imageView?.image = #imageLiteral(resourceName: "Settings")
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		switch indexPath.row {
		case 1:
			let url = URL(string: "https://dze74.app.goo.gl/29hQ")
			let shareText = "Lucriment is an online marketplace for tutors."
			let shareItems: [Any] = [shareText, url!]
			let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
			self.present(activityVC, animated: true, completion: nil)
		case 2:
			if let isTutor = UserManager.shared.isTutor {
				switch isTutor {
				case false:
					if ReachabilityManager.shared().reachabilityStatus == .notReachable {
						self.presentNoNetworkNotification()
					} else {
						UserManager.shared.addTutor { (error) in
							if error != nil {
								self.presentNoNetworkNotification()
							} else {
								self.presentTutorRegistrationVC()
							}
						}
					}
				case true:
					UIApplication.shared.isNetworkActivityIndicatorVisible = false
					self.presentTutorBarController()
				}
			}
		case 3:
			self.presentUserProfileSettingsVC()
		default: return
		}
	}
}

// MARK:- Network Disconnection
extension UserProfileVC {
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

extension UserProfileVC {
	fileprivate func presentTutorRegistrationVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentProfile", bundle: nil)
		let navigationController = mainStoryboard.instantiateViewController(withIdentifier: "TutorRegistrationController")
		self.present(navigationController, animated: true, completion: nil)
	}
	
	// presents UserProfileSettingsVC
	fileprivate func presentUserProfileSettingsVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentProfile", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "UserProfileSettingsVC")
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	// presents TutorBarController
	fileprivate func presentTutorBarController() {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		appDelegate.presentTutorBarController()
	}
}
