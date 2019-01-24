//
//  DefaultAvailabilityVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-06-20.
//  Copyright © 2017 Anton Lysov. All rights reserved.
//

import UIKit
import SwiftMessages

class DefaultAvailabilityVC: UITableViewController, DefaultAvailabilityDelegate {
	
	// DateProvider protocol implementaion
	var day: WeekDay!
	var timeslot: Timeslot!
	
	// Model
	var defaultAvailability: [String: [Timeslot]]!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.defaultAvailability = [String: [Timeslot]]()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.tableView.tableFooterView = UIView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		DispatchQueue.main.async {
			UserManager.shared.fetchDefaultAvailability { (error) in
				if let error = error {
					print(error.localizedDescription)
				} else {
					self.defaultAvailability = UserManager.shared.defaultAvailability
					
					if let mondayAvailability = self.defaultAvailability["monday"] {
						self.defaultAvailability["monday"] = mondayAvailability
					}
					if let mondayAvailability = self.defaultAvailability["tuesday"] {
						self.defaultAvailability["tuesday"] = mondayAvailability
					}
					if let mondayAvailability = self.defaultAvailability["wednesday"] {
						self.defaultAvailability["wednesday"] = mondayAvailability
					}
					if let mondayAvailability = self.defaultAvailability["thursday"] {
						self.defaultAvailability["thursday"] = mondayAvailability
					}
					if let mondayAvailability = self.defaultAvailability["friday"] {
						self.defaultAvailability["friday"] = mondayAvailability
					}
					if let mondayAvailability = self.defaultAvailability["saturday"] {
						self.defaultAvailability["saturday"] = mondayAvailability
					}
					if let mondayAvailability = self.defaultAvailability["sunday"] {
						self.defaultAvailability["sunday"] = mondayAvailability
					}
					self.tableView.reloadData()
				}
			}
		}
	}
}

extension DefaultAvailabilityVC {
	
	func addButtonDidPress() {
		self.presentAddDefaultAvailabilityVC()
	}
}

extension DefaultAvailabilityVC {
	
	// MARK:- tableView Data Sourse
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 7
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		var title: String? = nil
		
		switch section {
		case 0: title = "Monday"
		case 1: title = "Tuesday"
		case 2: title = "Wednesday"
		case 3: title = "Thursday"
		case 4: title = "Friday"
		case 5: title = "Saturday"
		case 6: title = "Sunday"
		default:
			break
		}
		
		return title
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			if self.defaultAvailability.keys.contains("monday") {
				return self.defaultAvailability["monday"]!.count
			}
		case 1:
			if self.defaultAvailability.keys.contains("tuesday") {
				return self.defaultAvailability["tuesday"]!.count
			}
		case 2:
			if self.defaultAvailability.keys.contains("wednesday") {
				return self.defaultAvailability["wednesday"]!.count
			}
		case 3:
			if self.defaultAvailability.keys.contains("thursday") {
				return self.defaultAvailability["thursday"]!.count
			}
		case 4:
			if self.defaultAvailability.keys.contains("friday") {
				return self.defaultAvailability["friday"]!.count
			}
		case 5:
			if self.defaultAvailability.keys.contains("saturday") {
				return self.defaultAvailability["saturday"]!.count
			}
		case 6:
			if self.defaultAvailability.keys.contains("sunday") {
				return self.defaultAvailability["sunday"]!.count
			}
		default:
			break
		}
		
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell")!
		cell.textLabel?.textColor = LUCColor.black
		cell.selectionStyle = .default
		
		switch indexPath.section {
		case 0:
			if self.defaultAvailability.keys.contains("monday") {
				let timeslot = self.defaultAvailability["monday"]![indexPath.row]
				cell.textLabel?.text = timeslot.toStringInUTC()
				return cell
			}
		case 1:
			if self.defaultAvailability.keys.contains("tuesday") {
				let timeslot = self.defaultAvailability["tuesday"]![indexPath.row]
				cell.textLabel?.text = timeslot.toStringInUTC()
				return cell
			}
		case 2:
			if self.defaultAvailability.keys.contains("wednesday") {
				let timeslot = self.defaultAvailability["wednesday"]![indexPath.row]
				cell.textLabel?.text = timeslot.toStringInUTC()
				return cell
			}
		case 3:
			if self.defaultAvailability.keys.contains("thursday") {
				let timeslot = self.defaultAvailability["thursday"]![indexPath.row]
				cell.textLabel?.text = timeslot.toStringInUTC()
				return cell
			}
		case 4:
			if self.defaultAvailability.keys.contains("friday") {
				let timeslot = self.defaultAvailability["friday"]![indexPath.row]
				cell.textLabel?.text = timeslot.toStringInUTC()
				return cell
			}
		case 5:
			if self.defaultAvailability.keys.contains("saturday") {
				let timeslot = self.defaultAvailability["saturday"]![indexPath.row]
				cell.textLabel?.text = timeslot.toStringInUTC()
				return cell
			}
		case 6:
			if self.defaultAvailability.keys.contains("sunday") {
				let timeslot = self.defaultAvailability["sunday"]![indexPath.row]
				cell.textLabel?.text = timeslot.toStringInUTC()
				return cell
			}
		default:
			break
		}
		
		cell.textLabel?.text = "Not Selected"
		cell.textLabel?.textColor = LUCColor.gray
		cell.selectionStyle = .none
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		self.tableView.deselectRow(at: indexPath, animated: true)
		
		var dateComponents = DateComponents()
		dateComponents.year = 1970
		guard let abbreviation = Calendar.current.timeZone.abbreviation() else {
			print("error")
			return
		}
		dateComponents.timeZone = TimeZone(abbreviation: abbreviation)
		
		switch indexPath.section {
		case 0:
			if self.defaultAvailability.keys.contains("monday") {
				self.day = WeekDay.monday
				self.timeslot = self.defaultAvailability["monday"]![indexPath.row]
				
				self.presentEditDefaultAvailabilityController()
			}
		case 1:
			if self.defaultAvailability.keys.contains("tuesday") {
				self.day = WeekDay.tuesday
				self.timeslot = self.defaultAvailability["tuesday"]![indexPath.row]
				
				self.presentEditDefaultAvailabilityController()
			}
		case 2:
			if self.defaultAvailability.keys.contains("wednesday") {
				self.day = WeekDay.wednesday
				self.timeslot = self.defaultAvailability["wednesday"]![indexPath.row]
				
				self.presentEditDefaultAvailabilityController()
			}
		case 3:
			if self.defaultAvailability.keys.contains("thursday") {
				self.day = WeekDay.thursday
				self.timeslot = self.defaultAvailability["thursday"]![indexPath.row]
				
				self.presentEditDefaultAvailabilityController()
			}
		case 4:
			if self.defaultAvailability.keys.contains("friday") {
				self.day = WeekDay.friday
				self.timeslot = self.defaultAvailability["friday"]![indexPath.row]
				
				self.presentEditDefaultAvailabilityController()
			}
		case 5:
			if self.defaultAvailability.keys.contains("saturday") {
				self.day = WeekDay.saturday
				self.timeslot = self.defaultAvailability["saturday"]![indexPath.row]
				
				self.presentEditDefaultAvailabilityController()
			}
		case 6:
			if self.defaultAvailability.keys.contains("sunday") {
				self.day = WeekDay.sunday
				self.timeslot = self.defaultAvailability["sunday"]![indexPath.row]
				
				self.presentEditDefaultAvailabilityController()
			}
		default:
			break
		}
	}
}

extension DefaultAvailabilityVC {
	
	// presents EditDefaultAvailabilityController
	fileprivate func presentEditDefaultAvailabilityController() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "TutorAvailability", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "EditDefaultAvailabilityController") as! EditDefaultAvailabilityController
		vc.delegate = self as DefaultAvailabilityDelegate
		let navigationController = UINavigationController(rootViewController: vc)
		navigationController.navigationBar.barStyle = .black
		navigationController.navigationBar.barTintColor = LUCColor.blue
		navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
		navigationController.navigationBar.tintColor = .white
		self.present(navigationController, animated: true, completion: nil)
	}
	
	// presents AddDefaultAvailability
	fileprivate func presentAddDefaultAvailabilityVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "TutorAvailability", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "AddDefaultAvailabilityVC") as! AddDefaultAvailabilityVC
		let navigationController = UINavigationController(rootViewController: vc)
		navigationController.navigationBar.barStyle = .black
		navigationController.navigationBar.isTranslucent = true
		navigationController.navigationBar.barTintColor = LUCColor.blue
		navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
		navigationController.navigationBar.tintColor = .white
		self.present(navigationController, animated: true, completion: nil)
	}
}
