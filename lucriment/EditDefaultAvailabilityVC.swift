//
//  EditDefaultAvailabilityVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-06-16.
//  Copyright © 2017 Anton Lysov. All rights reserved.
//

import UIKit

class EditDefaultAvailabilityVC: UITableViewController {

	var delegate: DefaultAvailabilityDelegate!
	var isFromPickerOn = false
	var isToPickerOn = false
	var day: String!
	@IBOutlet weak var dayLabel: UILabel!
	@IBOutlet weak var fromTimeLabel: UILabel!
	@IBOutlet weak var toTimeLabel: UILabel!
	@IBOutlet weak var fromTimePicker: UIDatePicker!
	@IBOutlet weak var toTimePicker: UIDatePicker!
	
	var timeslot: Timeslot!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set day label
		let dayLabelFormatter = DateFormatter()
		
		dayLabelFormatter.dateFormat = "EEEE"
		
		// e.g. "Friday"
		self.day = self.delegate.day.rawValue.capitalized
		
		// "Week Day"
		self.dayLabel.text = day
		
		// MARK: Sets pickers
		let from = self.delegate.timeslot.from
		self.fromTimePicker.timeZone = TimeZone(abbreviation: "UTC")
		self.fromTimePicker.setDate(from, animated: false)
		
		// toTimePicker
		let to = self.delegate.timeslot.to
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
	
	func done() {
		// saves timeslots to the firebase database
		if !timeslot.isValid {
			self.presentAlert(title: "Invalid Availability", message: nil)
		}
		
		// checks if the tutor's chosen availability conflicts with the existing availability
		if let timeslots = UserManager.shared.defaultAvailability[self.day.lowercased()] {
			for timeslot in timeslots {
				if !(self.timeslot.to.timeIntervalSince1970 < timeslot.from.timeIntervalSince1970 ||
					self.timeslot.from.timeIntervalSince1970 > timeslot.to.timeIntervalSince1970) {
					
					// checks if altering timeslot
					if !(self.delegate.timeslot == timeslot) {
						self.presentAlert(title: "Invalid Availability", message: "Availability you've choosen overlaps with the existing availability for \(self.day!.capitalized).")
						return
					}
				}
			}
		}
		
		// write availability to firebase database
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE"
		let day = self.delegate.day.rawValue.lowercased()
		
		// remove alterd default availability from the model
		_ = UserManager.shared.defaultAvailability[day]!.index(of: self.delegate.timeslot).map {
			UserManager.shared.defaultAvailability[day]!.remove(at: $0)
		}
		// add the new availability
		UserManager.shared.defaultAvailability[day]!.append(self.timeslot)
		// update availability for the whole day
		UserManager.shared.updateDefaultAvailability(for: self.delegate.day)
		
		self.dismiss(animated: true, completion: nil)
	}
	
	internal func presentAlert(title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}

extension EditDefaultAvailabilityVC {

// MARK:- tableView Data Sourse

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 2 {
			if self.isFromPickerOn {
				return 216
			} else {
				return 0
			}
		}
		
		if indexPath.row == 4 {
			if self.isToPickerOn {
				return 216
			} else {
				return 0
			}
		}
		
		return super.tableView(tableView, heightForRowAt: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 1 {
			self.tableView.deselectRow(at: indexPath, animated: true)
			self.isFromPickerOn = !self.isFromPickerOn
			self.isToPickerOn = false
			self.tableView.reloadRows(at: [indexPath], with: .automatic)
			self.tableView.reloadData()
		}
		
		if indexPath.row == 3 {
			self.tableView.deselectRow(at: indexPath, animated: true)
			self.isFromPickerOn = false
			self.isToPickerOn = !self.isToPickerOn
			self.tableView.reloadRows(at: [indexPath], with: .automatic)
			self.tableView.reloadData()
		}
	}
}
