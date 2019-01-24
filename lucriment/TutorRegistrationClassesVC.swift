//
//  TutorRegistrationClassesVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-04.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SwiftMessages
import MBProgressHUD

protocol TutorCoursesDelegate {
	var courses: [String]! { get }
}

class TutorRegistrationClassesVC: UITableViewController, TutorCoursesDelegate {

	var tutorInfoDelegate: TutorRegistrationInfoDelegate!
	
	var nextButton: UIBarButtonItem!
	fileprivate var activityIndicator: MBProgressHUD!
	fileprivate var selectedIndexPaths = [IndexPath]()
	
	var subjects: [Subject]!
	
	// TutorClassesDelegate implementation
	var courses: [String]! {
		didSet {
			if self.courses.count != 0 {
				self.nextButton.isEnabled = true
			} else {
				self.nextButton.isEnabled = false
			}
		}
	}
	
    override func viewDidLoad() {
		super.viewDidLoad()
		self.nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(TutorRegistrationClassesVC.nextButtonDidPress))
		//self.nextButton.isEnabled = false
		self.navigationItem.rightBarButtonItem = nextButton
		self.courses = [String]()
		self.subjects = [Subject]()
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
			DatabaseManager.shared.downloadSubjects { (subjects, error) in
				if let error = error {
					print(error.localizedDescription)
				} else {
					if let subjects = subjects {
						DispatchQueue.main.async {
							self.subjects = subjects
							self.tableView.reloadData()
							UIApplication.shared.isNetworkActivityIndicatorVisible = false
						}
					}
				}
			}
		}
	}
	
	func refresh(sender: Any) {
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.refreshControl?.endRefreshing()
		} else {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			DatabaseManager.shared.downloadSubjects { (subjects, error) in
				if let error = error {
					print(error.localizedDescription)
				} else {
					if let subjects = subjects {
						DispatchQueue.main.async {
							self.subjects = subjects
							self.tableView.reloadData()
							UIApplication.shared.isNetworkActivityIndicatorVisible = false
							self.refreshControl?.endRefreshing()
						}
					}
				}
			}
		}
	}

	
	func nextButtonDidPress() {
		self.presentTutorRegistrationPayoutVC() 
	}

	func showNoNetworkNotification() {
		let notificationView: MessageView = try! SwiftMessages.viewFromNib(named: "NoNetworkNotification")
		//let notificationView = MessageView.viewFromNib(layout: .CenteredView)
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
		if !self.selectedIndexPaths.contains(indexPath) {
			cell.accessoryType = .none
		} else if self.selectedIndexPaths.contains(indexPath) {
			cell.accessoryType = .checkmark
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		let section = indexPath.section
		let row = indexPath.row
		
		if let cell = tableView.cellForRow(at: indexPath) {
			if self.selectedIndexPaths.contains(indexPath)
			{
				cell.accessoryType = .none
				_ = self.selectedIndexPaths.index(of: indexPath).map { self.selectedIndexPaths.remove(at: $0) }
				let courseName = self.subjects[section].courses[row]
				_ = self.courses.index(of: courseName).map { self.courses.remove(at: $0) }
			} else {
				cell.accessoryType = .checkmark
				self.selectedIndexPaths.append(indexPath)
				let courseName = self.subjects[section].courses[row]
				self.courses.append(courseName)
			}
		}
	}	
}

extension TutorRegistrationClassesVC {
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

extension TutorRegistrationClassesVC {
	// presents TutorRegistrationPayoutVC
	fileprivate func presentTutorRegistrationPayoutVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentProfile", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "TutorRegistrationPayoutVC") as! TutorRegistrationPayoutVC
		vc.tutorInfoDelegate = self.tutorInfoDelegate
		vc.tutorCoursesDelegate = self as TutorCoursesDelegate
		self.navigationController?.pushViewController(vc, animated: true)
	}
}
