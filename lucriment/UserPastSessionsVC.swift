//
//  UserPastSessionsVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-06.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class UserPastSessionsVC: UIViewController {
	
	fileprivate let refreshControl = UIRefreshControl()
	@IBOutlet weak var tableView: UITableView!

	var sessionHistory = [Session]()
	var declinedSessions = [Session]()
	var cancelledSessions = [Session]()
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
		self.tableView.refreshControl = refreshControl
		self.tableView.addSubview(self.refreshControl)
		self.tableView.tableFooterView = UIView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.presentNoNetworkNotification()
		} else {
			self.sessionHistory = [Session]()
			self.declinedSessions = [Session]()
			self.cancelledSessions = [Session]()
			
			DispatchQueue.main.async {
				DatabaseManager.shared.downloadPastSessions(for: .student, id: UserManager.shared.id) { (sessions, error) in
					if let error = error {
						print(error.localizedDescription)
					} else if let sessions = sessions {
						for session in sessions {
							if session.sessionDeclined == true && session.sessionCancelled == false {
								self.declinedSessions.append(session)
							} else if session.sessionDeclined == false && session.sessionCancelled == true {
								self.cancelledSessions.append(session)
							} else {
								// checks if the session is past
								let date = Int(Date().timeIntervalSince1970 * 1_000)
								let sessionDate = Int(session.time.from.day().timeIntervalSince1970 * 1_000)
								if date > sessionDate {
									self.sessionHistory.append(session)
								}
							}
						}
						self.sessionHistory = self.sessionHistory.reversed()
						self.declinedSessions = self.declinedSessions.reversed()
						self.cancelledSessions = self.cancelledSessions.reversed()
						self.tableView.reloadData()
					}
				}
			}
		}
	}
	
	func refresh() {
		self.sessionHistory = [Session]()
		self.declinedSessions = [Session]()
		self.cancelledSessions = [Session]()
		
		DispatchQueue.main.async {
			DatabaseManager.shared.downloadPastSessions(for: .student, id: UserManager.shared.id) { (sessions, error) in
				if let error = error {
					print(error.localizedDescription)
					self.refreshControl.endRefreshing()
				} else if let sessions = sessions {
					for session in sessions {
						if session.sessionDeclined == true {
							self.declinedSessions.append(session)
						} else if session.sessionCancelled == true {
							self.cancelledSessions.append(session)
						} else {
							// checks if the session is past
							let date = Int(Date().timeIntervalSince1970 * 1_000)
							let sessionDate = Int(session.time.from.day().timeIntervalSince1970 * 1_000)
							if date > sessionDate {
								self.sessionHistory.append(session)
							}
						}
					}
					self.sessionHistory = self.sessionHistory.reversed()
					self.declinedSessions = self.declinedSessions.reversed()
					self.cancelledSessions = self.cancelledSessions.reversed()
					self.refreshControl.endRefreshing()
					self.tableView.reloadData()
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

extension UserPastSessionsVC: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "Past Sessions"
		}
		
		if section == 1 {
			return "Declined Sessions"
		}
		
		return "Cancelled Sessions"
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		switch section {
		case 0:
			let count = sessionHistory.count
			if count == 0 {
				return 1
			}
			return count
		case 1:
			let count = declinedSessions.count
			if count == 0 {
				return 1
			}
			return count
		default:
			break
		}
		
		let count = cancelledSessions.count
		if count == 0 {
			return 1
		}
		return count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let section = indexPath.section
		let row = indexPath.row
		
		// Past Sessions
		
		if section == 0 {
			let count = sessionHistory.count
			if count == 0 {
				let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
				cell.textLabel?.text = "No Session History"
				return cell
			}
			
			let cell = self.tableView.dequeueReusableCell(withIdentifier: "SessionCell")! as! SessionCell
			cell.nameLabel.text = self.sessionHistory[row].tutorName
			cell.subjectLabel.text = self.sessionHistory[row].subject
			cell.locationLabel.text = self.sessionHistory[row].location
			
			// dateLabel
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMM d"
			let date = self.sessionHistory[row].time.from
			cell.dateLabel.text = dateFormatter.string(from: date)
			
			// timeLabel
			let timeFormatter = DateFormatter()
			timeFormatter.dateFormat = "h:mm a"
			let from = self.sessionHistory[row].time.from
			let to = self.sessionHistory[row].time.to
			let time = "\(timeFormatter.string(from: from)) - \(timeFormatter.string(from: to))"
			cell.timeLabel.text = time
			
			return cell
		}
		
		// Declined Sessions
		
		if section == 1 {
			let count = declinedSessions.count
			if count == 0 {
				let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
				cell.textLabel?.text = "No Declined Sessions"
				return cell
			}
			let cell = self.tableView.dequeueReusableCell(withIdentifier: "SessionCell")! as! SessionCell
			cell.nameLabel.text = self.declinedSessions[row].tutorName
			cell.subjectLabel.text = self.declinedSessions[row].subject
			cell.locationLabel.text = self.declinedSessions[row].location
			
			// dateLabel
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMM d"
			let date = self.declinedSessions[row].time.from
			cell.dateLabel.text = dateFormatter.string(from: date)
			
			// timeLabel
			let timeFormatter = DateFormatter()
			timeFormatter.dateFormat = "h:mm a"
			let from = self.declinedSessions[row].time.from
			let to = self.declinedSessions[row].time.to
			let time = "\(timeFormatter.string(from: from)) - \(timeFormatter.string(from: to))"
			cell.timeLabel.text = time
			
			return cell
		}
		
		// Cancelled Sessions
		
		let count = cancelledSessions.count
		if count == 0 {
			let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
			cell.textLabel?.text = "No Cancelled Sessions"
			return cell
		}
		
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "SessionCell")! as! SessionCell
		cell.nameLabel.text = self.cancelledSessions[row].tutorName
		cell.subjectLabel.text = self.cancelledSessions[row].subject
		cell.locationLabel.text = self.cancelledSessions[row].location
		
		// dateLabel
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d"
		let date = self.cancelledSessions[row].time.from
		cell.dateLabel.text = dateFormatter.string(from: date)
		
		// timeLabel
		let timeFormatter = DateFormatter()
		timeFormatter.dateFormat = "h:mm a"
		let from = self.cancelledSessions[row].time.from
		let to = self.cancelledSessions[row].time.to
		let time = "\(timeFormatter.string(from: from)) - \(timeFormatter.string(from: to))"
		cell.timeLabel.text = time
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		self.tableView.deselectRow(at: indexPath, animated: true)
		
		let section = indexPath.section
		let row = indexPath.row
		
		if section == 0 {
			
			let count = self.sessionHistory.count
			if count == 0 {
				return
			}
			
			let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentSessions", bundle: nil)
			let vc = mainStoryboard.instantiateViewController(withIdentifier: "UserPastSessionDetailsVC") as! UserPastSessionDetailsVC
			vc.session = self.sessionHistory[row]
			self.navigationController?.pushViewController(vc, animated: true)
		} else if section == 1 {
			
			let count = self.declinedSessions.count
			if count == 0 {
				return
			}
			
			let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentSessions", bundle: nil)
			let vc = mainStoryboard.instantiateViewController(withIdentifier: "UserPastCancelledSessionDetailsVC") as! UserPastCancelledSessionDetailsVC
			vc.session = self.declinedSessions[row]
			self.navigationController?.pushViewController(vc, animated: true)
		} else {
			
			let count = self.cancelledSessions.count
			if count == 0 {
				return
			}
			
			let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentSessions", bundle: nil)
			let vc = mainStoryboard.instantiateViewController(withIdentifier: "UserPastCancelledSessionDetailsVC") as! UserPastCancelledSessionDetailsVC
			vc.session = self.cancelledSessions[row]
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
}

extension UserPastSessionsVC {
	// presents UserSessionDetailsVC
	fileprivate func presentUserSessionDetailsVC() {
		
	}
}
