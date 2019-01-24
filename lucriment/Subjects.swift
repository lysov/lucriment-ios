//
//  Subjects.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-04.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation

class Subjects {
	static func coursesFor(_ indexPaths: [IndexPath]?, subjects: [Subject]) -> [String]? {
		
		if let indexPaths = indexPaths {
			var courses = [String]()
			
			for indexPath in indexPaths {
				let section = indexPath.section
				let row = indexPath.row
				courses.append(subjects[section].courses[row])
			}
			return courses
		} else {
			return nil
		}
	}
	
	static func indexPathFor(_ courseName: String, subjects: [Subject]) -> IndexPath? {
		var subjectIndex = 0
		for subject in subjects {
			var courseIndex = 0
			for course in subject.courses {
				if course == courseName {
					return IndexPath(row: courseIndex, section: subjectIndex)
				}
				courseIndex += 1
			}
			subjectIndex += 1
		}
		return nil
	}
}

struct Subject {
	let name: String
	var courses: [String]
	
	init(name: String) {
		self.name = name
		self.courses = [String]()
	}
	mutating func append(_ course: String) {
		self.courses.append(course)
	}
}
