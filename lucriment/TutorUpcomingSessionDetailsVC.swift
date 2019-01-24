//
//  TutorUpcomingSessionDetailsVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-08.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class TutorUpcomingSessionDetailsVC: UITableViewController, UserDelegate {
	
	@IBOutlet weak var studentCell: StudentCell!
	@IBOutlet weak var subjectCell: UITableViewCell!
	@IBOutlet weak var timeCell: UITableViewCell!
	@IBOutlet weak var priceCell: UITableViewCell!
	@IBOutlet weak var locationCell: InfoCell!
	
	var session: Session!
	
	// UserInfoDelegate
	var user: User!
	var image: UIImage!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Session Request Details"
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
		
		self.setupTableView()
		self.tableView.reloadData()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.presentNoNetworkNotification()
		} else {
			DispatchQueue.main.async {
				
				let id = self.session.studentId
				
				DatabaseManager.shared.downloadStudent(id: id) { (student, error) in
					if let error = error {
						print(error.localizedDescription)
					} else if let student = student {
						
						self.studentCell.nameLabel.text = student.fullName
						self.studentCell.headlineLabel.text = student.headline ?? "\n\n"
						if let rating = student.rating {
							self.studentCell.ratingLabel.text = "\(rating.rounded(toPlaces: 1))"
						}
						
						// download student profile image cell
						StorageManager.shared.downloadProfileImageFor(student.id) { (image, error)  in
							if let error = error {
								print(error.localizedDescription)
							} else {
								self.studentCell.profileImageView.image = image
								self.studentCell.profileImageView.isHidden = false
							}
						}
					}
				}
			}
		}
	}
	
	func presentNoNetworkNotification() {
		let notificationView: MessageView = try! SwiftMessages.viewFromNib(named: "NoNetworkNotification")
		notificationView.preferredHeight = 35
		var config = SwiftMessages.Config()
		config.duration = .seconds(seconds: 3)
		
		SwiftMessages.show(config: config, view: notificationView)
	}
	
}

extension TutorUpcomingSessionDetailsVC {
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		let section = indexPath.section
		let row = indexPath.row
		
		
		if section == 1 {
			if row == 1 {
				// check if the session can be refunded
				let now = Date().timeIntervalSince1970
				
				let from = self.session.time.from.timeIntervalSince1970
				
				let timeLeft = from - now
				let twentyFourHoursInSeconds = 24.0 * 3_600.0
				if ( timeLeft - twentyFourHoursInSeconds ) < 0 {
					return 0
				}
			}
		}
		
		let locationIndexPath = IndexPath(row: 4, section: 0)
		
		if locationIndexPath == indexPath {
			return UITableViewAutomaticDimension
		}
		return super.tableView(tableView, heightForRowAt: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		self.tableView.deselectRow(at: indexPath, animated: true)
		
		let row = indexPath.row
		let section = indexPath.section
		
		if section == 1 {
			
			// contact tutor
			if row == 0 {
				self.presentUserChatVC()
			}
				
				// cancel session
			else {
				let alert = UIAlertController(title: "Cancel session?", message: nil, preferredStyle: .alert)
				
				alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (UIAlertAction) in
					self.cancelSession()
				}))
				alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
				self.present(alert, animated: true, completion: nil)
			}
		}
	}
	
	func setupTableView() {
		
		// Set up cells
		
		// subjectCell
		self.subjectCell.detailTextLabel?.text = self.session.subject
		
		// timeCell
		let dayFormatter = DateFormatter()
		dayFormatter.dateFormat = "MMM d"
		let timeFormatter = DateFormatter()
		timeFormatter.dateFormat = "h:mm a"
		
		let date = dayFormatter.string(from: self.session.time.from.day())
		let from = timeFormatter.string(from: self.session.time.from)
		let to = timeFormatter.string(from: self.session.time.to)
		
		self.timeCell.detailTextLabel?.text = "\(date), \(from) - \(to)"
		
		// priceCell
		self.priceCell.detailTextLabel?.text = "\(self.session.price)"
		
		// locationCell
		self.locationCell.cellText?.text = "\(self.session.location)"
		
	}
	
	func cancelSession() {
		
		DatabaseManager.shared.cancel(session) {
			let alert = UIAlertController(title: "Session has been successfully cancelled", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
				self.navigationController?.popToRootViewController(animated: true)
			}))
			self.present(alert, animated: true, completion: nil)
		}
	}
}

extension TutorUpcomingSessionDetailsVC {
	
	// presents UserChatVC
	fileprivate func presentUserChatVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "TutorInbox", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "TutorChatVC") as! TutorChatVC
		self.user = User(name: self.session.studentName, id: self.session.studentId)
		self.image = self.studentCell.imageView?.image
		vc.delegate = self as UserDelegate
		
		self.navigationController?.pushViewController(vc, animated: true)
	}
}
