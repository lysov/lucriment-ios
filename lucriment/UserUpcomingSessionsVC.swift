//
//  UserUpcomingSessionsVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-06.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class UserUpcomingSessionsVC: UIViewController {

	fileprivate let refreshControl = UIRefreshControl()
	@IBOutlet weak var tableView: UITableView!
	
	var sessionRequests = [Session]()
	var confirmedSessions = [Session]()
	
	var parentVC: UserSessionsController! // to show the current session
	
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
			self.sessionRequests = [Session]()
			self.confirmedSessions = [Session]()
			
			DispatchQueue.main.async {
				DatabaseManager.shared.downloadUpcomingSessions(for: .student, id: UserManager.shared.id) { (sessions, error) in
					if let error = error {
						print(error.localizedDescription)
					} else if let sessions = sessions {
						for session in sessions {
							if session.confirmed == false {
								self.sessionRequests.append(session)
							} else {
								self.confirmedSessions.append(session)
								
								let now = Date().timeIntervalSince1970
								let from = session.time.from.timeIntervalSince1970
								let to = session.time.to.timeIntervalSince1970


								if now >= from && now <= to {
									self.parentVC.currentSession = session
									self.parentVC.present(session)
								}
							}
						}
						self.sessionRequests = self.sessionRequests.reversed()
						self.confirmedSessions = self.confirmedSessions.reversed()
						self.tableView.reloadData()
					}
				}
			}
		}
	}
	
	func refresh() {
		self.sessionRequests = [Session]()
		self.confirmedSessions = [Session]()
		
		DispatchQueue.main.async {
			DatabaseManager.shared.downloadUpcomingSessions(for: .student, id: UserManager.shared.id) { (sessions, error) in
				if let error = error {
					print(error.localizedDescription)
					self.refreshControl.endRefreshing()
				} else if let sessions = sessions {
					for session in sessions {
						if session.confirmed == false {
							self.sessionRequests.append(session)
						} else {
							self.confirmedSessions.append(session)
							
							let now = Date().timeIntervalSince1970
							let from = session.time.from.timeIntervalSince1970
							let to = session.time.to.timeIntervalSince1970							
							
							if now >= from && now <= to {
								self.parentVC.currentSession = session
								self.parentVC.present(session)
							}
						}
					}
					self.sessionRequests = self.sessionRequests.reversed()
					self.confirmedSessions = self.confirmedSessions.reversed()
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

extension UserUpcomingSessionsVC: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section == 0 {
			let count = sessionRequests.count
			if count == 0 {
				return 1
			}
			return count
		}
		
		let count = confirmedSessions.count
		if count == 0 {
			return 1
		}
		return count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "Session Requests"
		}
		
		return "Confirmed Sessions"
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let section = indexPath.section
		let row = indexPath.row
		
		// Session Requests
		
		if section == 0 {
			let count = sessionRequests.count
			if count == 0 {
				let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
				cell.textLabel?.text = "No Session Requests"
				return cell
			}
			let cell = self.tableView.dequeueReusableCell(withIdentifier: "SessionCell")! as! SessionCell
			cell.nameLabel.text = self.sessionRequests[row].tutorName
			cell.subjectLabel.text = self.sessionRequests[row].subject
			cell.locationLabel.text = self.sessionRequests[row].location
			
			// dateLabel
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMM d"
			let date = self.sessionRequests[row].time.from
			cell.dateLabel.text = dateFormatter.string(from: date)

			// timeLabel
			let timeFormatter = DateFormatter()
			timeFormatter.dateFormat = "h:mm a"
			let from = self.sessionRequests[row].time.from
			let to = self.sessionRequests[row].time.to
			let time = "\(timeFormatter.string(from: from)) - \(timeFormatter.string(from: to))"
			cell.timeLabel.text = time

			return cell
		}
		
		// Confirmed Sessions
		
		let count = confirmedSessions.count
		if count == 0 {
			let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
			cell.textLabel?.text = "No Confirmed Sessions"
			return cell
		}
		
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "SessionCell")! as! SessionCell
		cell.nameLabel.text = self.confirmedSessions[row].tutorName
		cell.subjectLabel.text = self.confirmedSessions[row].subject
		cell.locationLabel.text = self.confirmedSessions[row].location
		
		// dateLabel
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d"
		let date = self.confirmedSessions[row].time.from
		cell.dateLabel.text = dateFormatter.string(from: date)
		
		// timeLabel
		let timeFormatter = DateFormatter()
		timeFormatter.dateFormat = "h:mm a"
		let from = self.confirmedSessions[row].time.from
		let to = self.confirmedSessions[row].time.to
		let time = "\(timeFormatter.string(from: from)) - \(timeFormatter.string(from: to))"
		cell.timeLabel.text = time
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		self.tableView.deselectRow(at: indexPath, animated: true)
		
		let section = indexPath.section
		let row = indexPath.row
		
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentSessions", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "UserUpcomingSessionDetailsVC") as! UserUpcomingSessionDetailsVC
		
		if section == 0 {
			let count = self.sessionRequests.count
			if count == 0 {
				return
			}
			
			vc.session = self.sessionRequests[row]
			self.navigationController?.pushViewController(vc, animated: true)
		} else {
			
			let count = self.confirmedSessions.count
			if count == 0 {
				return
			}
			
			vc.session = self.confirmedSessions[row]
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
}
