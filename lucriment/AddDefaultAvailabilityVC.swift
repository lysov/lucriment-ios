//
//  AddDefaultAvailabilityVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-25.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class AddDefaultAvailabilityVC: UITableViewController {
	
	var isDayPickerOn = false
	var isFromPickerOn = false
	var isToPickerOn = false
	var day: String!
	@IBOutlet weak var dayLabel: UILabel!
	@IBOutlet weak var dayPicker: UIPickerView!
	@IBOutlet weak var fromTimeLabel: UILabel!
	@IBOutlet weak var toTimeLabel: UILabel!
	@IBOutlet weak var fromTimePicker: UIDatePicker!
	@IBOutlet weak var toTimePicker: UIDatePicker!

	let days = [WeekDay.monday.rawValue, WeekDay.tuesday.rawValue, WeekDay.wednesday.rawValue, WeekDay.thursday.rawValue, WeekDay.friday.rawValue, WeekDay.saturday.rawValue, WeekDay.sunday.rawValue]
	var timeslot: Timeslot!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Add Default Availability"
		
		// "Week Day"
		self.day = WeekDay.monday.rawValue
		self.dayLabel.text = WeekDay.monday.rawValue.capitalized
		self.dayPicker.selectRow(0, inComponent: 0, animated: false)
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel))
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.done))
		
		// MARK: Sets pickers
		let from = Calendar.current.date(byAdding: .hour, value: 9, to: Date.init(millisecondsIntUTC: 0))!
		self.fromTimePicker.timeZone = TimeZone(abbreviation: "UTC")
		self.fromTimePicker.setDate(from, animated: false)
		
		// toTimePicker
		let to = Calendar.current.date(byAdding: .hour, value: 17, to: Date.init(millisecondsIntUTC: 0))!
		self.toTimePicker.timeZone = TimeZone(abbreviation: "UTC")
		self.toTimePicker.setDate(to, animated: false)
		
		self.timeslot = Timeslot(from: from, to: to)
		
		// MARK: Sets time labels
		let formatter = DateFormatter()
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.timeStyle = .short
		self.fromTimeLabel.text = formatter.string(from: from)
		self.toTimeLabel.text = formatter.string(from: to)
		
		self.fromTimePicker.addTarget(self, action: #selector(self.fromTimePickerDidChange), for: .valueChanged)
		self.toTimePicker.addTarget(self, action: #selector(self.toTimePickerDidChange), for: .valueChanged)
	}
	
	func fromTimePickerDidChange(datePicker: UIDatePicker) {
		let dateComponents = Calendar.current.dateComponents(in: TimeZone(abbreviation: "UTC")!, from: datePicker.date)
		let hoursAndMinutes = DateComponents(calendar: Calendar.current, timeZone: TimeZone(abbreviation: "UTC")!, era: nil, year: nil, month: nil, day: nil, hour: dateComponents.hour, minute: dateComponents.minute, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
		let from = Calendar.current.date(byAdding: hoursAndMinutes, to: Date.init(millisecondsIntUTC: 0))
		let dayLabelFormatter = DateFormatter()
		dayLabelFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dayLabelFormatter.timeStyle = .short
		if let from = from {
			self.fromTimeLabel.text = dayLabelFormatter.string(from: from)
			self.timeslot.from = from
		}
	}
	
	func toTimePickerDidChange(datePicker: UIDatePicker) {
		let dateComponents = Calendar.current.dateComponents(in: TimeZone(abbreviation: "UTC")!, from: datePicker.date)
		let hoursAndMinutes = DateComponents(calendar: Calendar.current, timeZone: TimeZone(abbreviation: "UTC")!, era: nil, year: nil, month: nil, day: nil, hour: dateComponents.hour, minute: dateComponents.minute, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
		let to = Calendar.current.date(byAdding: hoursAndMinutes, to: Date.init(millisecondsIntUTC: 0))
		let dayLabelFormatter = DateFormatter()
		dayLabelFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dayLabelFormatter.timeStyle = .short
		if let to = to {
			self.toTimeLabel.text = dayLabelFormatter.string(from: to)
			self.timeslot.to = to
		}
	}
	
	func cancel() {
		self.dismiss(animated: true, completion: nil)
	}
	
	func done() {
		
		// saves timeslots to the firebase database
		if !timeslot.isValid {
			self.presentAlert(title: "Invalid Availability", message: nil)
			return
		}
		
		// checks if the tutor's chosen availability conflicts with the existing availability
		if let timeslots =  UserManager.shared.defaultAvailability[self.day] {
			for timeslot in timeslots {
				if !(self.timeslot.to.timeIntervalSince1970 < timeslot.from.timeIntervalSince1970 ||
					self.timeslot.from.timeIntervalSince1970 > timeslot.to.timeIntervalSince1970) {
					self.presentAlert(title: "Invalid Availability", message: "Availability you've choosen overlaps with the existing availability for \(self.day!.capitalized).")
					return
				}
			}
		}
		
		// write availability to firebase database
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE"
		let dayLowercased = self.day.lowercased()
		
		if let availability = self.timeslot, let weekDay = WeekDay(rawValue: dayLowercased) {
			UserManager.shared.uploadDefault(availability, for: weekDay)
		}
		
		self.dismiss(animated: true, completion: nil)
	}
	
	internal func presentAlert(title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}

extension AddDefaultAvailabilityVC {
	
	// MARK:- tableView Data Sourse
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 1 {
			if self.isDayPickerOn {
				self.dayLabel.textColor = LUCColor.blue
				return 216
			} else {
				self.dayLabel.textColor = LUCColor.black
				return 0
			}
		}
		
		if indexPath.row == 3 {
			if self.isFromPickerOn {
				self.fromTimeLabel.textColor = LUCColor.blue
				return 216
			} else {
				self.fromTimeLabel.textColor = LUCColor.black
				return 0
			}
		}
		
		if indexPath.row == 5 {
			if self.isToPickerOn {
				self.toTimeLabel.textColor = LUCColor.blue
				return 216
			} else {
				self.toTimeLabel.textColor = LUCColor.black
				return 0
			}
		}
		
		return super.tableView(tableView, heightForRowAt: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		self.tableView.deselectRow(at: indexPath, animated: true)
		
		if indexPath.row == 0 {
			self.isDayPickerOn = !self.isDayPickerOn
			self.isFromPickerOn = false
			self.isToPickerOn = false
			self.tableView.reloadRows(at: [indexPath], with: .automatic)
			self.tableView.reloadData()
		}
		
		if indexPath.row == 2 {
			self.isDayPickerOn = false
			self.isFromPickerOn = !self.isFromPickerOn
			self.isToPickerOn = false
			self.tableView.reloadRows(at: [indexPath], with: .automatic)
			self.tableView.reloadData()
		}
		
		if indexPath.row == 4 {
			self.isDayPickerOn = false
			self.isFromPickerOn = false
			self.isToPickerOn = !self.isToPickerOn
			self.tableView.reloadRows(at: [indexPath], with: .automatic)
			self.tableView.reloadData()
		}
	}
}

extension AddDefaultAvailabilityVC: UIPickerViewDelegate, UIPickerViewDataSource {
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		self.day = self.days[row]
		self.dayLabel.text = self.days[row].capitalized
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return self.days[row].capitalized
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return self.days.count
	}
}
