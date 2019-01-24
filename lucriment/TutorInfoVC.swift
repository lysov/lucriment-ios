//
//  TutorInfoVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-17.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages
import SDWebImage

protocol TutorDelegate {
	var tutor: Tutor! { get }
}

class TutorInfoVC: UITableViewController {
	
	// Network Disconnection
	@IBOutlet weak var activityView: UIView!
	@IBOutlet weak var noNetworkConnectionLabel: UILabel!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	// Cells
	@IBOutlet weak var tutorCell: TutorCell!
	@IBOutlet weak var aboutCell: InfoCell!
	@IBOutlet weak var subjectsCell: InfoCell!
	@IBOutlet weak var mapCell: TutorInfoMapCell!

	var tutorDelegate: TutorDelegate!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.setupTableView()
		self.presentActivityView()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable, self.activityView.isHidden == false {
			self.presentNoNetworkActivityView()
		}
		else if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.presentNoNetworkNotification()
		} else {
			DispatchQueue.main.async {
				self.dismissActivityView()
				
				// Map Cell
				let mapVC = self.childViewControllers.last as! TutorInfoMapVC
				mapVC.refresh(address: self.tutorDelegate.tutor.postalCode)
			}
		}
	}
}

// table view
extension TutorInfoVC {
	func setupTableView() {
		
		// Set up tableView
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 44.0
		self.tableView.tableFooterView = UIView()
		
		// Set up cells
		
		
		// Tutor Cell
		if let profileImageReference = self.tutorDelegate.tutor.profileImage {
			let url = URL(string: profileImageReference)
			
			self.tutorCell.profileImageView.isHidden = false
			self.tutorCell.profileImageView.sd_setImage(with: url, placeholderImage: nil)
		}
		
		// tutorCell
		self.tutorCell.nameLabel.text = self.tutorDelegate.tutor.fullName
		if let headline = self.tutorDelegate.tutor.headline {
			self.tutorCell.headlineLabel.text = headline
		} else {
			self.tutorCell.headlineLabel.text = "\n\n"
		}
		
		if let rating = self.tutorDelegate.tutor.rating {
			let ratingString = String(rating.rounded(toPlaces: 1))
			self.tutorCell.ratingLabel.text = ratingString
		} else {
			self.tutorCell.ratingLabel.text = "N/A"
		}
		self.tutorCell.rateLabel.text = "$\(self.tutorDelegate.tutor.rate)/h"
		self.tutorCell.cityLabel.text = self.tutorDelegate.tutor.address ?? self.tutorDelegate.tutor.postalCode
		
		// aboutCell
		if let about = self.tutorDelegate.tutor.about {
			self.aboutCell.cellText.text = about
		}
		
		// subjectsCell
		self.subjectsCell.cellText.text = self.tutorDelegate.tutor.subjects
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let row = indexPath.row
		switch row {
		case 1, 2:
			return UITableViewAutomaticDimension
		default:
			break
		}
		return super.tableView(tableView, heightForRowAt: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		
		if indexPath.row == 4 {
			let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentSearch", bundle: nil)
			let vc = mainStoryboard.instantiateViewController(withIdentifier: "TutorReviewsVC") as! TutorReviewsVC
			vc.id = self.tutorDelegate.tutor.id
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
}

// MARK:- Network Disconnection
extension TutorInfoVC {
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
	
	func presentNoNetworkNotification() {
		let notificationView: MessageView = try! SwiftMessages.viewFromNib(named: "NoNetworkNotification")
		notificationView.preferredHeight = 35
		var config = SwiftMessages.Config()
		config.duration = .seconds(seconds: 3)
		
		SwiftMessages.show(config: config, view: notificationView)
	}
}
