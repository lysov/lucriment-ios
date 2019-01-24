//
//  AddCustomAvailabilityVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-28.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class AddCustomAvailabilityVC: UITableViewController {

	var isFromPickerOn = false
	var isToPickerOn = false
	var delegate: SelectedDayDelegate!
	
	var timeslot: Timeslot!
	
	@IBOutlet weak var dayLabel: UILabel!
	@IBOutlet weak var fromTimeLabel: UILabel!
	@IBOutlet weak var toTimeLabel: UILabel!
	@IBOutlet weak var fromTimePicker: UIDatePicker!
	@IBOutlet weak var toTimePicker: UIDatePicker!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Add Availability"
		
		let dayLabelFormatter = DateFormatter()
		dayLabelFormatter.dateFormat = "EEEE, MMM d"
		print(dayLabelFormatter.string(from: delegate.selectedDay))
		self.dayLabel.text = dayLabelFormatter.string(from: delegate.selectedDay)
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel))
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.done))
		
		// MARK: Sets pickers
		let from = Calendar.current.date(byAdding: .hour, value: 9, to: self.delegate.selectedDay)!
		self.fromTimePicker.setDate(from, animated: false)
		
		// toTimePicker
		let to = Calendar.current.date(byAdding: .hour, value: 17, to: self.delegate.selectedDay)!
		self.toTimePicker.setDate(to, animated: false)
		
		self.timeslot = Timeslot(from: from, to: to)
		
		// MARK: Sets time labels
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		self.fromTimeLabel.text = formatter.string(from: from)
		self.toTimeLabel.text = formatter.string(from: to)
		
		self.fromTimePicker.addTarget(self, action: #selector(self.fromTimePickerDidChange), for: .valueChanged)
		self.toTimePicker.addTarget(self, action: #selector(self.toTimePickerDidChange), for: .valueChanged)
    }
	
	func fromTimePickerDidChange(datePicker: UIDatePicker) {
		
		let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: datePicker.date)
		let from = Calendar.current.date(byAdding: dateComponents, to: self.delegate.selectedDay)
		let dayLabelFormatter = DateFormatter()
		dayLabelFormatter.timeStyle = .short
		if let from = from {
			self.fromTimeLabel.text = dayLabelFormatter.string(from: from)
			self.timeslot.from = from
		}
	}
	
	func toTimePickerDidChange(datePicker: UIDatePicker) {
		
		let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: datePicker.date)
		let to = Calendar.current.date(byAdding: dateComponents, to: self.delegate.selectedDay)
		let dayLabelFormatter = DateFormatter()
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
		
		let day = "\(Int(self.delegate.selectedDay.timeIntervalSince1970) * 1_000)"
		
		// checks if the tutor's chosen availability conflicts with the existing availability
		if let timeslots = UserManager.shared.customAvailability[day] {
			for (_, timeslot) in timeslots {
				if !(self.timeslot.to.timeIntervalSince1970 < timeslot.from.timeIntervalSince1970 ||
					self.timeslot.from.timeIntervalSince1970 > timeslot.to.timeIntervalSince1970) {
					let dayLabelFormatter = DateFormatter()
					dayLabelFormatter.dateFormat = "EEEE"
					self.presentAlert(title: "Invalid Availability", message: "Availability you've choosen overlaps with the existing availability for \(dayLabelFormatter.string(from: self.delegate.selectedDay)).")
					return
				}
			}
		} else {
			// checks if the tutor's chosen availability conflicts with the existing availability
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "EEEE"
			let weekDay = dateFormatter.string(from: self.delegate.selectedDay).lowercased()
			
			if let timeslots = UserManager.shared.defaultAvailability[weekDay] {
				
				for timeslot in timeslots {
					
					var dateComponents = Calendar.current.dateComponents(in: TimeZone(abbreviation: "UTC")!, from: timeslot.from)
					var hoursAndMinutes = DateComponents(calendar: Calendar.current, timeZone: TimeZone(abbreviation: "UTC")!, era: nil, year: nil, month: nil, day: nil, hour: dateComponents.hour, minute: dateComponents.minute, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
					let from = Calendar.current.date(byAdding: hoursAndMinutes, to: self.delegate.selectedDay)!
					
					dateComponents = Calendar.current.dateComponents(in: TimeZone(abbreviation: "UTC")!, from: timeslot.to)
					hoursAndMinutes = DateComponents(calendar: Calendar.current, timeZone: TimeZone(abbreviation: "UTC")!, era: nil, year: nil, month: nil, day: nil, hour: dateComponents.hour, minute: dateComponents.minute, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
					let to = Calendar.current.date(byAdding: hoursAndMinutes, to: self.delegate.selectedDay)!
					let DBTimeslot = Timeslot(from: from, to: to)
					
					if !(self.timeslot.to.timeIntervalSince1970 < DBTimeslot.from.timeIntervalSince1970 ||
						self.timeslot.from.timeIntervalSince1970 > DBTimeslot.to.timeIntervalSince1970) {
						let dayLabelFormatter = DateFormatter()
						dayLabelFormatter.dateFormat = "EEEE"
						self.presentAlert(title: "Invalid Availability", message: "Availability you've choosen overlaps with the existing availability for \(dayLabelFormatter.string(from: self.delegate.selectedDay)).")
						return
					}
				}
			}
		}

		if let availability = self.timeslot {
			UserManager.shared.uploadCustom(availability, for: self.delegate.selectedDay)
		}

		self.dismiss(animated: true, completion: nil)
	}
	
	internal func presentAlert(title: String, message: String?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}

extension AddCustomAvailabilityVC {
	
	// MARK:- tableView Data Sourse
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		if indexPath.row == 2 {
			if self.isFromPickerOn {
				self.fromTimeLabel.textColor = LUCColor.blue
				return 216
			} else {
				self.fromTimeLabel.textColor = LUCColor.black
				return 0
			}
		}
		
		if indexPath.row == 4 {
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
		
		if indexPath.row == 1 {
			self.isFromPickerOn = !self.isFromPickerOn
			self.isToPickerOn = false
			self.tableView.reloadRows(at: [indexPath], with: .automatic)
			self.tableView.reloadData()
		}
		
		if indexPath.row == 3 {
			self.isFromPickerOn = false
			self.isToPickerOn = !self.isToPickerOn
			self.tableView.reloadRows(at: [indexPath], with: .automatic)
			self.tableView.reloadData()
		}
	}
}
