//
//  TutorProfileSettingsVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-08.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class TutorProfileSettingsVC: UITableViewController {

	var activityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
		
		self.configureActivityIndicator()
		self.tableView.tableFooterView = UIView()
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		switch indexPath.row {
		case 0:
			self.presentTutorPayoutInfoVC()
		case 2:
			self.presentLogOutAlert()
		default: return
		}
	}
}

extension TutorProfileSettingsVC {
	func presentLogOutAlert() {
		let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { (action) in
			self.displayActivityIndicatorView()
			AuthManager.shared.delegate = self as ActivityIndicatorDelegate
			DispatchQueue.main.async{
				AuthManager.shared.logOut()
			}
		}))
		self.present(alert, animated: true, completion: nil)
	}
	
	// presents TutorPayoutInfoVC
	fileprivate func presentTutorPayoutInfoVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "TutorProfile", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "TutorPayoutInfoVC")
		self.navigationController?.pushViewController(vc, animated: true)
	}
}

extension TutorProfileSettingsVC: ActivityIndicatorDelegate {
	
	internal func presentAlert(title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	internal func configureActivityIndicator() {
		activityIndicator =  UIActivityIndicatorView(activityIndicatorStyle: .gray)
		activityIndicator.center = view.center
		activityIndicator.isHidden = true
		self.view.addSubview(activityIndicator)
	}
	
	internal func displayActivityIndicatorView() -> () {
		UIApplication.shared.beginIgnoringInteractionEvents()
		self.view.bringSubview(toFront: self.activityIndicator)
		self.activityIndicator.isHidden = false
		self.activityIndicator.startAnimating()
	}
	
	internal func hideActivityIndicatorView() -> () {
		if !self.activityIndicator.isHidden{
			DispatchQueue.main.async {
				UIApplication.shared.endIgnoringInteractionEvents()
				self.activityIndicator.stopAnimating()
				self.activityIndicator.isHidden = true
			}
		}
	}
}
