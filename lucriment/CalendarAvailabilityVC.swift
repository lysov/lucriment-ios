//
//  CalendarAvailabilityVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-28.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import JTAppleCalendar

protocol SelectedDayDelegate {
	var selectedDay: Date! { get }
}

class CalendarAvailabilityVC: UIViewController, SelectedDayDelegate, CustomAvailabilityDelegate {
	var defaultAvailabilties: [Timeslot]!
	
	@IBOutlet weak var monthLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var calendarView: JTAppleCalendarView!
	
	var timeslotDelegate: (String, Timeslot)!
	
	var timeslot: Timeslot!
	var selectedDay: Date!
	var today: Date!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.selectedDay = Date()
		self.today = selectedDay.day()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupCalendar()
		self.tableView.tableFooterView = UIView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		DispatchQueue.main.async {
			UserManager.shared.fetchCustomAvailability { (error) in
				if let error = error {
					print(error.localizedDescription)
				} else {
					self.tableView.reloadData()
				}
			}
		}
	}
}

extension CalendarAvailabilityVC {
		
	func addButtonDidPress() {
		self.presentAddCustomAvailabilityVC()
	}
}

extension CalendarAvailabilityVC {
	// MARK: - Setup the Calendar
	func setupCalendar() {
		self.calendarView.minimumLineSpacing = 0
		self.calendarView.minimumInteritemSpacing = 0
		
		self.calendarView.visibleDates { (visibleDates) in
			let date = visibleDates.monthDates.first!.date
			
			let formatter = DateFormatter()
			formatter.dateFormat = "MMMM"
			
			self.monthLabel.text = formatter.string(from: date)
		}
		
		// selects today's date
		self.calendarView.selectDates([self.selectedDay])
	}
	
	func handleCellTextColor(cell: JTAppleCell?, cellState: CellState) {
		guard let cell = cell as? DateJTAppleCell else { return }
		
		if cellState.dateBelongsTo == .thisMonth {
			if cellState.isSelected {
				cell.dateLabel.textColor = .white
			} else if cellState.date == self.today {
				cell.dateLabel.textColor = LUCColor.red
			} else {
				
				let now = Date()
				
				if cellState.date < now.day() {
					cell.dateLabel.textColor = LUCColor.gray
				} else {
					cell.dateLabel.textColor = LUCColor.black
				}
				
			}
		} else {
			cell.dateLabel.textColor = LUCColor.gray
		}
	}
	
	func handleCellSelected(cell: JTAppleCell?, cellState: CellState) {
		guard let cell = cell as? DateJTAppleCell else { return }
		
		if cellState.isSelected {
			cell.selectedView.isHidden = false
		} else {
			cell.selectedView.isHidden = true
		}
	}
	
}

extension CalendarAvailabilityVC: JTAppleCalendarViewDataSource {
	
	func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy MM dd"
		formatter.timeZone = Calendar.current.timeZone
		formatter.locale = Calendar.current.locale
		
		// the month (current) to schedule a session that gonna be shown on user device
		let startDateComponents = Calendar.current.dateComponents([.era, .year, .month, .day, .hour, .minute, .second, .nanosecond, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear, .yearForWeekOfYear],
			from: self.selectedDay)
		print(startDateComponents)
		
		let startDate = Calendar.current.date(from: startDateComponents)
		
		// interval is 6 months
		let interval = DateComponents(month: 5)
		
		let endDate = Calendar.current.date(byAdding: interval, to: startDate!)!.endOfMonth()
		print("endDate: \(endDate)")
		print("endDate timestamp: \(endDate.timeIntervalSince1970)")
		return ConfigurationParameters.init(startDate: startDate!, endDate: endDate, generateOutDates: .tillEndOfRow, firstDayOfWeek: .monday)
	}
}

extension CalendarAvailabilityVC: JTAppleCalendarViewDelegate {
	func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {}
	
	// Display cell
	func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
		let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "DateJTAppleCell", for: indexPath) as! DateJTAppleCell
		cell.dateLabel.text = cellState.text
		
		self.handleCellTextColor(cell: cell, cellState: cellState)
		self.handleCellSelected(cell: cell, cellState: cellState)
		return cell
	}
	
	func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
		let now = Date()
		
		if cellState.date < now.day() {
			return false
		}
		
		return true
	}
	
	func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
		self.handleCellTextColor(cell: cell, cellState: cellState)
		self.handleCellSelected(cell: cell, cellState: cellState)
		
		self.selectedDay = date
		self.tableView.reloadData()
	}
	
	func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
		self.handleCellTextColor(cell: cell, cellState: cellState)
		self.handleCellSelected(cell: cell, cellState: cellState)
	}
	
	func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
		let date = visibleDates.monthDates.first!.date
		
		let formatter = DateFormatter()
		formatter.dateFormat = "MMMM"
		
		self.monthLabel.text = formatter.string(from: date)
	}
}

extension CalendarAvailabilityVC: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		let day = Int(self.selectedDay.timeIntervalSince1970) * 1000
		
		var weekDay = ""
		let weekDayInt = Calendar.current.dateComponents([.weekday], from: self.selectedDay).weekday!
		
		switch weekDayInt {
		case 2:
			weekDay = "monday"
		case 3:
			weekDay = "tuesday"
		case 4:
			weekDay = "wednesday"
		case 5:
			weekDay = "thursday"
		case 6:
			weekDay = "friday"
		case 7:
			weekDay = "saturday"
		case 1:
			weekDay = "sunday"
		default:
			break
		}
		
		if UserManager.shared.customAvailability.keys.contains("\(day)") {
			return (UserManager.shared.customAvailability["\(day)"]?.count)!
		} else if UserManager.shared.defaultAvailability.keys.contains(weekDay){
			return UserManager.shared.defaultAvailability[weekDay]!.count
		}
		
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		var weekDay = ""
		let weekDayInt = Calendar.current.dateComponents([.weekday], from: self.selectedDay).weekday!
		
		switch weekDayInt {
		case 2:
			weekDay = "monday"
		case 3:
			weekDay = "tuesday"
		case 4:
			weekDay = "wednesday"
		case 5:
			weekDay = "thursday"
		case 6:
			weekDay = "friday"
		case 7:
			weekDay = "saturday"
		case 1:
			weekDay = "sunday"
		default:
			break
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "availabilityCell", for: indexPath)
		cell.textLabel?.textColor = LUCColor.black
		cell.selectionStyle = .default
		
		let day = Int(self.selectedDay.timeIntervalSince1970) * 1000
		if UserManager.shared.customAvailability.keys.contains("\(day)") {
			cell.textLabel?.text = UserManager.shared.customAvailability["\(day)"]![indexPath.row].1.toString()
			return cell
		} else if UserManager.shared.defaultAvailability.keys.contains(weekDay){
			let timeslot = UserManager.shared.defaultAvailability[weekDay]![indexPath.row]
			cell.textLabel?.text = timeslot.toStringInUTC()
			return cell
		}
		
		// Cell Appearance
		cell.textLabel?.textColor = LUCColor.gray
		cell.textLabel?.text = "No scheduled availability yet"
		cell.selectionStyle = .none
		
		return cell
	}
	
	// FIXME: - EditAvailabilityTableViewController should be pushed from Availability viewController
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		self.tableView.deselectRow(at: indexPath, animated: true)
		
		let day = Int(self.selectedDay.timeIntervalSince1970) * 1_000
		
		if UserManager.shared.customAvailability.keys.contains("\(day)") {
			self.timeslotDelegate = UserManager.shared.customAvailability["\(day)"]![indexPath.row]
		} else {
			var weekDay = ""
			let weekDayInt = Calendar.current.dateComponents([.weekday], from: self.selectedDay).weekday!
			
			switch weekDayInt {
			case 2:
				weekDay = "monday"
			case 3:
				weekDay = "tuesday"
			case 4:
				weekDay = "wednesday"
			case 5:
				weekDay = "thursday"
			case 6:
				weekDay = "friday"
			case 7:
				weekDay = "saturday"
			case 1:
				weekDay = "sunday"
			default:
				break
			}
			
			if UserManager.shared.defaultAvailability.keys.contains(weekDay) {
				// pass def. availability without the timelot that will be changes and inside edit C. Av. check for that object
				
				self.timeslotDelegate = ("0", UserManager.shared.defaultAvailability[weekDay]![indexPath.row].converted(to: self.selectedDay))
				var updatedDefaultAvailabilities = UserManager.shared.defaultAvailability[weekDay]!
				updatedDefaultAvailabilities.remove(at: indexPath.row)
				self.defaultAvailabilties = updatedDefaultAvailabilities
			}
		}
		
		self.presentEditCustomAvailabilityController()
	}
}

extension CalendarAvailabilityVC {
	
	// presents EditCustomAvailabilityController
	fileprivate func presentEditCustomAvailabilityController() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "TutorAvailability", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "EditCustomAvailabilityController") as! EditCustomAvailabilityController
		vc.delegate = self as CustomAvailabilityDelegate
		let navigationController = UINavigationController(rootViewController: vc)
		navigationController.navigationBar.barStyle = .black
		navigationController.navigationBar.barTintColor = LUCColor.blue
		navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
		navigationController.navigationBar.tintColor = .white
		self.present(navigationController, animated: true, completion: nil)
	}
	
	// presents AddCustomAvailabilityVC
	fileprivate func presentAddCustomAvailabilityVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "TutorAvailability", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "AddCustomAvailabilityVC") as! AddCustomAvailabilityVC
		vc.delegate = self as SelectedDayDelegate
		let navigationController = UINavigationController(rootViewController: vc)
		navigationController.navigationBar.barStyle = .black
		navigationController.navigationBar.isTranslucent = true
		navigationController.navigationBar.barTintColor = LUCColor.blue
		navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
		navigationController.navigationBar.tintColor = .white
		self.present(navigationController, animated: true, completion: nil)
	}
}
