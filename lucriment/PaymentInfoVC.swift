//
//  PaymentInfoVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-15.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class PaymentInfoVC: UITableViewController {
	
	// No Payment Info
	@IBOutlet weak var backgroundView: UIView!
	
	// Network Disconnection
	@IBOutlet weak var activityView: UIView!
	@IBOutlet weak var noNetworkConnectionLabel: UILabel!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	var creditCard: CreditCard!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Payment"
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
				DatabaseManager.shared.fetchPaymentInfo { (creditCard, error) in
					if let error = error {
						print(error.localizedDescription)
					} else if let creditCard = creditCard {
						self.creditCard = creditCard
						self.tableView.reloadData()
					}
					self.dismissActivityView()
				}
			}
		}
	}
	
	@IBAction func editButtonDidPress(_ sender: Any) {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentProfile", bundle: nil)
		let navigationController = mainStoryboard.instantiateViewController(withIdentifier: "EditPaymentInfoController")
		self.present(navigationController, animated: true, completion: nil)
	}
}

extension PaymentInfoVC {
	
	func setupTableView() {
		
		// tableView
		self.tableView.backgroundView = self.backgroundView
		self.tableView.backgroundView?.isHidden = true
		self.tableView.tableFooterView = UIView()
	}
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		cell.textLabel?.text = self.creditCard.brand + "****" + self.creditCard.lastFourDigits
		cell.detailTextLabel?.text = "\(self.creditCard.expirationMonth)/\(self.creditCard.expirationYear / 100)"
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if self.creditCard == nil {
			self.tableView.separatorStyle = .none
			self.tableView.backgroundView?.isHidden = false
		} else {
			self.tableView.separatorStyle = .singleLine
			self.tableView.backgroundView?.isHidden = true
		}
		
		if self.creditCard == nil {
			return 0
		}
		
		return 1
	}
}

// MARK:- Network Disconnection
extension PaymentInfoVC {
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
