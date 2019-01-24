//
//  Format.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-21.
//  Copyright © 2017 Anton Lysov. All rights reserved.
//

import Foundation

enum RegularExpressionFor: String {
	case name = "^[A-Za-z]{1,20}$"
	case headline = "^[A-Za-z0-9.,-]{0,60}$"
	case password = "^[A-Za-z0-9@%+/'!#$^?:(){}~`-]{6,128}$"
	case email = "^(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$"
	//Payment Info
	case cardNumber = "^[0-9]{12,19}$"
	case expires = "^[0-9]{4}$"
	case cvv = "^[0-9]{1,3}$"
}

class Format {
	static func isValidFor(name: String) -> Bool {
		
		let nameLength = name.characters.count
		guard nameLength >= 1, nameLength <= 20 else { return false }
		
		let nameRegularExpression = RegularExpressionFor.name.rawValue
		
		do {
			let regularExpression = try NSRegularExpression(pattern: nameRegularExpression)
			let nameNSString = name as NSString
			let matches = regularExpression.matches(in: name, range: NSRange(location: 0, length: nameNSString.length))
			
			if matches.count == 0 {
				return false
			}
		} catch {
			return false
		}
		
		return true
	}
	
	static func isValidFor(headline: String) -> Bool {
		
		let headlineLength = headline.characters.count
		guard headlineLength >= 0, headlineLength <= 60 else { return false }
		
		return true
	}
	
	static func isValidFor(about: String) -> Bool {
		
		let aboutLength = about.characters.count
		guard aboutLength >= 0, aboutLength <= 500 else { return false }
		
		return true
	}
	
	static func isValidFor(email: String) -> Bool {
		
		let emailLength = email.characters.count
		guard emailLength >= 6, emailLength <= 128 else { return false }
		
		let emailRegularExpression = RegularExpressionFor.email.rawValue
		
		do {
			let regularExpression = try NSRegularExpression(pattern: emailRegularExpression)
			let emailNSString = email as NSString
			let matches = regularExpression.matches(in: email, range: NSRange(location: 0, length: emailNSString.length))
			
			if matches.count == 0 {
				return false
			}
		} catch {
			return false
		}
		return true
	}
	
	static func isValidFor(password: String) -> Bool {
		
		let passwordLength = password.characters.count
		guard passwordLength >= 6, passwordLength <= 128 else { return false }
		
		let passwordRegularExpression = RegularExpressionFor.password.rawValue
		
		do {
			let regularExpression = try NSRegularExpression(pattern: passwordRegularExpression)
			let passwordNSString = password as NSString
			let matches = regularExpression.matches(in: password, range: NSRange(location: 0, length: passwordNSString.length))
			
			if matches.count == 0 {
				return false
			}
		} catch {
			return false
		}
		
		return true
	}
	
	static func isValidFor(cardNumber: String) -> Bool {
		
		let cardNumberLength = cardNumber.characters.count
		switch cardNumberLength {
		case 12...19:
			return true
		default:
			return false
		}
	}
	
	static func isValidFor(expires: String) -> Bool {
		
		let expiresLength = expires.characters.count
		switch expiresLength {
		case 1...6:
			break
		default:
			return false
		}
		
		// checks month
		if let month = Int(expires.substring(from: 0, to: 1)) {
			switch month {
			case 1...12:
				return true
			default:
				return false
			}
		} else {
			return false
		}

	}
	
	static func isValidFor(cvv: String) -> Bool {
		
		let cvvLength = cvv.characters.count
		switch cvvLength {
		case 1...3:
			return true
		default:
			return false
		}
	}
	
	static func isValidFor(phoneNumber: String) -> Bool {
		var formattedPhoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
		formattedPhoneNumber = formattedPhoneNumber.replacingOccurrences(of: "(", with: "")
		formattedPhoneNumber = formattedPhoneNumber.replacingOccurrences(of: ")", with: "")
		formattedPhoneNumber = formattedPhoneNumber.replacingOccurrences(of: "-", with: "")
		
		let phoneNumberLength = formattedPhoneNumber.characters.count
		if phoneNumberLength == 10 {
			return true
		} else {
			return false
		}
	}
	
	static func isValidFor(postalCode: String) -> Bool {
		var formattedPostalCode = postalCode.replacingOccurrences(of: " ", with: "")
		
		let phonePostalCodeLength = formattedPostalCode.characters.count
		if phonePostalCodeLength == 6 {
			return true
		} else {
			return false
		}
	}
	
	static func isValidFor(sin: String) -> Bool {
		var formattedSIN = sin.replacingOccurrences(of: " ", with: "")
		
		let formattedSINLength = formattedSIN.characters.count
		if formattedSINLength == 9 {
			return true
		} else {
			return false
		}
	}
	
	static func isValidFor(city: String) -> Bool {
		
		let cityLength = city.characters.count
		if cityLength >= 1, cityLength <= 60 {
			return true
		} else {
			return false
		}

	}
	
	static func isValidFor(address: String) -> Bool {
		
		let addressLength = address.characters.count
		if addressLength >= 1, addressLength <= 60 {
			return true
		} else {
			return false
		}
	}
}
