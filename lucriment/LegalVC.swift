//
//  LegalVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-23.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

protocol URLDelegate {
	var url: URL! { get }
}

class LegalVC: UIViewController {
	
	@IBOutlet weak var webView: UIWebView!
	
	var delegate: URLDelegate!

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.presentAlert()
		} else {
			if let url = self.delegate.url {
				DispatchQueue.main.async{
					self.webView.loadRequest(URLRequest(url: url))
				}
			}
		}
	}
}

extension LegalVC {
	internal func presentAlert() {
		let alert = UIAlertController(title: "No Internet Connection", message: "Please check your Internet connection.", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}
