//
//  TutorPastCancelledSessionDetailsVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-08.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class TutorPastCancelledSessionDetailsVC: UITableViewController {
	
	@IBOutlet weak var studentCell: StudentCell!
	@IBOutlet weak var subjectCell: UITableViewCell!
	@IBOutlet weak var timeCell: UITableViewCell!
	@IBOutlet weak var priceCell: UITableViewCell!
	@IBOutlet weak var locationCell: InfoCell!
	
	var session: Session!
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Session Details"
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

extension TutorPastCancelledSessionDetailsVC {
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		let locationIndexPath = IndexPath(row: 4, section: 0)
		
		if locationIndexPath == indexPath {
			return UITableViewAutomaticDimension
		}
		return super.tableView(tableView, heightForRowAt: indexPath)
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
}
