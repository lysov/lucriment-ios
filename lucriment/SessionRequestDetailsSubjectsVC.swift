//
//  SessionRequestDetailsSubjectsVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-06.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class SessionRequestDetailsSubjectsVC: UITableViewController {
	
	var id: String!
	var subjects = [String]()
	var selectedSubject: String!
	var selectedIndexPath: IndexPath!
	
	var parentVC: SessionRequestDetailsVC!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Choose Subject"
		
		self.tableView.tableFooterView = UIView()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			// present siwft messages no network
			self.showNoNetworkNotification()
		} else {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			DispatchQueue.main.async {
				DatabaseManager.shared.downloadSubjects(for: self.id) { (subjects, error) in
					if let error = error {
						print(error.localizedDescription)
					} else if let subjects = subjects {
						self.subjects = subjects
						
						for (index, subject) in self.subjects.enumerated() {
							if self.selectedSubject == subject {
								self.selectedIndexPath = IndexPath(row: index, section: 0)
							}
						}
						
						self.tableView.reloadData()
					}
				}
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(true)
		self.parentVC.delegate.subject = self.selectedSubject
		self.parentVC.subjectLabel.text = self.selectedSubject
	}
	
	func showNoNetworkNotification() {
		let notificationView: MessageView = try! SwiftMessages.viewFromNib(named: "NoNetworkNotification")
		notificationView.preferredHeight = 35
		var config = SwiftMessages.Config()
		config.duration = .seconds(seconds: 3)
		
		SwiftMessages.show(config: config, view: notificationView)
	}
}

extension SessionRequestDetailsSubjectsVC {

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
        return self.subjects.count
    }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
		
		let row = indexPath.row
		cell.textLabel?.text = self.subjects[row]
		if self.selectedIndexPath == indexPath {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		self.tableView.deselectRow(at: indexPath, animated: true)
		
		self.selectedSubject = self.subjects[indexPath.row]
		self.selectedIndexPath = indexPath
		
		self.tableView.reloadData()
	}
}
