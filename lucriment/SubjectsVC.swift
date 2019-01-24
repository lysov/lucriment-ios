//
//  SubjectsVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-12.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SwiftMessages
import MBProgressHUD

class SubjectsVC: UITableViewController {
	
	var nextButton: UIBarButtonItem!
	fileprivate var activityIndicator: MBProgressHUD!
	fileprivate var selectedIndexPaths: [IndexPath]!
	
	// TutorClassesDelegate implementation
	var courses: [String]!
	var delegate: EditCoursesDelegate!
	var subjects: [Subject]!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.courses = [String]()
		self.subjects = [Subject]()
		self.selectedIndexPaths = [IndexPath]()
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(TutorRegistrationClassesVC.refresh), for: .valueChanged)
		self.refreshControl?.layoutIfNeeded()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// TODO: download images using StorageManager singleton class
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			// present siwft messages no network
			self.showNoNetworkNotification()
		} else {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			DispatchQueue.main.async {
				DatabaseManager.shared.downloadSubjects { (subjects, error) in
					if let error = error {
						print(error.localizedDescription)
					} else {
						if let subjects = subjects {
							self.subjects = subjects
							if let subjects = UserManager.shared.subjects {
								self.courses = subjects
							}
							
							if let changedCourses = self.delegate.changedCourses {
								for course in changedCourses {
									if let indexPath = Subjects.indexPathFor(course, subjects: self.subjects) {
										if !self.selectedIndexPaths.contains(indexPath) {
											self.selectedIndexPaths.append(indexPath)
										}
									}
								}
							} else {
								
								for course in self.courses {
									if let indexPath = Subjects.indexPathFor(course, subjects: self.subjects) {
										self.selectedIndexPaths.append(indexPath)
									}
								}
							}
							self.tableView.reloadData()
							UIApplication.shared.isNetworkActivityIndicatorVisible = false
						}
					}
				}
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if let courses = Subjects.coursesFor(self.selectedIndexPaths, subjects: self.subjects) {
			self.delegate.changedCourses = courses
		}
	}
	
	func refresh(sender: Any) {
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.refreshControl?.endRefreshing()
		} else {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			DispatchQueue.main.async {
				DatabaseManager.shared.downloadSubjects { (subjects, error) in
					if let error = error {
						print(error.localizedDescription)
					} else {
						if let subjects = subjects {
							self.subjects = subjects
							self.tableView.reloadData()
						}
					}
					UIApplication.shared.isNetworkActivityIndicatorVisible = false
					self.refreshControl?.endRefreshing()
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
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.subjects.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.subjects[section].name
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.subjects[section].courses.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "courseCell")!
		let section = indexPath.section
		let row = indexPath.row
		
		let courseName = self.subjects[section].courses[row]
		cell.textLabel?.text = courseName
		if self.selectedIndexPaths.contains(indexPath) {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		if let cell = tableView.cellForRow(at: indexPath) {
			if self.selectedIndexPaths.contains(indexPath)
			{
				cell.accessoryType = .none
				_ = self.selectedIndexPaths.index(of: indexPath).map { self.selectedIndexPaths.remove(at: $0) }
			} else {
				cell.accessoryType = .checkmark
				self.selectedIndexPaths.append(indexPath)
			}
		}
	}
}

extension SubjectsVC {
	internal func displayActivityIndicatorView() -> () {
		self.activityIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
		self.tableView.bringSubview(toFront: self.activityIndicator)
		self.activityIndicator.label.text = "Loading..."
		self.view.isUserInteractionEnabled = false
	}
	
	internal func hideActivityIndicatorView() -> () {
		self.view.isUserInteractionEnabled = true
		DispatchQueue.main.async {
			self.activityIndicator.hide(animated: true)
		}
	}
}
