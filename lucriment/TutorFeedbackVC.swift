//
//  TutorFeedbackVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-09.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class TutorFeedbackVC: UITableViewController {
	
	var reviews = [Review]()
	
	
	
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
				
				DatabaseManager.shared.downloadReviews(for: id) { (reviews, error) in
					if let error = error {
						print(error.localizedDescription)
					} else if let reviews = reviews {
						self.reviews = reviews
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
				
				DatabaseManager.shared.downloadReviews(for: id) { (reviews, error) in
					if let error = error {
						print(error.localizedDescription)
					} else if let reviews = reviews {
						self.reviews = reviews
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
extension TutorFeedbackVC {
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		if self.reviews.count == 0 {
			return nil
		}
		
		let title: UILabel = UILabel()
		
		title.textAlignment = NSTextAlignment.center
		
		// calculate average rating
		var total = 0.0
		var numberOfReviews = 0.0
		for review in self.reviews {
			total += Double(review.rating)
			numberOfReviews += 1
		}
		let averageRating = (total / numberOfReviews).rounded(toPlaces: 1)
		
		title.text = "Average Rating: \(averageRating)"
		title.textColor = LUCColor.gray
		title.font = UIFont.systemFont(ofSize: 15)
		
		let constraint = NSLayoutConstraint.constraints(withVisualFormat: "H:[label]", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["label": title])
		
		title.addConstraints(constraint)
		
		return title
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.reviews.count
    }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let row = indexPath.row
		
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "ReviewCell") as! ReviewCell
		cell.nameLabel.text = self.reviews[row].author
		cell.ratingLabel.text = String(self.reviews[row].rating)
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d"
		let date = Date(milliseconds: self.reviews[row].timeStamp)
		let dateString = dateFormatter.string(from: date)
		cell.dateLabel.text = dateString
		
		cell.feedbackLabel.text = self.reviews[row].text
		
		return cell
	}

}
