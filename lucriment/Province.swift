//
//  Province.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-05.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation

class Province {
	static var shared = Province()
	
	lazy var provinces = ["Alberta", "British Columbia", "Manitoba", "New Brunswick", "Newfoundland and Labrador", "Nova Scotia", "Northwest Territories", "Nunavut", "Ontario", "Prince Edward Island", "Quebec", "Saskatchewan", "Yukon"]
	lazy var abbreviations = ["AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT"]
}
