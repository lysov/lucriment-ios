//
//  UserSessionsController.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-06.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class UserSessionsController: UIViewController {
	
	@IBOutlet weak var upcomingSessionsView: UIView!
	@IBOutlet weak var pastSessionsView: UIView!

	@IBOutlet weak var currentSessionView: UIView!
	@IBOutlet weak var currentSessionTimeLabel: UILabel!
	@IBOutlet weak var currentSessionUserLabel: UILabel!
	@IBOutlet weak var currentSessionSubjectLabel: UILabel!
	@IBOutlet weak var currentSessionLocationLabel: UILabel!
	
	var currentSession: Session!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
		
		self.currentSessionView.layer.cornerRadius = 20
		self.upcomingSessionsView.isHidden = false
		self.pastSessionsView.isHidden = true
    }
	
	@IBAction func viewDidChange(sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex
		{
		case 0:
			if let currentSession = self.currentSession {
				let now = Date().timeIntervalSince1970
				let from = currentSession.time.from.timeIntervalSince1970
				let to = currentSession.time.to.timeIntervalSince1970
								
				if now >= from && now <= to {
					self.present(currentSession)
				} else {
					self.currentSession = nil
				}
			}
			self.upcomingSessionsView.isHidden = false
			self.pastSessionsView.isHidden = true
		case 1:
			self.currentSessionView.isHidden = true
			self.upcomingSessionsView.isHidden = true
			self.pastSessionsView.isHidden = false
		default:
			break
		}
	}
	
	func present(_ session: Session) {
		// time View
		let dayFormatter = DateFormatter()
		dayFormatter.dateFormat = "MMMM d"
		
		let timeFormatter = DateFormatter()
		timeFormatter.dateFormat = "h:mm a"
		
		let day = dayFormatter.string(from: session.time.from)
		let from = timeFormatter.string(from: session.time.from)
		let to = timeFormatter.string(from: session.time.to)
		self.currentSessionTimeLabel.text = "\(day), \(from) - \(to)"
		
		// user name
		self.currentSessionUserLabel.text = session.tutorName
		
		// subject
		self.currentSessionSubjectLabel.text = session.subject
		
		// location
		self.currentSessionLocationLabel.text = session.location
		
		self.currentSessionView.isHidden = false
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "UserUpcomingSessionsVC") {
			let vc = segue.destination as! UserUpcomingSessionsVC
			vc.parentVC = self
		}
	}
}
