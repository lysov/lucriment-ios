//
//  FirebaseDatabaseManager.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-28.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseDatabase

class DatabaseManager {
	
	fileprivate static var databaseManager: DatabaseManager!
	fileprivate let firebaseDatabaseReference = Database.database().reference()
	var delegate: ActivityIndicatorDelegate!
	
	static var shared = DatabaseManager()
	
	func downloadSubjects(_ completion: @escaping ([Subject]?, Error?) -> ()) {
		self.firebaseDatabaseReference.child("subjects").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			
			if snapshot.exists() {
				var courses = [Subject]()
				for subjectSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
					
					let subjectName = subjectSnapshot.key // Math etc.
					var subject = Subject(name: subjectName)
					
					for courseSnapshot in subjectSnapshot.children.allObjects as! [DataSnapshot] {
						let courseName = courseSnapshot.value as! String
						subject.append(courseName)
					}
					courses.append(subject)
				}
				completion(courses, nil)
			} else {
				completion(nil, DatabaseManagerError.firebase)
			}
		}
	}
	
	func downloadSubjects(for id: String, _ completion: @escaping ([String]?, Error?) -> ()) {
		self.firebaseDatabaseReference.child("tutors").child(id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			
			if snapshot.exists() {
				var subjects = [String]()
				if let data = snapshot.value as? [String:Any] {
					// parse subjects
					for (key, value) in data {
						if value is Bool {
							if value as! Bool == true {
								subjects.append(key)
							}
						}
					}
				}
				completion(subjects, nil)
			} else {
				completion(nil, DatabaseManagerError.firebase)
			}
		}
	}
	
	func downloadTutors(for subject: String, _ completion: @escaping ([Tutor]?, Error?) -> ()) {
		self.firebaseDatabaseReference.child("tutors").queryOrdered(byChild: subject).queryEqual(toValue: true).observeSingleEvent(of: .value) { (tutorsSnapshot: DataSnapshot) in
			if tutorsSnapshot.exists() {
				
				var tutors = [Tutor]()
				for tutorSnapshot in tutorsSnapshot.children.allObjects as! [DataSnapshot] {
					if let tutor = tutorSnapshot.value as? [String:Any] {
						var tutorDictionary = [String:Any]()
						if let about = tutor["about"] as? String {
							tutorDictionary["about"] = about
						}
						if let address = tutor["address"] as? String {
							tutorDictionary["address"] = address
						}
						if let firstName = tutor["firstName"] as? String {
							tutorDictionary["firstName"] = firstName
						}
						if let fullName = tutor["fullName"] as? String {
							tutorDictionary["fullName"] = fullName
						}
						if let headline = tutor["headline"] as? String {
							tutorDictionary["headline"] = headline
						}
						if let id = tutor["id"] as? String {
							tutorDictionary["id"] = id
						}
						if let lastName = tutor["lastName"] as? String {
							tutorDictionary["lastName"] = lastName
						}
						if let postalCode = tutor["postalCode"] as? String {
							tutorDictionary["postalCode"] = postalCode
						}
						if let profileImage = tutor["profileImage"] as? String {
							tutorDictionary["profileImage"] = profileImage
						}
						if let rate = tutor["rate"] as? Int {
							tutorDictionary["rate"] = rate
						}
						if let ratingDictionary = tutor["rating"] as? [String: Any] {
							let numberOfReviews = ratingDictionary["numberOfReviews"] as! Int
							let totalScore = ratingDictionary["totalScore"] as! Int
							tutorDictionary["rating"] = Double(totalScore) / Double(numberOfReviews)
						}
						// parse subjects
						var subjectsString = ""
						for (key, value) in tutor {
							if value is Bool {
								if value as! Bool == true {
									subjectsString += key + ", "
								}
							}
						}
						
						// adds dot to the end of the text
						if subjectsString.characters.count >= 3 {
							let endIndex = subjectsString.index(subjectsString.endIndex, offsetBy: -2)
							subjectsString = subjectsString.substring(to: endIndex)
							subjectsString += "."
						}
						tutorDictionary["subjects"] = subjectsString
						
						tutors.append(Tutor(about: tutorDictionary["about"] as? String ?? nil, address: tutorDictionary["address"] as? String ?? nil, firstName: tutorDictionary["firstName"] as! String, fullName: tutorDictionary["fullName"] as! String, headline: tutorDictionary["headline"] as? String ?? nil, id: tutorDictionary["id"] as! String, lastName: tutorDictionary["lastName"] as! String, postalCode: tutorDictionary["postalCode"] as! String, profileImage: tutorDictionary["profileImage"] as? String ?? nil, rate: tutorDictionary["rate"] as! Int, rating: tutorDictionary["rating"] as? Double ?? nil, subjects: tutorDictionary["subjects"] as! String))
					} else {
						completion(nil, DatabaseManagerError.firebase)
					}
					
					completion(tutors, nil)
				}
			} else {
				completion(nil, DatabaseManagerError.firebase)
			}
		}
	}
	
	func downloadTutor(id: String, _ completion: @escaping (Tutor?, Error?) -> ()) {
		self.firebaseDatabaseReference.child("tutors").child(id).observeSingleEvent(of: .value) { (tutorSnapshot: DataSnapshot) in
			if tutorSnapshot.exists() {
				if let tutor = tutorSnapshot.value as? [String:Any] {
					var tutorDictionary = [String:Any]()
					if let about = tutor["about"] as? String {
						tutorDictionary["about"] = about
					}
					if let address = tutor["address"] as? String {
						tutorDictionary["address"] = address
					}
					if let firstName = tutor["firstName"] as? String {
						tutorDictionary["firstName"] = firstName
					}
					if let fullName = tutor["fullName"] as? String {
						tutorDictionary["fullName"] = fullName
					}
					if let headline = tutor["headline"] as? String {
						tutorDictionary["headline"] = headline
					}
					if let id = tutor["id"] as? String {
						tutorDictionary["id"] = id
					}
					if let lastName = tutor["lastName"] as? String {
						tutorDictionary["lastName"] = lastName
					}
					if let postalCode = tutor["postalCode"] as? String {
						tutorDictionary["postalCode"] = postalCode
					}
					if let profileImage = tutor["profileImage"] as? String {
						tutorDictionary["profileImage"] = profileImage
					}
					if let rate = tutor["rate"] as? Int {
						tutorDictionary["rate"] = rate
					}
					if let ratingDictionary = tutor["rating"] as? [String: Any] {
						let numberOfReviews = ratingDictionary["numberOfReviews"] as! Int
						let totalScore = ratingDictionary["totalScore"] as! Int
						tutorDictionary["rating"] = Double(totalScore) / Double(numberOfReviews)
					}
					// parse subjects
					var subjectsString = ""
					for (key, value) in tutor {
						if value is Bool {
							if value as! Bool == true {
								subjectsString += key + ", "
							}
						}
					}
					
					// adds dot to the end of the text
					if subjectsString.characters.count >= 3 {
						let endIndex = subjectsString.index(subjectsString.endIndex, offsetBy: -2)
						subjectsString = subjectsString.substring(to: endIndex)
						subjectsString += "."
					}
					tutorDictionary["subjects"] = subjectsString
					
					let tutor = Tutor(about: tutorDictionary["about"] as? String ?? nil, address: tutorDictionary["address"] as? String ?? nil, firstName: tutorDictionary["firstName"] as! String, fullName: tutorDictionary["fullName"] as! String, headline: tutorDictionary["headline"] as? String ?? nil, id: tutorDictionary["id"] as! String, lastName: tutorDictionary["lastName"] as! String, postalCode: tutorDictionary["postalCode"] as! String, profileImage: tutorDictionary["profileImage"] as? String ?? nil, rate: tutorDictionary["rate"] as! Int, rating: tutorDictionary["rating"] as? Double ?? nil, subjects: tutorDictionary["subjects"] as! String)
					
					completion(tutor, nil)
				} else {
					completion(nil, DatabaseManagerError.firebase)
				}
			} else {
				completion(nil, DatabaseManagerError.firebase)
			}
		}
	}
	
	func downloadSavedTutors(_ completion: @escaping ([Tutor]?, Error?) -> ()) {
		if UserManager.shared.firstName == nil {
			UserManager.shared.refresh { (error) in
				if let error = error {
					print(error.localizedDescription)
					completion(nil, error)
				} else {
					
					self.firebaseDatabaseReference.child("tutors").observeSingleEvent(of: .value) { (tutorsSnapshot: DataSnapshot) in
						if tutorsSnapshot.exists() {
							
							var tutors = [Tutor]()
							for tutorSnapshot in tutorsSnapshot.children.allObjects as! [DataSnapshot] {
								if let favourites = UserManager.shared.favourites {
									if favourites.contains(tutorSnapshot.key) {
										if let tutor = tutorSnapshot.value as? [String:Any] {
											var tutorDictionary = [String:Any]()
											if let about = tutor["about"] as? String {
												tutorDictionary["about"] = about
											}
											if let address = tutor["address"] as? String {
												tutorDictionary["address"] = address
											}
											if let firstName = tutor["firstName"] as? String {
												tutorDictionary["firstName"] = firstName
											}
											if let fullName = tutor["fullName"] as? String {
												tutorDictionary["fullName"] = fullName
											}
											if let headline = tutor["headline"] as? String {
												tutorDictionary["headline"] = headline
											}
											if let id = tutor["id"] as? String {
												tutorDictionary["id"] = id
											}
											if let lastName = tutor["lastName"] as? String {
												tutorDictionary["lastName"] = lastName
											}
											if let postalCode = tutor["postalCode"] as? String {
												tutorDictionary["postalCode"] = postalCode
											}
											if let profileImage = tutor["profileImage"] as? String {
												tutorDictionary["profileImage"] = profileImage
											}
											if let rate = tutor["rate"] as? Int {
												tutorDictionary["rate"] = rate
											}
											if let ratingDictionary = tutor["rating"] as? [String: Any] {
												let numberOfReviews = ratingDictionary["numberOfReviews"] as! Int
												let totalScore = ratingDictionary["totalScore"] as! Int
												tutorDictionary["rating"] = Double(totalScore) / Double(numberOfReviews)
											}
											// parse subjects
											var subjectsString = ""
											for (key, value) in tutor {
												if value is Bool {
													if value as! Bool == true {
														subjectsString += key + ", "
													}
												}
											}
											
											// adds dot to the end of the text
											if subjectsString.characters.count >= 3 {
												let endIndex = subjectsString.index(subjectsString.endIndex, offsetBy: -2)
												subjectsString = subjectsString.substring(to: endIndex)
												subjectsString += "."
											}
											tutorDictionary["subjects"] = subjectsString
											
											tutors.append(Tutor(about: tutorDictionary["about"] as? String ?? nil, address: tutorDictionary["address"] as? String ?? nil, firstName: tutorDictionary["firstName"] as! String, fullName: tutorDictionary["fullName"] as! String, headline: tutorDictionary["headline"] as? String ?? nil, id: tutorDictionary["id"] as! String, lastName: tutorDictionary["lastName"] as! String, postalCode: tutorDictionary["postalCode"] as! String, profileImage: tutorDictionary["profileImage"] as? String ?? nil, rate: tutorDictionary["rate"] as! Int, rating: tutorDictionary["rating"] as? Double ?? nil, subjects: tutorDictionary["subjects"] as! String))
										} else {
											completion(nil, DatabaseManagerError.firebase)
										}
									}
								}
							}
							
							completion(tutors, nil)
						} else {
							completion(nil, DatabaseManagerError.firebase)
						}
					}
				}
			}
		// user profile exists
		} else {
			self.firebaseDatabaseReference.child("tutors").observeSingleEvent(of: .value) { (tutorsSnapshot: DataSnapshot) in
				if tutorsSnapshot.exists() {
					
					var tutors = [Tutor]()
					for tutorSnapshot in tutorsSnapshot.children.allObjects as! [DataSnapshot] {
						if let favourites = UserManager.shared.favourites {
							if favourites.contains(tutorSnapshot.key) {
								if let tutor = tutorSnapshot.value as? [String:Any] {
									var tutorDictionary = [String:Any]()
									if let about = tutor["about"] as? String {
										tutorDictionary["about"] = about
									}
									if let address = tutor["address"] as? String {
										tutorDictionary["address"] = address
									}
									if let firstName = tutor["firstName"] as? String {
										tutorDictionary["firstName"] = firstName
									}
									if let fullName = tutor["fullName"] as? String {
										tutorDictionary["fullName"] = fullName
									}
									if let headline = tutor["headline"] as? String {
										tutorDictionary["headline"] = headline
									}
									if let id = tutor["id"] as? String {
										tutorDictionary["id"] = id
									}
									if let lastName = tutor["lastName"] as? String {
										tutorDictionary["lastName"] = lastName
									}
									if let postalCode = tutor["postalCode"] as? String {
										tutorDictionary["postalCode"] = postalCode
									}
									if let profileImage = tutor["profileImage"] as? String {
										tutorDictionary["profileImage"] = profileImage
									}
									if let rate = tutor["rate"] as? Int {
										tutorDictionary["rate"] = rate
									}
									if let ratingDictionary = tutor["rating"] as? [String: Any] {
										let numberOfReviews = ratingDictionary["numberOfReviews"] as! Int
										let totalScore = ratingDictionary["totalScore"] as! Int
										tutorDictionary["rating"] = Double(totalScore) / Double(numberOfReviews)
									}
									
									// parse subjects
									var subjectsString = ""
									for (key, value) in tutor {
										if value is Bool {
											if value as! Bool == true {
												subjectsString += key + ", "
											}
										}
									}
									
									// adds dot to the end of the text
									if subjectsString.characters.count >= 3 {
										let endIndex = subjectsString.index(subjectsString.endIndex, offsetBy: -2)
										subjectsString = subjectsString.substring(to: endIndex)
										subjectsString += "."
									}
									tutorDictionary["subjects"] = subjectsString
									
									tutors.append(Tutor(about: tutorDictionary["about"] as? String ?? nil, address: tutorDictionary["address"] as? String ?? nil,firstName: tutorDictionary["firstName"] as! String, fullName: tutorDictionary["fullName"] as! String, headline: tutorDictionary["headline"] as? String ?? nil, id: tutorDictionary["id"] as! String, lastName: tutorDictionary["lastName"] as! String, postalCode: tutorDictionary["postalCode"] as! String, profileImage: tutorDictionary["profileImage"] as? String ?? nil, rate: tutorDictionary["rate"] as! Int, rating: tutorDictionary["rating"] as? Double ?? nil, subjects: tutorDictionary["subjects"] as! String))
								} else {
									completion(nil, DatabaseManagerError.firebase)
								}
							}
						}
					}
					
					completion(tutors, nil)
				} else {
					completion(nil, DatabaseManagerError.firebase)
				}
			}
		}
	}
	
	// downloads student profile
	func downloadStudent(id: String, _ completion: @escaping (Student?, Error?) -> ()) {
		self.firebaseDatabaseReference.child("users").child(id).observeSingleEvent(of: .value) { (studentSnapshot: DataSnapshot) in
			if studentSnapshot.exists() {
				if let student = studentSnapshot.value as? [String: Any] {
					var studentDictionary = [String:Any]()
					
					if let email = student["email"] as? String {
						studentDictionary["email"] = email
					}
					if let firstName = student["firstName"] as? String {
						studentDictionary["firstName"] = firstName
					}
					if let fullName = student["fullName"] as? String {
						studentDictionary["fullName"] = fullName
					}
					if let headline = student["headline"] as? String {
						studentDictionary["headline"] = headline
					}
					if let id = student["id"] as? String {
						studentDictionary["id"] = id
					}
					if let lastName = student["lastName"] as? String {
						studentDictionary["lastName"] = lastName
					}
					if let profileImage = student["profileImage"] as? String {
						studentDictionary["profileImage"] = profileImage
					}
					if let ratingDictionary = student["rating"] as? [String: Any] {
						let numberOfReviews = ratingDictionary["numberOfReviews"] as! Int
						let totalScore = ratingDictionary["totalScore"] as! Int
						studentDictionary["rating"] = Double(totalScore) / Double(numberOfReviews)
					}
					
					let student = Student(email: studentDictionary["email"] as! String, firstName: studentDictionary["firstName"] as! String, fullName: studentDictionary["fullName"] as! String, headline: studentDictionary["headline"] as? String ?? nil, id: studentDictionary["id"] as! String, lastName: studentDictionary["lastName"] as! String, profileImage: studentDictionary["profileImage"] as? String ?? nil, rating: studentDictionary["rating"] as? Double ?? nil)
					
					completion(student, nil)
				} else {
					completion(nil, DatabaseManagerError.firebase)
				}
			} else {
				completion(nil, DatabaseManagerError.firebase)
			}
		}
	}
	
	// updates values in several locations in the database
	func update(_ childValues: [String: Any], _ completion: @escaping (Error?) -> ()) {
		self.firebaseDatabaseReference.updateChildValues(childValues) { (error, snapshot) in
			if error != nil {
				completion(error)
			} else {
				completion(nil)
			}
		}
	}
	
	func downloadEarnings(for id: String, _ completion: @escaping ([Earning]?, Error?) -> ()) {
		// check session/tutorId in the past
		self.firebaseDatabaseReference.child("sessions").child(id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				
				var earnings = [Earning]()
				
				for sessionsSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
					
					let sessionsKey = sessionsSnapshot.key
					let sessionsKeyArray = sessionsKey.components(separatedBy: "_")
					
					if sessionsKeyArray[1] == id {
						
						for sessionSnapshot in sessionsSnapshot.children.allObjects as! [DataSnapshot] {
							let earningDictionary = sessionSnapshot.value as! [String: AnyObject]
							
							// check if the session is upcoming
							let timeDictionary = earningDictionary["time"] as! [String: AnyObject]
							let fromTimeInterval = TimeInterval(timeDictionary["from"] as! Int)
							let day = Date(timeIntervalSince1970: fromTimeInterval / 1_000).day()
							if day <= Date() {
								// 2. check if the session is confirmed, !cancelled, !declinded
								let isConfirmed = earningDictionary["confirmed"] as! Bool
								if isConfirmed == false {
									continue
								}
								
								let isCancelled = earningDictionary["sessionCancelled"] as! Bool
								if isCancelled == true {
									continue
								}
								
								let isDeclined = earningDictionary["sessionCancelled"] as! Bool
								if isDeclined == true {
									continue
								}
								
								let studentName = earningDictionary["studentName"] as! String
								let price = earningDictionary["price"] as! Double
								
								// time
								let from = Date(timeIntervalSince1970: fromTimeInterval / 1_000)
								let toTimeInterval = TimeInterval(timeDictionary["to"] as! Int)
								let to = Date(timeIntervalSince1970: toTimeInterval / 1_000)
								let sessionDuration = Int((to.timeIntervalSince1970 - from.timeIntervalSince1970) / 60) // in minutes
								
								let earning = Earning(studentName: studentName, date: day, price: price, sessionDuration: sessionDuration)
								
								earnings.append(earning)
							}
						}
					}
				}
				
				completion(earnings, nil)
			} else {
				completion(nil, DatabaseManagerError.firebase)
			}
		}
	}
	
	// MARK:- Payment
	
	func fetchPaymentInfo(_ completion: @escaping (CreditCard?, Error?) -> ()) {
		
		let id = UserManager.shared.id!
		self.firebaseDatabaseReference.child("users").child(id).child("paymentInfo").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				
				var creditCard = [String: Any]()
				
				for paymentInfoSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
					if let paymentInfoDictionary = paymentInfoSnapshot.value as? [String: Any] {
						if let brand = paymentInfoDictionary["brand"] as? String {
							creditCard["brand"] = brand
						}
						if let lastFourDigits = paymentInfoDictionary["last4"] as? String {
							creditCard["last4"] = lastFourDigits
						}
						if let expirationMonth = paymentInfoDictionary["exp_month"] as? Int {
							creditCard["exp_month"] = expirationMonth
						}
						if let expirationYear = paymentInfoDictionary["exp_year"] as? Int {
							creditCard["exp_year"] = expirationYear
						}
						
						if let brand = creditCard["brand"] as? String, let lastFourDigits = creditCard["last4"] as? String, let expirationMonth = creditCard["exp_month"] as? Int, let expirationYear = creditCard["exp_year"] as? Int {
							let creditCard = CreditCard(brand: brand, lastFourDigits: lastFourDigits, expirationMonth: expirationMonth, expirationYear: expirationYear)
							completion(creditCard, nil)
						} else {
							completion(nil, DatabaseManagerError.firebase)
						}
					} else {
						completion(nil, DatabaseManagerError.firebase)
					}
				}
			} else {
				completion(nil, DatabaseManagerError.firebase)
			}
		}
	}
	
	func fetchPayoutInfo(_ completion: @escaping (Payout?, Error?) -> ()) {
		
		let id = UserManager.shared.id!
		self.firebaseDatabaseReference.child("tutors").child(id).child("stripe_connected").child("external_accounts").child("data").child("0").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				
				var payout = [String: Any]()
				
				if let payoutInfoDictionary = snapshot.value as? [String: Any] {
					if let bank = payoutInfoDictionary["bank_name"] as? String {
						payout["bank_name"] = bank
					}
					if let lastFourDigits = payoutInfoDictionary["last4"] as? String {
						payout["last4"] = lastFourDigits
					}
					
					
					if let routingNumber = payoutInfoDictionary["routing_number"] as? String {
						let routingNumberArray = routingNumber.components(separatedBy: "-")
						payout["transit"] = routingNumberArray[0]
						payout["financialInstitution"] = routingNumberArray[1]
					}
					
					if let bank = payout["bank_name"] as? String, let lastFourDigits = payout["last4"] as? String, let transit = payout["transit"] as? String, let financialInstitution = payout["financialInstitution"] as? String {
						let payout = Payout(bank: bank, lastFourDigits: lastFourDigits, transit: transit, financialInstitution: financialInstitution)
						completion(payout, nil)
					} else {
						completion(nil, DatabaseManagerError.firebase)
					}
				} else {
					completion(nil, DatabaseManagerError.firebase)
				}
			} else {
				completion(nil, DatabaseManagerError.firebase)
			}
		}
	}
	
	func updatePaymentInfo(_ creditCard: [String: AnyObject], _ completion: @escaping (Error?) -> ()) {
		
		let id = UserManager.shared.id!
		
		self.firebaseDatabaseReference.child("users").child(id).child("paymentInfo").childByAutoId().child("token").setValue(creditCard)
		completion(nil)
	}
	
	func updatePayoutInfo(_ bankInfo: [String: AnyObject], _ completion: @escaping (Error?) -> ()) {
		
		let id = UserManager.shared.id!
		
		self.firebaseDatabaseReference.child("tutors").child(id).child("stripe_connected").child("update").child("external_account").setValue(bankInfo)
		completion(nil)
	}
	
	func checkPaymentMethod(_ completion: @escaping (Bool) -> ()) {
		let id = UserManager.shared.id!
		
		self.firebaseDatabaseReference.child("users").child(id).child("paymentInfo").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				completion(true)
			} else {
				completion(false)
			}
		}
		
	}
	
	func checkPayoutMethod(_ completion: @escaping (Bool) -> ()) {
		let id = UserManager.shared.id!
		
		self.firebaseDatabaseReference.child("tutors").child(id).child("stripe_connected").child("external_accounts").child("data").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				completion(true)
			} else {
				completion(false)
			}
		}
		
	}
	
	
	// MARK:- Sessions
	
	// books session
	func request(_ session: [String: Any], _ completion: () -> ()) {
		let tutorId = session["tutorId"] as! String
		let studentId = session["studentId"] as! String
		
		let key = self.firebaseDatabaseReference.child("sessions").child(tutorId).child("\(studentId)_\(tutorId)").childByAutoId().key
		
		self.firebaseDatabaseReference.child("sessions").child(tutorId).child("\(studentId)_\(tutorId)").child(key).setValue(session)		
		self.firebaseDatabaseReference.child("sessions").child(studentId).child("\(studentId)_\(tutorId)").child(key).setValue(session)
		
		self.firebaseDatabaseReference.child("requestNotifications").child(tutorId).childByAutoId().child("from").setValue(UserManager.shared.id)
		
		completion()
	}
	
	// session cancellation
	
	func cancel(_ session: Session, _ completion: @escaping () -> ()) {
		
		let tutorId = session.tutorId
		let studentId = session.studentId
		
		let key = session.key
		
		self.firebaseDatabaseReference.child("tutors").child(tutorId).child("stripe_connected").child("id").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				
				let stripe_id = snapshot.value as! String
				
				self.firebaseDatabaseReference.child("users").child(studentId).child("charges").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
					if snapshot.exists() {
						
						var chargeId = ""
						
						for chargeSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
							if let chargeDictionary = chargeSnapshot.value as? [String: Any] {
								if let destination = chargeDictionary["destination"] as? String {
									
									if destination == stripe_id {
										if let id = chargeDictionary["id"] as? String {
											chargeId = id
										}
									}
									
								}
							}
						}
						
						var dictionary = [String: AnyObject]()
						dictionary["chargeId"] = chargeId as AnyObject
						
						self.firebaseDatabaseReference.child("users").child(studentId).child("refunds").childByAutoId().setValue(dictionary)
					}
				}
				completion()
			} else {
				completion()
			}
		}
		self.firebaseDatabaseReference.child("sessions").child(tutorId).child("\(studentId)_\(tutorId)").child(key).updateChildValues(["sessionCancelled": true])
		self.firebaseDatabaseReference.child("sessions").child(studentId).child("\(studentId)_\(tutorId)").child(key).updateChildValues(["sessionCancelled": true])
		
		if UserManager.shared.id == tutorId {
			// tutor cancells the session
			self.firebaseDatabaseReference.child("cancelledNotifications").child(studentId).childByAutoId().child("from").setValue(tutorId)
		} else {
			// students cancells the session
			self.firebaseDatabaseReference.child("cancelledNotifications").child(tutorId).childByAutoId().child("from").setValue(studentId)
		}
		
		completion()
	}
	
	// decline session request
	
	func decline(_ sessionRequest: Session, _ completion: () -> ()) {
		
		let tutorId = sessionRequest.tutorId
		let studentId = sessionRequest.studentId
		
		let key = sessionRequest.key
		
		self.firebaseDatabaseReference.child("sessions").child(tutorId).child("\(studentId)_\(tutorId)").child(key).updateChildValues(["sessionDeclined": true])
		self.firebaseDatabaseReference.child("sessions").child(studentId).child("\(studentId)_\(tutorId)").child(key).updateChildValues(["sessionDeclined": true])
		
		if UserManager.shared.id == tutorId {
			// tutor cancells the session
			self.firebaseDatabaseReference.child("declinedNotifications").child(studentId).childByAutoId().child("from").setValue(tutorId)
		} else {
			// students cancells the session
			self.firebaseDatabaseReference.child("declinedNotifications").child(tutorId).childByAutoId().child("from").setValue(studentId)
		}
		
		completion()
	}
	
	// accept session request
	
	func accept(_ sessionRequest: Session, _ completion: @escaping () -> ()) {
		
		let tutorId = sessionRequest.tutorId
		let studentId = sessionRequest.studentId
		
		let key = sessionRequest.key
	
		self.firebaseDatabaseReference.child("tutors").child(tutorId).child("stripe_connected").child("id").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				
				let stripe_id = snapshot.value as! String
				
				var charge = [String: AnyObject]()
				charge["amount"] = sessionRequest.price * 100 as AnyObject
				charge["destination"] = stripe_id as AnyObject
				
				self.firebaseDatabaseReference.child("users").child(studentId).child("charges").childByAutoId().setValue(charge)
				self.firebaseDatabaseReference.child("confirmedNotifications").child(studentId).childByAutoId().child("from").setValue(tutorId)
				completion()
			} else {
				completion()
			}
		}
		
		self.firebaseDatabaseReference.child("sessions").child(tutorId).child("\(studentId)_\(tutorId)").child(key).updateChildValues(["confirmed": true])
		self.firebaseDatabaseReference.child("sessions").child(studentId).child("\(studentId)_\(tutorId)").child(key).updateChildValues(["confirmed": true])
		
		completion()
	}
	
	// leave feedback
	func rate(_ userType: UserType, session: Session, review: [String: Any], _ completion: @escaping (Error?) -> ()) {
		
		let tutorId = session.tutorId
		let studentId = session.studentId
		
		let key = "\(session.studentId)_\(session.tutorId)"
		
		if userType == .tutor {
			// leave feedback for tutor
			
			// 1. get rating of the tutor
			self.downloadRating(.tutor, id: tutorId) { (rating, error) in
				if let error = error {
					print(error.localizedDescription)
					completion(DatabaseManagerError.firebase)
				} else if let rating = rating {
					var newRating = [String: Int]()
					newRating["numberOfReviews"] = rating["numberOfReviews"]! + 1
					newRating["totalScore"] = review["rating"] as! Int + rating["totalScore"]!
					
					// 2. update the rating
					self.firebaseDatabaseReference.child("tutors").child(tutorId).updateChildValues(["rating": newRating])
					
					// 3. leave the review
					self.firebaseDatabaseReference.child("tutors").child(tutorId).child("reviews").childByAutoId().setValue(review)
					
					// review under the session
					self.firebaseDatabaseReference.child("sessions").child(tutorId).child(key).child(session.key).updateChildValues(["tutorReview": review])
					self.firebaseDatabaseReference.child("sessions").child(studentId).child(key).child(session.key).updateChildValues(["tutorReview": review])
				}
			}
		}
		
		// leave feedback for student
		else {
			// 1. get rating of the tutor
			self.downloadRating(.student, id: studentId) { (rating, error) in
				if let error = error {
					print(error.localizedDescription)
					completion(DatabaseManagerError.firebase)
				} else if let rating = rating {
					var newRating = [String: Int]()
					newRating["numberOfReviews"] = rating["numberOfReviews"]! + 1
					newRating["totalScore"] = review["rating"] as! Int + rating["totalScore"]!
					
					// 2. update the rating
					self.firebaseDatabaseReference.child("users").child(studentId).updateChildValues(["rating": newRating])
					
					// 3. leave the review
					self.firebaseDatabaseReference.child("users").child(studentId).child("reviews").childByAutoId().setValue(review)
					
					// review under the session
					self.firebaseDatabaseReference.child("sessions").child(tutorId).child(key).child(session.key).updateChildValues(["studentReview": review])
					self.firebaseDatabaseReference.child("sessions").child(studentId).child(key).child(session.key).updateChildValues(["studentReview": review])
				}
			}
		}
		
		completion(nil)
	}
	
	fileprivate func downloadRating(_ userType: UserType, id: String, _ completion: @escaping ([String: Int]?, Error?) -> ()) {
		
		if userType == .tutor {
			self.firebaseDatabaseReference.child("tutors").child(id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
				if snapshot.exists() {
					if let tutorDictionary = snapshot.value as? [String: AnyObject] {
						
						var rating = [String: Int]()
						
						if let ratingDictionary = tutorDictionary["rating"] as? [String: AnyObject] {
							rating["numberOfReviews"] = (ratingDictionary["numberOfReviews"] as! Int)
							rating["totalScore"] = (ratingDictionary["totalScore"] as! Int)
						} else {
							rating["numberOfReviews"] = 0
							rating["totalScore"] = 0
						}
						
						completion(rating, nil)
					}
				} else {
					completion(nil, DatabaseManagerError.firebase)
				}
			}
		} else {
			self.firebaseDatabaseReference.child("users").child(id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
				if snapshot.exists() {
					if let tutorDictionary = snapshot.value as? [String: AnyObject] {
						
						var rating = [String: Int]()
						
						if let ratingDictionary = tutorDictionary["rating"] as? [String: AnyObject] {
							rating["numberOfReviews"] = (ratingDictionary["numberOfReviews"] as! Int)
							rating["totalScore"] = (ratingDictionary["totalScore"] as! Int)
						} else {
							rating["numberOfReviews"] = 0
							rating["totalScore"] = 0
						}
						
						completion(rating, nil)
					}
				} else {
					completion(nil, DatabaseManagerError.firebase)
				}
			}
		}
	}
	
	// fetches rating
	func downloadReviews(for id: String, _ completion: @escaping ([Review]?, Error?) -> ()) {
		self.firebaseDatabaseReference.child("tutors").child(id).child("reviews").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				
				var reviews = [Review]()
				
				for reviewSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
					
					let reviewDictionary = reviewSnapshot.value as! [String: AnyObject]
					
					let author = reviewDictionary["author"] as! String
					let authorId = reviewDictionary["authorId"] as! String
					let rating = reviewDictionary["rating"] as! Int
					let text = reviewDictionary["text"] as! String
					let timeStamp = reviewDictionary["timeStamp"] as! Int
					
					let review = Review(author: author, authorId: authorId, rating: rating, text: text, timeStamp: timeStamp)
					
					reviews.append(review)
				}
				
				completion(reviews, nil)
			} else {
				completion(nil, DatabaseManagerError.firebase)
			}
		}
	}
	
	func downloadUpcomingSessions(for userType: UserType, id: String, _ completion: @escaping ([Session]?, Error?) -> ()) {
		self.firebaseDatabaseReference.child("sessions").child(id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				var sessions = [Session]()
				for sessionsSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
					
					let sessionsKey = sessionsSnapshot.key
					let sessionsKeyArray = sessionsKey.components(separatedBy: "_")
					
					switch userType {
					case .tutor:
						if sessionsKeyArray[1] == id {
							
							for sessionSnapshot in sessionsSnapshot.children.allObjects as! [DataSnapshot] {
								
								let sessionDictionary = sessionSnapshot.value as! [String: AnyObject]
								
								// check if the session is upcoming
								let timeDictionary = sessionDictionary["time"] as! [String: AnyObject]
								let fromTimeInterval = TimeInterval(timeDictionary["from"] as! Int)
								let date = Date(timeIntervalSince1970: fromTimeInterval / 1_000)
								let dayComponents = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: date)
								let day = Calendar.current.date(from: dayComponents)!
								
								if day >= Date() {
									
									let key = sessionSnapshot.key
									
									let confirmed = sessionDictionary["confirmed"] as! Bool
									let location = sessionDictionary["location"] as! String
									let price = sessionDictionary["price"] as! Double
									let sessionCancelled = sessionDictionary["sessionCancelled"] as! Bool
									if sessionCancelled == true {
										continue
									}
									let sessionDeclined = sessionDictionary["sessionDeclined"] as! Bool
									if sessionDeclined == true {
										continue
									}
									let studentId = sessionDictionary["studentId"] as! String
									let studentName = sessionDictionary["studentName"] as! String
									let subject = sessionDictionary["subject"] as! String
									
									// time
									let from = Date(timeIntervalSince1970: fromTimeInterval / 1_000)
									let toTimeInterval = TimeInterval(timeDictionary["to"] as! Int)
									let to = Date(timeIntervalSince1970: toTimeInterval / 1_000)
									let time = Timeslot(from: from, to: to)
									
									let tutorId = sessionDictionary["tutorId"] as! String
									let tutorName = sessionDictionary["tutorName"] as! String
									
									var session = Session(key: key, confirmed: confirmed, location: location, price: price, sessionCancelled: sessionCancelled, sessionDeclined: sessionDeclined, studentId: studentId, studentName: studentName, subject: subject, time: time, tutorId: tutorId, tutorName: tutorName)
									
									sessions.append(session)
								}
							}
						}
					case .student:
						if sessionsKeyArray[0] == id {
							
							for sessionSnapshot in sessionsSnapshot.children.allObjects as! [DataSnapshot] {
								
								let sessionDictionary = sessionSnapshot.value as! [String: AnyObject]
								
								// check if the session is upcoming
								let timeDictionary = sessionDictionary["time"] as! [String: AnyObject]
								let fromTimeInterval = TimeInterval(timeDictionary["from"] as! Int)
								let date = Date(timeIntervalSince1970: fromTimeInterval / 1_000)
								let dayComponents = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: date)
								let day = Calendar.current.date(from: dayComponents)!
								
								if day >= Date() {
									
									let key = sessionSnapshot.key
									
									let confirmed = sessionDictionary["confirmed"] as! Bool
									let location = sessionDictionary["location"] as! String
									let price = sessionDictionary["price"] as! Double
									let sessionCancelled = sessionDictionary["sessionCancelled"] as! Bool
									if sessionCancelled == true {
										continue
									}
									let sessionDeclined = sessionDictionary["sessionDeclined"] as! Bool
									if sessionDeclined == true {
										continue
									}
									let studentId = sessionDictionary["studentId"] as! String
									let studentName = sessionDictionary["studentName"] as! String
									let subject = sessionDictionary["subject"] as! String
									
									// time
									let from = Date(timeIntervalSince1970: fromTimeInterval / 1_000)
									let toTimeInterval = TimeInterval(timeDictionary["to"] as! Int)
									let to = Date(timeIntervalSince1970: toTimeInterval / 1_000)
									let time = Timeslot(from: from, to: to)
									
									let tutorId = sessionDictionary["tutorId"] as! String
									let tutorName = sessionDictionary["tutorName"] as! String
									
									var session = Session(key: key, confirmed: confirmed, location: location, price: price, sessionCancelled: sessionCancelled, sessionDeclined: sessionDeclined, studentId: studentId, studentName: studentName, subject: subject, time: time, tutorId: tutorId, tutorName: tutorName)
									
									sessions.append(session)
								}
							}
						}
					}
				}
				completion(sessions, nil)
			} else {
				completion(nil, DatabaseManagerError.firebase)
			}
		}
	}
	
	func downloadPastSessions(for userType: UserType, id: String, _ completion: @escaping ([Session]?, Error?) -> ()) {
		self.firebaseDatabaseReference.child("sessions").child(id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				var sessions = [Session]()
				for sessionsSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
					
					let sessionsKey = sessionsSnapshot.key
					let sessionsKeyArray = sessionsKey.components(separatedBy: "_")
					
					switch userType {
					case .tutor:
						if sessionsKeyArray[1] == id {
							
							for sessionSnapshot in sessionsSnapshot.children.allObjects as! [DataSnapshot] {
								
								let sessionDictionary = sessionSnapshot.value as! [String: AnyObject]
								
								// check if the session is upcoming
								let timeDictionary = sessionDictionary["time"] as! [String: Any]
								let fromTimeInterval = TimeInterval(timeDictionary["from"] as! Int)
								
								let key = sessionSnapshot.key
								
								let confirmed = sessionDictionary["confirmed"] as! Bool
								let location = sessionDictionary["location"] as! String
								let price = sessionDictionary["price"] as! Double
								let sessionCancelled = sessionDictionary["sessionCancelled"] as! Bool
								let sessionDeclined = sessionDictionary["sessionDeclined"] as! Bool
								let studentId = sessionDictionary["studentId"] as! String
								let studentName = sessionDictionary["studentName"] as! String
								let subject = sessionDictionary["subject"] as! String
								
								// time
								let from = Date(timeIntervalSince1970: fromTimeInterval / 1_000)
								let toTimeInterval = TimeInterval(timeDictionary["to"] as! Int)
								let to = Date(timeIntervalSince1970: toTimeInterval / 1_000)
								let time = Timeslot(from: from, to: to)
								
								let tutorId = sessionDictionary["tutorId"] as! String
								let tutorName = sessionDictionary["tutorName"] as! String
								
								var session = Session(key: key, confirmed: confirmed, location: location, price: price, sessionCancelled: sessionCancelled, sessionDeclined: sessionDeclined, studentId: studentId, studentName: studentName, subject: subject, time: time, tutorId: tutorId, tutorName: tutorName)
								
								if let tutorDictionary = sessionDictionary["tutorReview"] as? [String: AnyObject] {
									let tutorReview = Review(author: tutorDictionary["author"] as! String, authorId: tutorDictionary["authorId"] as! String, rating: tutorDictionary["rating"] as! Int, text: tutorDictionary["text"] as! String, timeStamp: tutorDictionary["timeStamp"] as! Int)
									session.tutorReview = tutorReview
								}
								
								if let studentDictionary = sessionDictionary["studentReview"] as? [String: AnyObject] {
									let studentReview = Review(author: studentDictionary["author"] as! String, authorId: studentDictionary["authorId"] as! String, rating: studentDictionary["rating"] as! Int, text: studentDictionary["text"] as! String, timeStamp: studentDictionary["timeStamp"] as! Int)
									session.studentReview = studentReview
								}
								
								sessions.append(session)
							}
						}
					case .student:
						if sessionsKeyArray[0] == id {
							
							for sessionSnapshot in sessionsSnapshot.children.allObjects as! [DataSnapshot] {
								
								let sessionDictionary = sessionSnapshot.value as! [String: AnyObject]
								
								// check if the session is upcoming
								let timeDictionary = sessionDictionary["time"] as! [String: Any]
								let fromTimeInterval = TimeInterval(timeDictionary["from"] as! Int)
								
								let key = sessionSnapshot.key
								
								let confirmed = sessionDictionary["confirmed"] as! Bool
								let location = sessionDictionary["location"] as! String
								let price = sessionDictionary["price"] as! Double
								let sessionCancelled = sessionDictionary["sessionCancelled"] as! Bool
								let sessionDeclined = sessionDictionary["sessionDeclined"] as! Bool
								let studentId = sessionDictionary["studentId"] as! String
								let studentName = sessionDictionary["studentName"] as! String
								let subject = sessionDictionary["subject"] as! String
								
								// time
								let from = Date(timeIntervalSince1970: fromTimeInterval / 1_000)
								let toTimeInterval = TimeInterval(timeDictionary["to"] as! Int)
								let to = Date(timeIntervalSince1970: toTimeInterval / 1_000)
								let time = Timeslot(from: from, to: to)
								
								let tutorId = sessionDictionary["tutorId"] as! String
								let tutorName = sessionDictionary["tutorName"] as! String
								
								var session = Session(key: key, confirmed: confirmed, location: location, price: price, sessionCancelled: sessionCancelled, sessionDeclined: sessionDeclined, studentId: studentId, studentName: studentName, subject: subject, time: time, tutorId: tutorId, tutorName: tutorName)
								
								if let tutorDictionary = sessionDictionary["tutorReview"] as? [String: AnyObject] {
									let tutorReview = Review(author: tutorDictionary["author"] as! String, authorId: tutorDictionary["authorId"] as! String, rating: tutorDictionary["rating"] as! Int, text: tutorDictionary["text"] as! String, timeStamp: tutorDictionary["timeStamp"] as! Int)
									session.tutorReview = tutorReview
								}
								
								if let studentDictionary = sessionDictionary["studentReview"] as? [String: AnyObject] {
									let studentReview = Review(author: studentDictionary["author"] as! String, authorId: studentDictionary["authorId"] as! String, rating: studentDictionary["rating"] as! Int, text: studentDictionary["text"] as! String, timeStamp: studentDictionary["timeStamp"] as! Int)
									session.studentReview = studentReview
								}
								
								sessions.append(session)
							}
						}
					}
				}
				completion(sessions, nil)
			} else {
				completion(nil, DatabaseManagerError.firebase)
			}
		}
	}
}

enum DatabaseManagerError: Error {
	case firebase
	case unknown
}

extension DatabaseManagerError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .firebase:
			return NSLocalizedString("Error connecting to the Firebase", comment: "ChatManagerError")
		case .unknown:
			return NSLocalizedString("Unknown Error", comment: "ChatManagerError")
		}
	}
}
