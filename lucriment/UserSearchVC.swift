//
//  UserSearchVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-16.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages
import SDWebImage
import FirebaseAuth

class UserSearchVC: UITableViewController, SearchResultsDelegate, TutorDelegate {
	
	// MARK:- Properties
	
	// No Search Results
	@IBOutlet weak var noSearchResultsBackgroundView: UIView!
	@IBOutlet weak var initialBackgroundView: UIView!
	
	// Network Disconnection
	@IBOutlet weak var activityView: UIView!
	@IBOutlet weak var noNetworkConnectionLabel: UILabel!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	// Data Source
	var tutors = [Tutor]()
	
	// Selected Tutor
	var tutor: Tutor!
	
	// SearchResultsDelegate
	var subjects: [Subject]!
	var filteredSubjects: [Subject]!
	
	var searchResultsController: UserSearchSubjectsVC!
	var searchController: UISearchController!
	
	
	
	
	// MARK:- UIViewController Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
		
		// Setup model for SearchResultsVC
		self.subjects = [Subject]()
		self.filteredSubjects = [Subject]()
		
		// Setup the Search Controller
		
		//Creates an instance of a custom View Controller that holds the results
		self.searchResultsController = UIStoryboard(name: "StudentSearch", bundle: nil).instantiateViewController(withIdentifier: "UserSearchSubjectsVC") as! UserSearchSubjectsVC
		self.searchResultsController.delegate = self
		self.searchController = UISearchController(searchResultsController: searchResultsController)
		self.searchController.searchBar.setTextColor(color: LUCColor.black)
		self.searchController.searchBar.tintColor = .white
		self.searchController.searchBar.delegate = self
		UITextField.appearance(whenContainedInInstancesOf: [type(of: searchController.searchBar)]).tintColor = LUCColor.blue
		self.searchController.searchBar.placeholder = NSLocalizedString("Search by Subject", comment: "")
		self.searchController.searchResultsUpdater = self
		self.searchController.hidesNavigationBarDuringPresentation = false
		self.searchController.obscuresBackgroundDuringPresentation = true
		self.definesPresentationContext = true
		// Adds searchController to the Navigation Controller
		self.navigationItem.titleView = searchController.searchBar
		
		self.tableView.tableFooterView = UIView()
		self.setupTableViewBackgroundView()
		
		if Auth.auth().currentUser?.email == nil {
			self.presentFacebookRegistrationController()
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
}

extension UserSearchVC: UISearchResultsUpdating {
	// MARK: - UISearchResultsUpdating Delegate
	func updateSearchResults(for searchController: UISearchController) {
		
		self.searchController.searchResultsController?.view.isHidden = false
		self.filterContentForSearchText(self.searchController.searchBar.text!)
		if let subject = self.searchController.searchBar.text, subject != "" {
			self.searchForTutors(by: subject)
		}
		
	}
	
	func searchBarIsEmpty() -> Bool {
		// Returns true if the text is empty or nil
		return self.searchController.searchBar.text?.isEmpty ?? true
	}
	
	func filterContentForSearchText(_ searchText: String, scope: String = "All") {
		self.filteredSubjects = self.subjects
		
		self.filteredSubjects = self.subjects.filter( {( subject : Subject) -> Bool in
			return subject.courses.filter( {(course: String) -> Bool in
				return course.lowercased().contains(searchText.lowercased())
			}).count > 0
		})
		self.searchResultsController.tableView.reloadData()
	}
}

extension UserSearchVC: UISearchBarDelegate {
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		self.isEditing = false
		self.tutors = [Tutor]()
		self.tableView.reloadData()
	}
}


extension UserSearchVC {
	
	func setupTableViewBackgroundView() {
		self.tableView.backgroundView = self.initialBackgroundView
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		
		let row = indexPath.row
		
		self.tutor = self.tutors[row]

		self.presentTutorInfoController()
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if searchBarIsEmpty() {
			if self.tutors.count == 0 {
				self.tableView.separatorStyle = .none
				self.tableView.backgroundView = self.initialBackgroundView
				self.tableView.backgroundView?.isHidden = false
			} else {
				self.tableView.separatorStyle = .singleLine
				self.tableView.backgroundView?.isHidden = true
			}
		} else {
			if self.tutors.count == 0 {
				self.tableView.separatorStyle = .none
				self.tableView.backgroundView = self.noSearchResultsBackgroundView
				self.tableView.backgroundView?.isHidden = false
			} else {
				self.tableView.separatorStyle = .singleLine
				self.tableView.backgroundView?.isHidden = true
			}
		}
		
		return self.tutors.count
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
}



// MARK:- Network Disconnection
extension UserSearchVC {
	func presentActivityView() {
		self.activityView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
		self.activityIndicatorView.color = LUCColor.gray
		self.activityIndicatorView.startAnimating()
		self.activityIndicatorView.isHidden = false
		self.view.addSubview(self.activityView)
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	
	func dismissActivityView() {
		self.noNetworkConnectionLabel.isHidden = false
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
	
	func showNoNetworkNotification() {
		let notificationView: MessageView = try! SwiftMessages.viewFromNib(named: "NoNetworkNotification")
		notificationView.preferredHeight = 35
		var config = SwiftMessages.Config()
		config.duration = .seconds(seconds: 3)
		
		SwiftMessages.show(config: config, view: notificationView)
	}
}

extension UserSearchVC {
	
	// load tutor profiles based on the query
	func searchForTutors(by subject: String) {
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable, self.activityView.isHidden == false {
			self.presentNoNetworkActivityView()
		}
		else if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.showNoNetworkNotification()
		} else {
			DatabaseManager.shared.downloadTutors(for: subject) { (tutors, error) in
				
				if let error = error {
					
					print(error.localizedDescription)
					DispatchQueue.main.async {
						self.tutors = [Tutor]()
						self.tableView.reloadData()
					}
					
				} else if let tutors = tutors {
					DispatchQueue.main.async {
						self.tutors = tutors
						self.tableView.reloadData()
					}
				}
				
			}
		}
	}
}

extension UserSearchVC {
	// presents FacebookRegistrationVC
	fileprivate func presentTutorInfoController() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentSearch", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "TutorInfoController") as! TutorInfoController
		vc.tutorDelegate = self as TutorDelegate
		vc.subject = self.searchController.searchBar.text
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	// presents FacebookRegistrationVC
	fileprivate func presentFacebookRegistrationController() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
		let navigationController = mainStoryboard.instantiateViewController(withIdentifier: "FacebookRegistrationController")
		self.present(navigationController, animated: false, completion: nil)
	}
}
