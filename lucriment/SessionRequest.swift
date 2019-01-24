//
//  SessionRequest.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-01.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation
import FirebaseDatabase

class SessionRequest {
	
	// properties
	static let shared = SessionRequest()
	fileprivate let database = Database.database().reference()
	
	var bookedSessions = [String: [Timeslot]]() // timestamp (the day) - timeslots for that day
	var customAvailability = [String: [(String, Timeslot)]]() // timestamp (the day) - timeslots for that day
	var defaultAvailability = [String: [Timeslot]]()
	
	// fetches tutor's booked sessions
	func fetchBookedSessionsTimeslots(for id: String, _ completion: @escaping (Error?) -> () ) {
		self.database.child("sessions").child(id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				var bookedSessionsTimeslots = [String: [Timeslot]]()
				var sortedBookedSessionsTimeslots = [String: [Timeslot]]()
				
				for sessionsSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
					
					// id "studentId_tutorId" add to the bookedSessionsTimeslots only the timelsots where user was a tutor
					if let sessions = sessionsSnapshot.value as? [String: AnyObject] {
						
						// example: -Ku7ELd48LnfgCtkbXWL
						for (_, session) in sessions {
							let timeslotDictionary = session["time"] as! [String: AnyObject]
							let fromTimeInterval = TimeInterval(timeslotDictionary["from"] as! Int)
							let from = Date(timeIntervalSince1970: fromTimeInterval / 1_000)

							let toTimeInterval = TimeInterval(timeslotDictionary["to"] as! Int)
							let to = Date(timeIntervalSince1970: toTimeInterval / 1_000)

							let timeslot = Timeslot(from: from, to: to)

							let key = String(Int(from.day().timeIntervalSince1970) * 1_000)
							if bookedSessionsTimeslots[key] == nil {
								bookedSessionsTimeslots[key] = [Timeslot]()
							}
							
							let isCancelled = session["sessionCancelled"] as! Bool
							let isDeclined = session["sessionDeclined"] as! Bool
							
							if !(isCancelled) {
								continue
							}
							
							if !(isDeclined) {
								continue
							}
							
							bookedSessionsTimeslots[key]?.append(timeslot)
						}
					}
				}
				
				// sorts default availability in ascending order
				for (key, element) in bookedSessionsTimeslots {
					sortedBookedSessionsTimeslots[key] = element.sorted(by: { $0.from < $1.from })
				}
				
				self.bookedSessions = sortedBookedSessionsTimeslots
				print("booked sessions has been downdloaded")
			}
			completion(nil)
		}
	}
	
	// fetches tutor's custom availability
	func fetchCustomAvailability(for id: String, _ completion: @escaping (Error?) -> () ) {
		
		let customAvailabilityDBRef = self.database.child("tutors").child(id).child("customAvailability")
		customAvailabilityDBRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				var customAvailability = [String: [(String, Timeslot)]]() //day that consists of of list of availabilities for that day
				var sortedCustomAvailability = [String: [(String, Timeslot)]]()
				
				for daySnapshot in snapshot.children.allObjects as! [DataSnapshot] { // going over the days
					
					if let timeslots = daySnapshot.value as? [String: AnyObject] {
						
						for (key, timeslot) in timeslots {
							
							let fromTimeInterval = timeslot["from"] as! Int
							let from = Date(milliseconds: fromTimeInterval)
							
							let toTimeInterval = timeslot["to"] as! Int
							let to = Date(milliseconds: toTimeInterval)
							
							if customAvailability[daySnapshot.key] == nil {
								customAvailability[daySnapshot.key] = [(String, Timeslot)]()
							}
							let timeslotTuple = (key, Timeslot(from: from, to: to))
							customAvailability[daySnapshot.key]?.append(timeslotTuple)
							
							for (key, element) in customAvailability {
								sortedCustomAvailability[key] = element.sorted(by: { $0.1.from < $1.1.from })
							}
						}
					}
				}
				
				self.customAvailability = sortedCustomAvailability
				print("custom availability downdloaded")
			}
			completion(nil)
		}
	}
	
	// fetches tutor's default availability
	func fetchDefaultAvailability(for id: String, _ completion: @escaping (Error?) -> () ) {
		self.database.child("tutors").child(id).child("defaultAvailability").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				var defaultAvailability = [String: [Timeslot]]()
				var sortedDefaultAvailability = [String: [Timeslot]]()
				
				for weekDaySnapshot in snapshot.children.allObjects as! [DataSnapshot] {
					if let timeslots = weekDaySnapshot.value as? [[String: AnyObject]] {
						for timeslot in timeslots {
							print(timeslot)
							let fromTimeInterval = TimeInterval(timeslot["from"] as! Int)
							let from = Date(timeIntervalSince1970: fromTimeInterval / 1_000)
							
							let toTimeInterval = TimeInterval(timeslot["to"] as! Int)
							let to = Date(timeIntervalSince1970: toTimeInterval / 1_000)
							
							let timeslot = Timeslot(from: from, to: to)
							if defaultAvailability[weekDaySnapshot.key] == nil {
								defaultAvailability[weekDaySnapshot.key] = [Timeslot]()
							}
							defaultAvailability[weekDaySnapshot.key]?.append(timeslot)
							
							// sorts default availability in ascending order
							for (key, element) in defaultAvailability {
								sortedDefaultAvailability[key] = element.sorted(by: { $0.from < $1.from })
							}
						}
					}
				}
				self.defaultAvailability = sortedDefaultAvailability
				print("default availability downdloaded")
			}
			completion(nil)
		}
	}
}
