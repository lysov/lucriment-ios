//
//  ChangeTutorInfoVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-08.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class TutorProfileInfoVC: UITableViewController {
	
	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var headlineLabel: TopAlignedLabel!
	@IBOutlet weak var ratingLabel: UILabel!
	@IBOutlet weak var ratingImageView: UIImageView!
	@IBOutlet weak var rateLabel: UILabel!
	@IBOutlet weak var cityLabel: UILabel!
	@IBOutlet weak var aboutLabel: UILabel!
	@IBOutlet weak var subjectsLabel: UILabel!
	
	@IBOutlet weak var activityView: UIView!
	@IBOutlet weak var noNetworkConnectionLabel: UILabel!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(TutorProfileInfoVC.refresh), for: .valueChanged)
		self.refreshControl?.layoutIfNeeded()
		self.tableView.tableFooterView = UIView()
		
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 44
		self.presentActivityView()
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let row = indexPath.row
		switch row {
		case 1, 2:
			return UITableViewAutomaticDimension
		default:
			break
		}
		return super.tableView(tableView, heightForRowAt: indexPath)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable, self.activityView.isHidden == false {
			self.presentNoNetworkActivityView()
		}
		else if ReachabilityManager.shared().reachabilityStatus == .notReachable{
			self.showNoNetworkNotification()
		} else {
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
					} else {
						// tutor cell
						self.nameLabel.text = UserManager.shared.fullName
						if let headline = UserManager.shared.tutorHeadline {
							self.headlineLabel.text = headline
						} else {
							self.headlineLabel.text = "\n\n"
						}
						if let rating = UserManager.shared.rating {
							self.ratingLabel.text = String(rating.rounded(toPlaces: 1))
							self.ratingLabel.isHidden = false
							self.ratingImageView.isHidden = false
						} else {
							self.ratingLabel.text = "0.0"
						}
						self.rateLabel.text = "$" + String(UserManager.shared.rate) + "/h"
						
						// about cell
						if let about = UserManager.shared.about {
							self.aboutLabel.text = String(about)
						} else {
							self.aboutLabel.text = ""
						}
						
						// subjects cell
						if let subjects = UserManager.shared.subjects {
							
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
						
						if let city = UserManager.shared.address {
							self.cityLabel.text = city
						} else {
							self.cityLabel.text = UserManager.shared.postalCode
						}
						
						// Map Cell
						let mapVC = self.childViewControllers.last as! MapVC
						DispatchQueue.main.async {
							mapVC.refresh()
						}
						
						self.dismissActivityView()
						self.tableView.reloadData()
					}
				}
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
					} else {
						// tutor cell
						self.nameLabel.text = UserManager.shared.fullName
						if let headline = UserManager.shared.tutorHeadline {
							self.headlineLabel.text = headline
						} else {
							self.headlineLabel.text = "\n\n"
						}
						if let rating = UserManager.shared.rating {
							self.ratingLabel.text = String(rating.rounded(toPlaces: 1))
							self.ratingLabel.isHidden = false
							self.ratingImageView.isHidden = false
						}
						self.rateLabel.text = "$" + String(UserManager.shared.rate) + "/h"
						
						// about cell
						if let about = UserManager.shared.about {
							self.aboutLabel.text = String(about)
						} else {
							self.aboutLabel.text = " "
						}
						
						// subjects cell
						if let subjects = UserManager.shared.subjects {
							
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
						
						if let city = UserManager.shared.address {
							self.cityLabel.text = city
						} else {
							self.cityLabel.text = UserManager.shared.postalCode
						}
						
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
	
	@IBAction func editButtonDidPress(_ sender: Any) {
		self.presentEditTutorProfileVC()
	}
	fileprivate func presentEditTutorProfileVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "TutorProfile", bundle: nil)
		let navigationController = mainStoryboard.instantiateViewController(withIdentifier: "EditTutorProfileController")
		self.present(navigationController, animated: true, completion: nil)
	}
}

extension TutorProfileInfoVC {
	func presentActivityView() {
		self.activityView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
		self.activityIndicatorView.color = LUCColor.gray
		self.activityIndicatorView.startAnimating()
		self.view.addSubview(self.activityView)
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	
	func dismissActivityView() {
		self.noNetworkConnectionLabel.isHidden = false
		self.activityView.isHidden = true
		self.activityIndicatorView.stopAnimating()
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
