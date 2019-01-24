//
//  Tutor.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-16.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation
import UIKit

struct Tutor {
	let about: String?
	let address: String?
	let firstName: String
	let fullName: String
	let headline: String?
	let id: String
	let lastName: String
	let postalCode: String
	let profileImage: String?
	let rate: Int
	let rating: Double?
	let subjects: String
	
	init(about: String?, address: String?, firstName: String, fullName: String, headline: String?, id: String, lastName: String, postalCode: String, profileImage: String?, rate: Int, rating: Double?, subjects: String) {
		self.about = about
		self.address = address
		self.firstName = firstName
		self.fullName = fullName
		self.headline = headline
		self.id = id
		self.lastName = lastName
		self.postalCode = postalCode
		self.profileImage = profileImage
		self.rate = rate
		self.rating = rating
		self.subjects = subjects
	}
}
