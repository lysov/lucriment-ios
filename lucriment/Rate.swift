//
//  Rate.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-04.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation

class Rate {
	static var shared = Rate()
	
	init() {
		for rate in 15...200 {
			self.rates.append(rate)
		}
	}
	
	lazy var rates = [Int]()
}
