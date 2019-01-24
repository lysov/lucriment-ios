//
//  TutorEarningsVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-09.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class TutorEarningsVC: UITableViewController {
	
	var earnings = [Earning]()

    override func viewDidLoad() {
        super.viewDidLoad()

		// Setup refreshControl
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
		self.refreshControl?.layoutIfNeeded()
		
		self.tableView.tableFooterView = UIView()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.presentNoNetworkNotification()
		} else {
			DispatchQueue.main.async {
				
				let id = UserManager.shared.id!
				
				DatabaseManager.shared.downloadEarnings(for: id) { (earnings, error) in
					if let error = error {
						print(error.localizedDescription)
					} else if let earnings = earnings {
						self.earnings = earnings
						self.tableView.reloadData()
					}
				}
			}
		}
	}
	
	func refresh() {
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.refreshControl?.endRefreshing()
			self.presentNoNetworkNotification()
		} else {
			DispatchQueue.main.async {
				
				let id = UserManager.shared.id!
				
				DatabaseManager.shared.downloadEarnings(for: id) { (earnings, error) in
					if let error = error {
						print(error.localizedDescription)
					} else if let earnings = earnings {
						self.earnings = earnings
						self.refreshControl?.endRefreshing()
						self.tableView.reloadData()
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

// MARK: - Table view data source
extension TutorEarningsVC {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.earnings.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let row = indexPath.row
		
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "EarningsCell") as! EarningsCell
		
		// name
		cell.studentNameLabel.text = self.earnings[row].studentName
		
		// price
		cell.priceLabel.text = "$\(self.earnings[row].price)"
		
		// date
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "E, MMM d"
		let dateString = dateFormatter.string(from: self.earnings[row].date)
		cell.dateLabel.text = dateString
		
		// duration
		cell.timeLabel.text = "\(self.earnings[row].sessionDuration) min"
		
		return cell
	}
	
}
