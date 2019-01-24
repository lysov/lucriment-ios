//
//  AboutVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-01.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class AboutVC: UITableViewController, URLDelegate {

	internal let termsOfUse = URL(string: "https://lucriment.com/tos.html")
	internal let privacyPolicy = URL(string: "https://lucriment.com/privacy.html")
	var url: URL!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.tableFooterView = UIView()
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		let row = indexPath.row
		switch row {
		case 0:
			let storyboard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
			let vc = storyboard.instantiateViewController(withIdentifier: "LegalVC") as! LegalVC
			vc.hidesBottomBarWhenPushed = true
			vc.delegate = self as URLDelegate
			vc.title = "Terms and Conditions of Use"
			self.url = self.termsOfUse
			self.navigationController?.pushViewController(vc, animated: true)
		case 1:
			let storyboard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
			let vc = storyboard.instantiateViewController(withIdentifier: "LegalVC") as! LegalVC
			vc.hidesBottomBarWhenPushed = true
			vc.delegate = self as URLDelegate
			vc.title = "Privacy Policy"
			self.url = self.privacyPolicy
			self.navigationController?.pushViewController(vc, animated: true)
		default:
			break
		}
	}
}
