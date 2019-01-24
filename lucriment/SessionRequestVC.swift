//
//  SessionRequestVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-01.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import JTAppleCalendar

protocol SessionRequestDetailsDelegate {
	
	var tutor: Tutor! { get }
	var timeslot: Timeslot! { get }
	var subject: String! { get set }
	
}

class SessionRequestVC: UIViewController, SelectedDayDelegate, SessionRequestDetailsDelegate {
	
	// Calendar
	@IBOutlet weak var monthLabel: UILabel!
	@IBOutlet weak var calendarView: JTAppleCalendarView!
	
	// CollectionView
	@IBOutlet weak var setSessionTimeLabel: UILabel!
	@IBOutlet weak var timesCollectionView: UICollectionView!
	
	// Buttons View
	@IBOutlet weak var button: UIButton!
	@IBOutlet weak var buttonsView: UIView!
	
	var delegate: TutorDelegate!
	var selectedDay: Date!
	var today: Date!
	var availability = [Timeslot]()
	// "from"
	var fromTimes = [String]() // "18:15" etc.
	var fromBookedSessionsTimes = [String]()
	var pastSessionsTimes = [String]()
	var selectedFromTime = ""
	// "to"
	var isToTimesShowing = false
	var toTimes = [String]() // "19:15" etc.
	var toBookedSessionsTimes = [String]()
	var selectedToTime = ""
	// SessionRequestDetailsDelegate
	var tutor: Tutor!
	var timeslot: Timeslot!
	var subject: String!
	
	
	
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.selectedDay = Date()
		self.today = selectedDay.day()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupCalendar()
		self.buttonsView.layer.cornerRadius = 20
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		
		DispatchQueue.main.async {
			
			// Download tutor's booked sessions
			SessionRequest.shared.fetchBookedSessionsTimeslots(for: self.delegate.tutor.id) { (error) in
				if let error = error {
					print(error.localizedDescription)
				}
				
				// Download tutor's default availability
				SessionRequest.shared.fetchDefaultAvailability(for: self.delegate.tutor.id) { (error) in
					if let error = error {
						print(error.localizedDescription)
					}
					
					// Download tutor's custom availability
					SessionRequest.shared.fetchCustomAvailability(for: self.delegate.tutor.id) { (error) in
						if let error = error {
							print(error.localizedDescription)
						}
						
						self.configureFromTimes(for: self.selectedDay)
						self.timesCollectionView.reloadData()
						self.calendarView.reloadData()
					}
				}
			}
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.setSessionTimeLabel.text = "Set Session Start Time"
		self.isToTimesShowing = false
		self.selectedFromTime = ""
		self.selectedToTime = ""
		self.buttonsView.backgroundColor = LUCColor.gray
		self.button.isEnabled = false
		
		self.configureFromTimes(for: self.selectedDay)
		self.timesCollectionView.reloadData()
	}

	@IBAction func buttonDidPress(_ sender: Any) {
		if isToTimesShowing {
			self.tutor = self.delegate.tutor
			
			// configure timeslot
			
			// "from"
			let numberOfFromHours = self.selectedFromTime.substring(from: 0, to: self.selectedFromTime.index(of: ":")! - 1)
			let numberOfFromMinutes = self.selectedFromTime.substring(from: self.selectedFromTime.index(of: ":")! + 1, to: self.selectedFromTime.characters.count)
			var from = Calendar.current.date(byAdding: .hour, value: Int(numberOfFromHours)!, to: self.selectedDay)
			from = Calendar.current.date(byAdding: .minute, value: Int(numberOfFromMinutes)!, to: from!)!
			
			// "to"
			let numberOfToHours = self.selectedToTime.substring(from: 0, to: self.selectedToTime.index(of: ":")! - 1)
			let numberOfToMinutes = self.selectedToTime.substring(from: self.selectedToTime.index(of: ":")! + 1, to: self.selectedToTime.characters.count)
			var to = Calendar.current.date(byAdding: .hour, value: Int(numberOfToHours)!, to: self.selectedDay)
			to = Calendar.current.date(byAdding: .minute, value: Int(numberOfToMinutes)!, to: to!)!
			
			self.timeslot = Timeslot(from: from!, to: to!)
			
			self.presentSessionRequestDetailsVC()
		} else {
			self.setSessionTimeLabel.text = "Set Session End Time"
			self.isToTimesShowing = true
			self.configureToTimes()
			self.buttonsView.backgroundColor = LUCColor.gray
			self.button.isEnabled = false
			self.timesCollectionView.reloadData()
		}
	}
}


// MARK:- "from"
extension SessionRequestVC {
	
	/**
	Configures "from" times for the selected day.
	
	- parameter day: A selected day.
	*/
	func configureFromTimes(for day: Date) {
		
		let dayString = String(Int(self.selectedDay.timeIntervalSince1970) * 1_000)
		self.availability = [Timeslot]()
		
		// check custom availability
		if let customAvailability = SessionRequest.shared.customAvailability[dayString] {
			for (_, timeslot) in customAvailability {
				self.availability.append(timeslot)
			}
		} else {
			
			// check default availability
			
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
			
			if let defaultAvailability = SessionRequest.shared.defaultAvailability[weekDay] {
				for timeslot in defaultAvailability {
					self.availability.append(timeslot.converted(to: self.selectedDay))
				}
			}
			
		}
		
		// configure "from" times
		self.fromTimes = [String]()
		for timeslot in self.availability {
			self.configureFromTimes(for: timeslot)
		}
		
		// configure "from" booked sessions times
		self.fromBookedSessionsTimes = [String]()
		if let bookedSessions = SessionRequest.shared.bookedSessions[dayString] {
			for timeslot in bookedSessions {
				self.configureFromBookedSessionsTimes(for: timeslot)
			}
		}
		
		// exclude "from" booked sessions times from "from" times
		if self.fromBookedSessionsTimes.count != 0 {
			
			var times = [String]()
			
			for time in self.fromTimes {
				if !self.fromBookedSessionsTimes.contains(time) {
					times.append(time)
				}
			}
			self.fromTimes = times
		}
		
		// configure "from" past sessions times
		let now = Date()
		self.pastSessionsTimes = [String]()
		if day == now.day() {
			self.configurePastSessionsTimes(for: now)
			
			// exclude "from" past sessions times from "from" times
			if self.pastSessionsTimes.count != 0 {
				
				var times = [String]()
				
				for time in self.fromTimes {
					if !self.pastSessionsTimes.contains(time) {
						times.append(time)
					}
				}
				self.fromTimes = times
			}
		}
	}
	
	func configureFromTimesForDots(for day: Date) {
		
		let dayString = String(Int(day.timeIntervalSince1970) * 1_000)
		self.availability = [Timeslot]()
		
		// check custom availability
		if let customAvailability = SessionRequest.shared.customAvailability[dayString] {
			for (_, timeslot) in customAvailability {
				self.availability.append(timeslot)
			}
		} else {
			
			// check default availability
			
			var weekDay = ""
			let weekDayInt = Calendar.current.dateComponents([.weekday], from: day).weekday!
			
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
			
			if let defaultAvailability = SessionRequest.shared.defaultAvailability[weekDay] {
				for timeslot in defaultAvailability {
					self.availability.append(timeslot.converted(to: self.selectedDay))
				}
			}
			
		}
		
		// configure "from" times
		self.fromTimes = [String]()
		for timeslot in self.availability {
			self.configureFromTimes(for: timeslot)
		}
		
		// configure "from" booked sessions times
		self.fromBookedSessionsTimes = [String]()
		if let bookedSessions = SessionRequest.shared.bookedSessions[dayString] {
			for timeslot in bookedSessions {
				self.configureFromBookedSessionsTimes(for: timeslot)
			}
		}
		
		// exclude "from" booked sessions times from "from" times
		if self.fromBookedSessionsTimes.count != 0 {
			
			var times = [String]()
			
			for time in self.fromTimes {
				if !self.fromBookedSessionsTimes.contains(time) {
					times.append(time)
				}
			}
			self.fromTimes = times
		}
	}
	
	func configureFromTimes(for timeslot: Timeslot) {
		
		let calendar = Calendar.current
		
		var fromHour = calendar.component(.hour, from: timeslot.from)
		var fromMinute = calendar.component(.minute, from: timeslot.from)
		let toHour = calendar.component(.hour, from: timeslot.to)
		let toMinute = calendar.component(.minute, from: timeslot.to)
		
		let fromTotalMinute = fromHour * 60 + fromMinute
		let toTotalMinute = toHour * 60 + toMinute
		let timeDifference = toTotalMinute - fromTotalMinute
		
		var numberOfFromTimes = (timeDifference - 60) / 15
		
		while (numberOfFromTimes >= 0) {
			
			var time = ""
			
			if (fromMinute < 45) {
				
				if (fromMinute == 0) {
					time = "\((fromHour)):00"
				} else {
					time = "\(fromHour):\(fromMinute)"
				}
				
				self.fromTimes.append(time)
				fromMinute += 15
				
			} else {
				time = "\(fromHour):\(fromMinute)"
				self.fromTimes.append(time)
				fromMinute = 0
				fromHour += 1
			}
			
			numberOfFromTimes -= 1
		}
		
		self.fromTimes = self.fromTimes.sorted { Int($0.replacingOccurrences(of: ":", with: ""))! < Int($1.replacingOccurrences(of: ":", with: ""))! }
	}
	
	func configureFromBookedSessionsTimes(for timeslot: Timeslot) {
		
		let calendar = Calendar.current
		
		var fromHour = calendar.component(.hour, from: timeslot.from)
		var fromMinute = calendar.component(.minute, from: timeslot.from)
		let toHour = calendar.component(.hour, from: timeslot.to)
		let toMinute = calendar.component(.minute, from: timeslot.to)
		
		if (fromMinute != 45) {
			fromHour -= 1
			fromMinute += 15
		} else {
			fromMinute = 0
		}
		
		let fromTotalMinute = fromHour * 60 + fromMinute
		let toTotalMinute = toHour * 60 + toMinute
		let timeDifference = toTotalMinute - fromTotalMinute
		
		var numberOfFromTimes = (timeDifference) / 15
		
		while (numberOfFromTimes >= 0) {
			
			var time = ""
			
			if (fromMinute < 45) {
				if (fromMinute == 0) {
					time = "\(fromHour):00"
				} else {
					time = "\(fromHour):\(fromMinute)"
				}
				self.fromBookedSessionsTimes.append(time)
				fromMinute += 15
			} else {
				time = "\(fromHour):\(fromMinute)"
				self.fromBookedSessionsTimes.append(time)
				fromMinute = 0
				fromHour += 1
			}
			
			numberOfFromTimes -= 1
		}
	}
	
	func configurePastSessionsTimes(for now: Date) {
		let calendar = Calendar.current
		
		var fromHour = 0
		var fromMinute = 0
		let toHour = calendar.component(.hour, from: now)
		let toMinute = calendar.component(.minute, from: now)
		
		let toTotalMinute = toHour * 60 + toMinute
		
		var numberOfFromTimes = toTotalMinute / 15
		
		while (numberOfFromTimes >= 0) {
			
			var time = ""
			
			if (fromMinute < 45) {
				if (fromMinute == 0) {
					time = "\(fromHour):00"
				} else {
					time = "\(fromHour):\(fromMinute)"
				}
				self.pastSessionsTimes.append(time)
				fromMinute += 15
			} else {
				time = "\(fromHour):\(fromMinute)"
				self.pastSessionsTimes.append(time)
				fromMinute = 0
				fromHour += 1
			}
			
			numberOfFromTimes -= 1
		}
	}
}

// MARK:- "to"
extension SessionRequestVC {
	
	/**
	Configures "to" times for the selected day.
	
	- parameter day: A selected day.
	*/
	func configureToTimes() {
		self.toTimes = [String]()
		var fromTime = self.selectedFromTime
		let hour = fromTime.substring(from: 0, to: fromTime.index(of: ":")! - 1)
		let minute = fromTime.substring(from: fromTime.index(of: ":")! + 1, to: fromTime.characters.count)
		let fromMinute = Int(minute)!
		let fromHour = Int(hour)!
		let timeValue = fromHour * 60 + fromMinute
		
		// gets the timeslots that has ...
		var selectedTimeslot: Timeslot!
		let calendar = Calendar.current
		
		for timeslot in self.availability {
			
			let from = calendar.component(.hour, from: timeslot.from) * 60 + calendar.component(.minute, from: timeslot.from)
			let to = calendar.component(.hour, from: timeslot.to) * 60 + calendar.component(.minute, from: timeslot.to)
			
			if (timeValue >= from && timeValue <= to) {
				selectedTimeslot = timeslot
			}
		}
		
		let endTotal = calendar.component(.hour, from: selectedTimeslot.to) * 60 + calendar.component(.minute, from: selectedTimeslot.to)
		var toMinute = calendar.component(.minute, from: selectedTimeslot.to)
		var toHour = calendar.component(.hour, from: selectedTimeslot.to)
		let timeDifference = endTotal - timeValue
		var numberOfToTimes = (timeDifference - 60) / 15
		
		while (numberOfToTimes >= 0) {
			
			var time = ""
			
			if (toMinute == 0) {
				time = "\(toHour):00"
				toHour -= 1
				toMinute = 45
			} else {
				time = "\(toHour):\(toMinute)"
				toMinute -= 15
			}
			
			self.toTimes.append(time)
			
			numberOfToTimes -= 1
			
		}
		
		// configure "to" booked sessions times
		let day = String(Int(self.selectedDay.timeIntervalSince1970) * 1_000)
		self.toBookedSessionsTimes = [String]()
		if let bookedSessions = SessionRequest.shared.bookedSessions[day] {
			for timeslot in bookedSessions {
				self.configureToBookedSessionsTimes(for: timeslot)
			}
		}
		
		// exclude "to" booked sessions times from "from" times
		if self.toBookedSessionsTimes.count != 0 {
			
			var times = [String]()
			
			for time in self.toTimes {
				if !self.toBookedSessionsTimes.contains(time) {
					times.append(time)
				}
			}
			self.toTimes = times
		}
		
		self.toTimes = self.toTimes.sorted { Int($0.replacingOccurrences(of: ":", with: ""))! < Int($1.replacingOccurrences(of: ":", with: ""))! }
	}
	
	func configureToBookedSessionsTimes(for timeslot: Timeslot) {
		
		let calendar = Calendar.current
		
		var fromHour = calendar.component(.hour, from: timeslot.from)
		var fromMinute = calendar.component(.minute, from: timeslot.from)
		let toHour = calendar.component(.hour, from: timeslot.to)
		let toMinute = calendar.component(.minute, from: timeslot.to)
		
		if (fromMinute != 45) {
			
			fromMinute += 15
		} else {
			fromMinute = 0
			fromHour += 1
		}
		
		let fromTotal = fromHour * 60 + fromMinute
		let toTotal = toHour * 60 + toMinute
		let timeDifference = toTotal - fromTotal
		var numberOfToTimes = (timeDifference) / 15
		
		while (numberOfToTimes >= 0) {
			
			var time = ""
			
			if (fromMinute < 45) {
				if (fromMinute == 0) {
					time = "\(fromHour):00"
				} else {
					time = "\(fromHour):\(fromMinute)"
				}
				self.toBookedSessionsTimes.append(time)
				fromMinute += 15
			} else {
				time = "\(fromHour):\(fromMinute)"
				self.toBookedSessionsTimes.append(time)
				fromMinute = 0
				fromHour += 1
			}
			
			numberOfToTimes -= 1
		}
	}
}

// MARK: - UICollectionViewDataSource
extension SessionRequestVC: UICollectionViewDataSource, UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		if self.isToTimesShowing {
			return self.toTimes.count
		}
		
		return self.fromTimes.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "time", for: indexPath) as! TimeCell
		
		// Configure the cell
		if self.isToTimesShowing {
			cell.timeLabel.text = self.toTimes[indexPath.row]
		} else {
			cell.timeLabel.text = self.fromTimes[indexPath.row]
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if isToTimesShowing {
			let cell = collectionView.cellForItem(at: indexPath) as! TimeCell
			self.selectedToTime = cell.timeLabel.text!
			
			self.buttonsView.backgroundColor = LUCColor.red
			self.button.isEnabled = true
		} else {
			
			// save "from" time and show "to" times
			let cell = collectionView.cellForItem(at: indexPath) as! TimeCell
			self.selectedFromTime = cell.timeLabel.text!
			
			self.buttonsView.backgroundColor = LUCColor.red
			self.button.isEnabled = true
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		self.buttonsView.backgroundColor = LUCColor.gray
		self.button.isEnabled = false
	}
}

// MARK: - Setup the Calendar
extension SessionRequestVC {
	
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
		cell.hasAvailabilityView.isHidden = true
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
		
		// put the dots
		
		let cellTextColor = cell.dateLabel.textColor
		
		if cellTextColor == LUCColor.red || cellTextColor == UIColor.white || cellTextColor == LUCColor.black {
			self.configureFromTimesForDots(for: cellState.date)
			if self.fromTimes.count != 0 {
				cell.hasAvailabilityView.isHidden = false
			}
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

extension SessionRequestVC: JTAppleCalendarViewDataSource {
	
	func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy MM dd"
		formatter.timeZone = Calendar.current.timeZone
		formatter.locale = Calendar.current.locale
		
		// the month (current) to schedule a session that gonna be shown on user device
		let startDateComponents = Calendar.current.dateComponents([.era, .year, .month, .day, .hour, .minute, .second, .nanosecond, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear, .yearForWeekOfYear], from: self.selectedDay)
		
		let startDate = Calendar.current.date(from: startDateComponents)
		
		// interval is 6 months
		let interval = DateComponents(month: 5)
		
		let endDate = Calendar.current.date(byAdding: interval, to: startDate!)!.endOfMonth()
		return ConfigurationParameters.init(startDate: startDate!, endDate: endDate, generateOutDates: .tillEndOfRow, firstDayOfWeek: .monday)
	}
}

extension SessionRequestVC: JTAppleCalendarViewDelegate {
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
		
		self.setSessionTimeLabel.text = "Set Session Start Time"
		self.isToTimesShowing = false
		self.buttonsView.backgroundColor = LUCColor.gray
		self.button.isEnabled = false
		
		self.configureFromTimes(for: selectedDay)
		self.timesCollectionView.reloadData()
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

extension SessionRequestVC {
	// presents SessionRequestDetailsVC
	fileprivate func presentSessionRequestDetailsVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentSearch", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "SessionRequestDetailsController") as! SessionRequestDetailsController
		vc.delegate = self as SessionRequestDetailsDelegate
		self.navigationController?.pushViewController(vc, animated: true)
	}
}
