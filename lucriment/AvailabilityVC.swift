//
//  AvailabilityVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-06-20.
//  Copyright © 2017 Anton Lysov. All rights reserved.
//

import UIKit

class AvailabilityVC: UIViewController {

	@IBOutlet weak var calendarAvailabilityView: UIView!
	@IBOutlet weak var defaultAvailabilityView: UIView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.calendarAvailabilityView.isHidden = false
		self.defaultAvailabilityView.isHidden = true
    }
	
	@IBAction func viewDidChange(sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex
		{
		case 0:
			self.calendarAvailabilityView.isHidden = false
			self.defaultAvailabilityView.isHidden = true
		case 1:
			self.calendarAvailabilityView.isHidden = true
			self.defaultAvailabilityView.isHidden = false
		default:
			break;
		}
	}
	
	@IBAction func addButtonDidPress(_ sender: Any) {
		if self.calendarAvailabilityView.isHidden == false {
			let vc = self.childViewControllers.first(where: { $0 is CalendarAvailabilityVC }) as! CalendarAvailabilityVC
			vc.addButtonDidPress()
		} else {
			let vc = self.childViewControllers.first(where: { $0 is DefaultAvailabilityVC }) as! DefaultAvailabilityVC
			vc.addButtonDidPress()
		}
	}
}
