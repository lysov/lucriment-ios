//
//  InitialVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-23.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class InitialVC: UIViewController {
	
	@IBOutlet weak var featuresScrollView: UIScrollView!
	@IBOutlet weak var featurePageControl: UIPageControl!
	
	@IBOutlet weak var createAccountButton: UIButton!
	@IBOutlet weak var logInButton: UIButton!
	
	internal let feature1 = ["keyword": "Better Grades", "sentence": "Get expert assistance on assignments and exam preparation."]
	internal let feature2 = ["keyword": "Save Time", "sentence": "Finding the perfect tutor is quick and easy."]
	internal let feature3 = ["keyword": "Save Money", "sentence": "Find a tutor within your budget."]
	internal let feature4 = ["keyword": "Find Clients Easily", "sentence": "Gain access to a marketplace of knowledge hungry students."]
	internal let feature5 = ["keyword": "Teach on Your Schedule", "sentence": "Set an availability that works for you."]
	internal var features = [Dictionary<String, String>]()
	
	// timer variables
	internal var scrollViewHorizontalCoordinate: CGFloat = 0
	internal weak var timer: Timer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
		
		// configures UI elements
		self.configureScrollView()
		self.configureCreateAccountButton()
		self.configureLogInButton()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// navigation bar
		self.navigationController?.navigationBar.barStyle = .default
		self.navigationController?.navigationBar.barTintColor = .white
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		
		// starts a timer
		self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerShouldStart), userInfo: nil, repeats: true)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// navigation bar
		self.navigationController?.navigationBar.barStyle = .black
		self.navigationController?.navigationBar.barTintColor = UIColor(red:0.13, green:0.66, blue:0.88, alpha:1)
		self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
		self.navigationController?.navigationBar.shadowImage = nil
		
		// stops the timer
		self.timer.invalidate()
		self.timer = nil
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.featuresScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
		self.scrollViewHorizontalCoordinate = 0
	}
}

// set up scrollView
extension InitialVC {
	internal func configureScrollView() {
		self.features = [self.feature1, self.feature2, self.feature3, self.feature4, self.feature5]
		featuresScrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(self.features.count), height: 220)
		self.configureFeatures()
	}
	
	internal func configureFeatures() {
		for (index, feature) in self.features.enumerated() {
			if let featureView = Bundle.main.loadNibNamed("Feature", owner: self, options: nil)?.first as? FeatureView {
				featureView.image.image = UIImage(named: "Feature\(index)")
				featureView.keyword.text = feature["keyword"]
				featureView.sentence.text = feature["sentence"]
				
				self.featuresScrollView.addSubview(featureView)
				featureView.frame.size.width = self.view.bounds.size.width
				featureView.frame.origin.x = CGFloat(index) * self.view.bounds.size.width
			}
		}
	}
	
	internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let page = scrollView.contentOffset.x / scrollView.frame.size.width
		self.featurePageControl.currentPage = Int(page)
	}
}

// configures buttons
extension InitialVC {
	internal func configureCreateAccountButton() {
		self.createAccountButton.layer.cornerRadius = 20
		self.createAccountButton.setBackgroundColor(color: UIColor(red:0.13, green:0.66, blue:0.88, alpha:1), forState: .highlighted)
	}
	
	internal func configureLogInButton() {
		self.logInButton.layer.cornerRadius = 20
		self.logInButton.layer.borderWidth = 1
		self.logInButton.layer.borderColor = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1).cgColor
		self.logInButton.setBackgroundColor(color: UIColor(red:0.85, green:0.85, blue:0.85, alpha:1), forState: .highlighted)
	}
}

// starts a timer
extension InitialVC {
	internal func timerShouldStart() {
		self.scrollViewHorizontalCoordinate += self.view.bounds.width
		var scrollViewOffset = self.featuresScrollView.contentOffset.x + self.view.bounds.width
		if self.scrollViewHorizontalCoordinate == self.view.bounds.width * 5 {
			self.scrollViewHorizontalCoordinate = 0
		}
		if scrollViewOffset == self.view.bounds.width * 5 {
			scrollViewOffset = 0
		}
		
		if self.scrollViewHorizontalCoordinate == scrollViewOffset {
			self.featuresScrollView.setContentOffset(CGPoint(x: self.scrollViewHorizontalCoordinate, y: 0), animated: true)
		}
	}
}
