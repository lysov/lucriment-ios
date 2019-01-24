//
//  Session.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-01.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation

struct Session {
	
	var key: String
	
	var confirmed: Bool
	var location: String
	var price: Double
	var sessionCancelled: Bool
	var sessionDeclined: Bool
	var studentId: String
	var studentName: String
	var studentReview: Review?
	var subject: String
	var time: Timeslot
	var tutorId: String
	var tutorName: String
	var tutorReview: Review?
	
	
	init(key: String, confirmed: Bool, location: String, price: Double, sessionCancelled: Bool, sessionDeclined: Bool, studentId: String, studentName: String, subject: String, time: Timeslot, tutorId: String, tutorName: String) {
		
		self.key = key
		
		self.confirmed = confirmed
		self.location = location
		self.price = price
		self.sessionCancelled = sessionCancelled
		self.sessionDeclined = sessionDeclined
		self.studentId = studentId
		self.studentName = studentName
		self.studentReview = nil
		self.subject = subject
		self.time = time
		self.tutorId = tutorId
		self.tutorName = tutorName
		self.tutorReview = nil
		
	}
	
	init(key: String, location: String, price: Double, studentId: String, studentName: String, subject: String, time: Timeslot, tutorId: String, tutorName: String) {
		
		self.key = key
		
		self.confirmed = false
		self.location = location
		self.price = price
		self.sessionCancelled = false
		self.sessionDeclined = false
		self.studentId = studentId
		self.studentName = studentName
		self.studentReview = nil
		self.subject = subject
		self.time = time
		self.tutorId = tutorId
		self.tutorName = tutorName
		self.tutorReview = nil
		
	}
	
	func toDictionary() -> [String : Any] {
		var dictionary = [String: Any]()
		
		dictionary["confirmed"] = self.confirmed
		dictionary["location"] = self.location
		dictionary["price"] = self.price
		dictionary["sessionCancelled"] = self.sessionCancelled
		dictionary["sessionDeclined"] = self.sessionDeclined
		dictionary["studentId"] = self.studentId
		dictionary["studentName"] = self.studentName
		dictionary["subject"] = self.subject
		dictionary["time"] = self.time.toDictionary()
		dictionary["tutorId"] = self.tutorId
		dictionary["tutorName"] = self.tutorName
		
		return dictionary
	}
}
