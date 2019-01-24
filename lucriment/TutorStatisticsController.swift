//
//  TutorStatisticsController.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-09.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class TutorStatisticsController: UIViewController {

	@IBOutlet weak var earningsView: UIView!
	@IBOutlet weak var feedbackView: UIView!
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.earningsView.isHidden = false
		self.feedbackView.isHidden = true
	}
	
	@IBAction func viewDidChange(sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex
		{
		case 0:
			self.earningsView.isHidden = false
			self.feedbackView.isHidden = true
		case 1:
			self.earningsView.isHidden = true
			self.feedbackView.isHidden = false
		default:
			break
		}
	}
}
