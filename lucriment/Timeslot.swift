//
//  Timeslot.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-06-21.
//  Copyright © 2017 Anton Lysov. All rights reserved.
//

import Foundation

struct Timeslot: Equatable {
	
	var from: Date
	var to: Date
	var isValid: Bool {
		get {
			if self.from < self.to {
				return true
			} else {
				return false
			}
		}
	}
	
	static func ==(lhs: Timeslot, rhs: Timeslot) -> Bool {
		if lhs.from == rhs.from, lhs.to == rhs.to {
			return true
		} else {
			return false
		}
	}
	
	func converted(to day: Date) -> Timeslot {
		let from = Date(timeInterval: self.from.timeIntervalSince1970, since: day)
		let to = Date(timeInterval: self.to.timeIntervalSince1970, since: day)
		return Timeslot(from: from, to: to)
	}
	
	func toDictionary() -> [String : Int] {
		var dictionary = [String: Int]()
		dictionary["from"] = Int(self.from.timeIntervalSince1970) * 1_000
		dictionary["to"] = Int(self.to.timeIntervalSince1970) * 1_000
		
		return dictionary
	}
	
	func toString() -> String {
		let dayLabelFormatter = DateFormatter()
		dayLabelFormatter.timeStyle = .short
		return "\(dayLabelFormatter.string(from: from)) - \(dayLabelFormatter.string(from: to))"
	}
	
	func toStringInUTC() -> String {
		let dayLabelFormatter = DateFormatter()
		dayLabelFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dayLabelFormatter.timeStyle = .short
		return "\(dayLabelFormatter.string(from: from)) - \(dayLabelFormatter.string(from: to))"
	}
}
