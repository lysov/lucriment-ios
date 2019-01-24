//
//  Helper.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-02.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
	func compress() -> UIImage {
		
		let actualHeight: CGFloat = self.size.height
		let actualWidth: CGFloat = self.size.width
		let imgRatio: CGFloat = actualWidth / actualHeight
		let maxWidth: CGFloat = 400
		let resizedHeight:CGFloat = maxWidth / imgRatio
		let compressionQuality:CGFloat = 0.5
		
		let rect:CGRect = CGRect(x: 0, y: 0, width: maxWidth, height: resizedHeight)
		UIGraphicsBeginImageContext(rect.size)
		self.draw(in: rect)
		let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		let imageData:Data = UIImageJPEGRepresentation(img, compressionQuality)!
		UIGraphicsEndImageContext()
		
		return UIImage(data: imageData)!		
	}
}

extension String {
	func substring(from: Int?, to: Int?) -> String {
		if let start = from {
			guard start < self.characters.count else {
				return ""
			}
		}
		
		if let end = to {
			guard end >= 0 else {
				return ""
			}
		}
		
		if let start = from, let end = to {
			guard end - start >= 0 else {
				return ""
			}
		}
		
		let startIndex: String.Index
		if let start = from, start >= 0 {
			startIndex = self.index(self.startIndex, offsetBy: start)
		} else {
			startIndex = self.startIndex
		}
		
		let endIndex: String.Index
		if let end = to, end >= 0, end < self.characters.count {
			endIndex = self.index(self.startIndex, offsetBy: end + 1)
		} else {
			endIndex = self.endIndex
		}
		
		return self[startIndex ..< endIndex]
	}
}

// change the background of a button
extension UIButton {
	func setBackgroundColor(color: UIColor, forState: UIControlState) {
		UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
		UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
		UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
		let colorImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		self.setBackgroundImage(colorImage, for: forState)
	}
}

extension Array {
	public func toDictionary() -> [String:Element] {
		var dictionary = [String:Element]()
		var index = 0
		for element in self {
			dictionary["\(index)"] = element
			index += 1
		}
		return dictionary
	}
}

// Lucriment Color Pallete
struct LUCColor {
	static var black = UIColor(red:0.18, green:0.20, blue:0.20, alpha:1.0)
	static var gray = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)
	static var lightGray = UIColor(red:0.87, green:0.90, blue:0.90, alpha:1.0)
	static var blue = UIColor(red:0.13, green:0.66, blue:0.88, alpha:1.0)
	static var red = UIColor(red:0.95, green:0.38, blue:0.32, alpha:1.0)
}

@IBDesignable class TopAlignedLabel: UILabel {
	override func drawText(in rect: CGRect) {
		if let stringText = text {
			let stringTextAsNSString = stringText as NSString
			let labelStringSize = stringTextAsNSString.boundingRect(with: CGSize(width: self.frame.width,height: CGFloat.greatestFiniteMagnitude),
			                                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
			                                                        attributes: [NSFontAttributeName: font],
			                                                        context: nil).size
			super.drawText(in: CGRect(x:0,y: 0,width: self.frame.width, height:ceil(labelStringSize.height)))
		} else {
			super.drawText(in: rect)
		}
	}
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		layer.borderWidth = 1
		layer.borderColor = UIColor.black.cgColor
	}
}

public extension UISearchBar {
	
	public func setTextColor(color: UIColor) {
		let svs = subviews.flatMap { $0.subviews }
		guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
		tf.textColor = color
	}
}

extension Date {
	var millisecondsSince1970:Int64 {
		return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
	}
	
	var millisecondsSince1970InUTC:Int64 {
		let dateInUTC = Calendar.current.date(from: Calendar.current.dateComponents(in: TimeZone(abbreviation: "UTC")!, from: self))
		return Int64((dateInUTC!.timeIntervalSince1970 * 1000.0).rounded())
	}
	
	init(milliseconds:Int) {
		self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
	}
	
	init(millisecondsIntUTC:Int) {
		let date = Date(timeIntervalSince1970: TimeInterval(millisecondsIntUTC / 1000))
		self = Calendar.current.date(from: Calendar.current.dateComponents(in: TimeZone(abbreviation: "UTC")!, from: date))!
	}
	
}

class RoundedImageView: UIImageView {
	override func layoutSubviews() {
		super.layoutSubviews()
		let radius: CGFloat = self.bounds.size.width / 2.0
		self.layer.cornerRadius = radius
		self.clipsToBounds = true
	}
}

enum MessageOwner {
	case sender
	case receiver
}

extension UIColor {
	convenience init(colorWithHexValue value: Int, alpha: CGFloat = 1.0) {
		self.init(
			red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(value & 0x0000FF) / 255.0,
			alpha: alpha
		)
	}
}

extension Date {
	func day() -> Date {
		let dateComponents = Calendar.current.dateComponents([.calendar, .day, .era, .month, .quarter, .timeZone, .weekday, .weekdayOrdinal, .weekOfMonth, .weekOfYear, .year, .yearForWeekOfYear], from: self)
		return Calendar.current.date(from: dateComponents)!
	}
	
	func startOfMonth() -> Date {
		return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
	}
	
	func endOfMonth() -> Date {
		return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
	}
}

extension String {
	public func index(of char: Character) -> Int? {
		if let idx = characters.index(of: char) {
			return characters.distance(from: startIndex, to: idx)
		}
		return nil
	}
}

extension Double {
	/// Rounds the double to decimal places value
	func rounded(toPlaces places:Int) -> Double {
		let divisor = pow(10.0, Double(places))
		return (self * divisor).rounded() / divisor
	}
}
