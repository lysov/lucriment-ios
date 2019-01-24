//
//  UserSearchSubjectsVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-16.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

protocol SearchResultsDelegate {
	var searchController: UISearchController! { get set }
	var subjects: [Subject]! { get set }
	var filteredSubjects: [Subject]! { get set }
}

class UserSearchSubjectsVC: UITableViewController {

	// No Search Results
	@IBOutlet weak var backgroundView: UIView!
	
	var delegate: SearchResultsDelegate!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.delegate.subjects = [Subject]()
		self.delegate.filteredSubjects = [Subject]()
		
		self.tableView.tableFooterView = UIView()
		self.setupTableViewBackgroundView()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.showNoNetworkNotification()
		} else {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			DispatchQueue.main.async {
				DatabaseManager.shared.downloadSubjects { (subjects, error) in
					if let error = error {
						print(error.localizedDescription)
					} else {
						if let subjects = subjects {
							self.delegate.subjects = subjects
							self.tableView.reloadData()
							UIApplication.shared.isNetworkActivityIndicatorVisible = false
						}
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
}

extension UserSearchSubjectsVC {
	func searchBarIsEmpty() -> Bool {
		// Returns true if the text is empty or nil
		return self.delegate.searchController.searchBar.text?.isEmpty ?? true
	}
	
	func isFiltering() -> Bool {
		return self.delegate.searchController.isActive && !searchBarIsEmpty()
	}
}

extension UserSearchSubjectsVC {
	
	// MARK: - Table view data source
	
	func setupTableViewBackgroundView() {
		self.tableView.backgroundView = self.backgroundView
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let section = indexPath.section
		let row = indexPath.row
		if isFiltering() {
			self.delegate.searchController.searchBar.text? = self.delegate.filteredSubjects[section].courses[row]
		} else {
			self.delegate.searchController.searchBar.text? = self.delegate.subjects[section].courses[row]
		}

		self.dismiss(animated: true, completion: nil)
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if isFiltering() {
			return self.delegate.filteredSubjects[section].name
		} else {
			return self.delegate.subjects[section].name
		}
		
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if isFiltering() {
			if self.delegate.filteredSubjects.count == 0 {
				self.tableView.separatorStyle = .none
				self.tableView.backgroundView?.isHidden = false
			} else {
				self.tableView.separatorStyle = .singleLine
				self.tableView.backgroundView?.isHidden = true
			}
			return self.delegate.filteredSubjects.count
		} else {
			return self.delegate.subjects.count
			self.tableView.backgroundView?.isHidden = true
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isFiltering() {
			return self.delegate.filteredSubjects[section].courses.count
		} else {
			return self.delegate.subjects[section].courses.count
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = indexPath.section
		let row = indexPath.row
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "subjectCell")!
		if isFiltering() {
			cell.textLabel?.text = self.delegate.filteredSubjects[section].courses[row]
		} else {
			cell.textLabel?.text = self.delegate.subjects[section].courses[row]
		}
		
		return cell
	}
}
