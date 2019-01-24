//
//  TutorPayoutInfoVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-09.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//
import UIKit
import SwiftMessages

class TutorPayoutInfoVC: UITableViewController {
	
	// No Payment Info
	@IBOutlet weak var backgroundView: UIView!
	
	// Network Disconnection
	@IBOutlet weak var activityView: UIView!
	@IBOutlet weak var noNetworkConnectionLabel: UILabel!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	var payout: Payout!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Payout"
		self.setupTableView()
		self.presentActivityView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable, self.activityView.isHidden == false {
			self.presentNoNetworkActivityView()
		}
		else if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.showNoNetworkNotification()
		} else {
			DispatchQueue.main.async {
				
				// download credit card info
				DatabaseManager.shared.fetchPayoutInfo { (payout, error) in
					if let error = error {
						print(error.localizedDescription)
					} else if let payout = payout {
						self.payout = payout
						self.tableView.reloadData()
					}
					self.dismissActivityView()
				}
			}
		}
	}
	
	@IBAction func editButtonDidPress(_ sender: Any) {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "TutorProfile", bundle: nil)
		let navigationController = mainStoryboard.instantiateViewController(withIdentifier: "EditPayoutInfoController")
		self.present(navigationController, animated: true, completion: nil)
	}
}

extension TutorPayoutInfoVC {
	
	func setupTableView() {
		
		// tableView
		self.tableView.backgroundView = self.backgroundView
		self.tableView.backgroundView?.isHidden = true
		self.tableView.tableFooterView = UIView()
	}
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		cell.textLabel?.text = self.payout.bank + "****" + self.payout.lastFourDigits
		cell.detailTextLabel?.text = "\(self.payout.transit)-\(self.payout.financialInstitution)"
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if self.payout == nil {
			self.tableView.separatorStyle = .none
			self.tableView.backgroundView?.isHidden = false
		} else {
			self.tableView.separatorStyle = .singleLine
			self.tableView.backgroundView?.isHidden = true
		}
		
		if self.payout == nil {
			return 0
		}
		
		return 1
	}
}

// MARK:- Network Disconnection
extension TutorPayoutInfoVC {
	func presentActivityView() {
		self.activityView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
		self.activityIndicatorView.color = LUCColor.gray
		self.activityIndicatorView.startAnimating()
		self.activityIndicatorView.isHidden = false
		self.view.addSubview(self.activityView)
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	
	func dismissActivityView() {
		self.noNetworkConnectionLabel.isHidden = true
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
	
	func presentNoMessagesView() {
		self.noNetworkConnectionLabel.isHidden = true
		self.activityIndicatorView.stopAnimating()
		self.activityIndicatorView.isHidden = true
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
