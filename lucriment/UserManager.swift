//
//  UserManager.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-31.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

enum UserType: String {
	case student
	case tutor
}

class UserManager {
	
	// properties
	static let shared = UserManager()
	fileprivate let database = Database.database().reference()
	fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
	fileprivate let firebaseAuth = Auth.auth()

	var mode: UserType = .student
	var cashedProfileImage = NSCache<NSString, UIImage>()
	
	// user properties
	var id: String!
	var email: String!
	var favourites: [String]!
	var firstName: String!
	var fullName: String!
	var headline: String!
	var lastName: String!
	var profileImage: String!
	var userType: UserType?
	
	// tutor properties
	var address: String!
	var about: String!
	var customAvailability = [String: [(String, Timeslot)]]() // timestamp (the day) - timeslots for that day
	var defaultAvailability = [String: [Timeslot]]()
	var tutorHeadline: String!
	var phoneNumber: String!
	var postalCode: String!
	var rate: Int!
	var rating: Double!
	var subjects: [String]!
	
	var isTutor: Bool!
	
	fileprivate init() {
		// listens to sign in state
		Auth.auth().addStateDidChangeListener { auth, user in
			if let user = user {
				self.id = user.uid
				self.userType = .student
				if let deviceToken = Messaging.messaging().fcmToken {
					self.updateCurrent(.student, with: ["deviceToken": deviceToken], { (error) in })
				}
				self.appDelegate.presentStudentTabBarController()
			} else {
				self.id = nil
				self.appDelegate.presentInitialVC()
			}
		}
	}
}

// MARK:- Methods for current user
extension UserManager {
	
	// refreshes info of the current user (student or tutor)
	func refresh(_ completion: @escaping (_ error: Error?) -> () ) {
		switch self.mode {
			
		case .student:
			self.database.child("users").child(self.id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
				if let data = snapshot.value as? [String:Any] {
					if let email = data["email"] as? String {
						self.email = email
					}
					if let favourites = data["favourites"] as? [String] {
						self.favourites = favourites
					}
					if let firstName = data["firstName"] as? String {
						self.firstName = firstName
					}
					if let fullName = data["fullName"] as? String {
						self.fullName = fullName
					}
					if let headline = data["headline"] as? String {
						self.headline = headline
					}
					if let lastName = data["lastName"] as? String {
						self.lastName = lastName
					}
					if let profileImage = data["profileImage"] as? String {
						self.profileImage = profileImage
					}
					if let userType = data["userType"] as? String {
						self.userType = UserType(rawValue: userType)
					}
					self.database.child("tutors").child(self.id).child("stripe_connected").child("tos_acceptance").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
						if snapshot.exists() {
							self.isTutor = true
							completion(nil)
						} else {
							self.isTutor = false
							completion(nil)
						}
					}
				} else {
					completion(UserManagerError.firebase)
				}
			}
			
		case .tutor:
			self.database.child("tutors").child(self.id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
				if let data = snapshot.value as? [String:Any] {
					if let address = data["address"] as? String {
						self.address = address
					}
					if let about = data["about"] as? String {
						self.about = about
					}
					if let email = data["email"] as? String {
						self.email = email
					}
					if let firstName = data["firstName"] as? String {
						self.firstName = firstName
					}
					if let fullName = data["fullName"] as? String {
						self.fullName = fullName
					}
					if let headline = data["headline"] as? String {
						self.tutorHeadline = headline
					}
					if let lastName = data["lastName"] as? String {
						self.lastName = lastName
					}
					if let phoneNumber = data["phoneNumber"] as? String {
						self.phoneNumber = phoneNumber
					}
					if let postalCode = data["postalCode"] as? String {
						self.postalCode = postalCode
					}
					if let rate = data["rate"] as? Int {
						self.rate = rate
					}
					if let profileImage = data["profileImage"] as? String {
						self.profileImage = profileImage
					}
					// parse subjects
					self.subjects = [String]()
					for (key, value) in data {
						if value is Bool {
							if value as! Bool == true {
								self.subjects.append(key)
							}
						}
					}
					if let userType = data["userType"] as? String {
						self.userType = UserType(rawValue: userType)
					}
					completion(nil)
				} else {
					completion(UserManagerError.firebase)
				}
			}
		}
	}
	
	func addToSaved(_ id: String, _ completion: @escaping (Error?) -> ()) {
		self.database.child("users").child(self.id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if let data = snapshot.value as? [String:Any] {
				
				// add to existing list of saved tutors
				if let favourites = data["favourites"] as? [String] {
					var updatedFavourites = favourites
					updatedFavourites.append(id)
					UserManager.shared.updateCurrent(.student, with: ["favourites": updatedFavourites]) { (error) in
						if let error = error {
							completion(error)
						} else {
							UserManager.shared.favourites = updatedFavourites
							completion(nil)
						}
					}
				// add to the first tutor to saved tutors
				} else {
					UserManager.shared.updateCurrent(.student, with: ["favourites": [id]]) { (error) in
						if let error = error {
							completion(error)
						} else {
							UserManager.shared.favourites = [id]
							completion(nil)
						}
					}
				}
			}
		}
	}
	
	func removeFromSaved(_ id: String, _ completion: @escaping (Error?) -> ()) {
		self.database.child("users").child(self.id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				if let data = snapshot.value as? [String:Any] {
					if let favourites = data["favourites"] as? [String] {
						if favourites.contains(id) {
							var updatedFavourites = favourites
							_ = updatedFavourites.index(of: id).map { updatedFavourites.remove(at: $0) }
							UserManager.shared.updateCurrent(.student, with: ["favourites": updatedFavourites]) { (error) in
								if let error = error {
									completion(error)
								} else {
									UserManager.shared.favourites = updatedFavourites
									completion(nil)
								}
							}
						}
					}
				}
			} else {
				completion(nil)
			}
		}
	}
	
	func updateStripePayoutInfo(with value: [String: Any], _ completion: @escaping (_ error: Error?) -> () ) {
		self.database.child("tutors").child(self.id).child("stripe_connected").child("update").setValue(value) { (error, ref) in
			if let error = error {
				print(error.localizedDescription)
				completion(UserManagerError.firebase)
			} else {
				completion(nil)
			}
		}
	}
	
	// updates a specific property of the current user in the database
	func updateCurrent(_ user: UserType, with values: [String: Any], _ completion: @escaping (_ error: Error?) -> () ) {
		switch user {
		case .student:
			self.database.child("users").child(self.id).updateChildValues(values) { (error, ref) in
				if let error = error {
					print(error.localizedDescription)
					completion(UserManagerError.firebase)
				} else {
					completion(nil)
				}
			}
		case .tutor:
			self.database.child("tutors").child(self.id).updateChildValues(values) { (error, ref) in
				if let error = error {
					print(error.localizedDescription)
					completion(UserManagerError.firebase)
				} else {
					completion(nil)
				}
			}
		}
	}
}

// MARK:- Methods for new users
extension UserManager {
	
	// adds tutor to the database
	func addTutor(_ completion: @escaping (Error?) -> ()) {
		var tutor = [String: String]()
		if let email = self.email, let firstName = self.firstName, let fullName = self.fullName, let lastName = self.lastName {
			tutor["email"] = email
			tutor["firstName"] = firstName
			tutor["fullName"] = fullName
			tutor["lastName"] = lastName
		} else {
			self.refresh { (error) in
				if error == nil {
					tutor["email"] = self.email
					tutor["firstName"] = self.firstName
					tutor["fullName"] = self.fullName
					tutor["lastName"] = self.lastName
					tutor["id"] = self.id
					tutor["userType"] = "tutor"
					
					self.database.child("tutors").child(self.id).updateChildValues(tutor) { (error, ref) in
						if error != nil {
							completion(UserManagerError.firebase)
						} else {
							completion(nil)
						}
					}
				}
			}
		}
		
		tutor["id"] = id
		tutor["userType"] = "tutor"
		
		self.database.child("tutors").child(id).updateChildValues(tutor) { (error, ref) in
			if error != nil {
				completion(UserManagerError.firebase)
			} else {
				completion(nil)
			}
		}
	}
	
	// adds user to the database
	func addUser(withEmail: String, firstName: String, fullName: String, id: String, lastName: String) {
		var user: [String:Any] = [:]
		user["email"] = withEmail
		user["firstName"] = firstName
		user["fullName"] = fullName
		user["id"] = id
		user["lastName"] = lastName
		user["userType"] = "student"
		self.database.child("users").child(id).setValue(user)
		print("user profile has been created in the database")
	}
	
	// TODO: check if user has a snapshot under "users"
	func userExists(_ completion: @escaping (Bool) -> ()) {
		self.database.child("users").child(self.id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				completion(true)
			} else{
				completion(false)
			}
		}
	}
}

extension UserManager {
	
	// MARK:- Methods for tutor availability
	
	// fetches tutor's custom availability
	func fetchCustomAvailability(_ completion: @escaping (Error?) -> () ) {
		
		let customAvailabilityDBRef = self.database.child("tutors").child(self.id).child("customAvailability")
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
	
	// uploads custom availability and adds default availability to custom availability
	func uploadCustom(_ availability: Timeslot, for: Date) {
		
		// check if there's custom availability for that day, if so, then checking for the default is unneccessary
		let day = availability.from.day()
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
		
		if UserManager.shared.customAvailability.keys.contains("\(Int(day.timeIntervalSince1970 * 1_000))") {
			
			let databaseRef = self.database.child("tutors").child(self.id).child("customAvailability").child("\(Int(day.timeIntervalSince1970 * 1_000))").childByAutoId()
			
			databaseRef.setValue(availability.toDictionary())
			
		} else {
			
			let databaseRef = self.database.child("tutors").child(self.id).child("customAvailability").child("\(Int(day.timeIntervalSince1970 * 1_000))")
			
			// write custom availability
			databaseRef.childByAutoId().setValue(availability.toDictionary())
			
			// checks if there's default availability for that weekDay
			if UserManager.shared.defaultAvailability.keys.contains(weekDay) {
				
				let databaseRef = self.database.child("tutors").child(self.id).child("customAvailability").child("\(Int(day.timeIntervalSince1970 * 1_000))")
				
				for availability in UserManager.shared.defaultAvailability[weekDay]! {
					let convertedAvailability = availability.converted(to: day)
					databaseRef.childByAutoId().setValue(convertedAvailability.toDictionary())
				}
			}
		}
	}
	
	// uploads custom availability and adds the rest of the default availabilities to custom availability
	func editCustom(_ availability: Timeslot, key: String?, defaultAvailabilities: [Timeslot]?, for: Date) {
		
		let day = availability.from.day()
		
		let databaseRef = self.database.child("tutors").child(self.id).child("customAvailability").child("\(Int(day.timeIntervalSince1970 * 1_000))")
		
		if let key = key, key != "0" {
			databaseRef.child(key).setValue(availability.toDictionary())
		} else {
			databaseRef.childByAutoId().setValue(availability.toDictionary())
			
			if let defaultAvailabilities = defaultAvailabilities {
				for availability in defaultAvailabilities {
					let convertedAvailability = availability.converted(to: day)
					databaseRef.childByAutoId().setValue(convertedAvailability.toDictionary())
				}
			}
		}
	}
	
	// deletes custom availability and adds the rest of the default availabilities to custom availability
	func deleteCustomAvailability(key: String?, defaultAvailabilities: [Timeslot]?, for day: Date) {
		
		let day = day.day()
		
		let databaseRef = self.database.child("tutors").child(self.id).child("customAvailability").child("\(Int(day.timeIntervalSince1970 * 1_000))")
		
		if let key = key, key != "0" {
			
			databaseRef.child(key).setValue(nil)
			
		} else {
			
			if let defaultAvailabilities = defaultAvailabilities {
				for availability in defaultAvailabilities {
					let convertedAvailability = availability.converted(to: day)
					databaseRef.childByAutoId().setValue(convertedAvailability.toDictionary())
				}
			}
		}
	}
	
	// fetches tutor's default availability
	func fetchDefaultAvailability(_ completion: @escaping (Error?) -> () ) {
		self.database.child("tutors").child(self.id).child("defaultAvailability").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
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
				completion(nil)
			} else {
				completion(nil)
			}
		}
	}
	
	// uploads tutor's default availability for specific day
	// used by AddDefaultAvailabilityVC
	func uploadDefault(_ availability: Timeslot, for weekDay: WeekDay) {
		
		let databaseRef = self.database.child("tutors").child(self.id).child("defaultAvailability").child(weekDay.rawValue)
		
		// the default availability doesn't exist for the specific day, it will be created otherwise added to existing availabilities for that day
		if let _ = self.defaultAvailability[weekDay.rawValue] {
			self.defaultAvailability[weekDay.rawValue]?.append(availability)
		} else {
			self.defaultAvailability[weekDay.rawValue] = [availability]
		}
		
		var timeslots = [[String:Int]]()
		for (_, timeslot) in self.defaultAvailability[weekDay.rawValue]!.enumerated() {
			timeslots.append(timeslot.toDictionary())
		}
		
		// DefaultAvailabilityVC will be update defaultAvailability anyways when user goes back to the vc, so I don't update self.defaultAvailability
		databaseRef.setValue(timeslots)
	}
	
	// used by EditDefaultAvailabilityVC
	func updateDefaultAvailability(for weekDay: WeekDay) {
		
		let databaseRef = self.database.child("tutors").child(self.id).child("defaultAvailability").child(weekDay.rawValue)
		
		var timeslots = [[String:Int]]()
		for (_, timeslot) in self.defaultAvailability[weekDay.rawValue]!.enumerated() {
			timeslots.append(timeslot.toDictionary())
		}
		
		databaseRef.setValue(timeslots)
	}
	
	func remove(_ defaultAvailability: Timeslot!, for weekDay: WeekDay!) {
		
		let day = weekDay.rawValue.lowercased()
		
		// remove alterd default availability from the model
		_ = UserManager.shared.defaultAvailability[day]!.index(of: defaultAvailability).map {
		UserManager.shared.defaultAvailability[day]!.remove(at: $0)
		}
		
		self.updateDefaultAvailability(for: weekDay)
	}
}

enum UserManagerError: Error {
	case firebase
	case unknown
}

extension UserManagerError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .firebase:
			return NSLocalizedString("Error connecting to the Firebase", comment: "UserManagerError")
		case .unknown:
			return NSLocalizedString("Unknown Error", comment: "UserManagerError")
		}
	}
}
