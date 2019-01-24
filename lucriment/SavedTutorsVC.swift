//
//  SavedTutorsVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-21.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class SavedTutorsVC: UITableViewController, TutorDelegate {

	// No Saved Tutors
	@IBOutlet weak var backgroundView: UIView!
	
	// Network Disconnection
	@IBOutlet weak var activityView: UIView!
	@IBOutlet weak var noNetworkConnectionLabel: UILabel!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	// Model
	var tutors = [Tutor]()
	//var images = [String: UIImage?]()
	
	// TutorInfoDelegate
	//var image: UIImage!
	var tutor: Tutor!
	
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
			self.showNoNetworkNotification()
		} else {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			DispatchQueue.main.async {
				DatabaseManager.shared.downloadSavedTutors { (tutors, error) in
					if let error = error {
						print(error.localizedDescription)
						self.dismissActivityView()
					} else {
						if let tutors = tutors {
							
							DispatchQueue.main.async {
								self.tutors = tutors
								self.tableView.reloadData()
								self.dismissActivityView()
							}
						}
					}
				}
			}
		}
	}
}

extension SavedTutorsVC {
	
	func setupTableView() {
		
		// tableView
		self.tableView.backgroundView = self.backgroundView
		self.tableView.backgroundView?.isHidden = true
		self.tableView.tableFooterView = UIView()
	}
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		
		let row = indexPath.row
		
		self.tutor = self.tutors[row]
		
		self.presentTutorInfoController()
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let row = indexPath.row
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "tutorCell", for: indexPath) as! TutorCell
		
		cell.cityLabel.text = self.tutors[row].address ?? self.tutors[row].postalCode
		cell.nameLabel.text = self.tutors[row].fullName
		cell.headlineLabel.text = self.tutors[row].headline ?? ""
		cell.rateLabel.text = "$\(self.tutors[row].rate)/h"
		
		cell.profileImageView.isHidden = true
		cell.profileImageView.image = nil
		// downloads profile image
		if let profileImageReference = self.tutors[row].profileImage {
			let url = URL(string: "\(profileImageReference)")
			
			cell.profileImageView.isHidden = false
			cell.profileImageView.sd_setImage(with: url, placeholderImage: nil)
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if self.tutors.count == 0 {
			self.tableView.separatorStyle = .none
			self.tableView.backgroundView?.isHidden = false
		} else {
			self.tableView.separatorStyle = .singleLine
			self.tableView.backgroundView?.isHidden = true
		}
		
		return self.tutors.count
	}
}

// MARK:- Network Disconnection
extension SavedTutorsVC {
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
	
	func presentNoMessagesView() {
		self.noNetworkConnectionLabel.isHidden = true
		self.activityIndicatorView.stopAnimating()
		self.activityIndicatorView.isHidden = true
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
	
	func showNoNetworkNotification() {
		let notificationView: MessageView = try! SwiftMessages.viewFromNib(named: "NoNetworkNotification")
		notificationView.preferredHeight = 35
		var config = SwiftMessages.Config()
		config.duration = .seconds(seconds: 3)
		
		SwiftMessages.show(config: config, view: notificationView)
	}
}

extension SavedTutorsVC {
	// presents TutorInfoController
	fileprivate func presentTutorInfoController() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentSearch", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "TutorInfoController") as! TutorInfoController
		vc.tutorDelegate = self as TutorDelegate
		vc.address = self.tutor.postalCode
		self.navigationController?.pushViewController(vc, animated: true)
	}
}
