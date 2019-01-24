//
//  Message.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-13.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation

struct Message {
	var owner: MessageOwner {
		if UserManager.shared.id == receiverId {
			return .sender
		} else {
			return .receiver
		}
	}
	let receiverId: String
	let receiverName: String
	let senderId: String
	let senderName: String
	let text: String
	let timestamp: Int
	
	// get name of a person you have a chat for ChatCell
	var name: String {
		if UserManager.shared.id == self.receiverId {
			return senderName
		} else {
			return receiverName
		}
	}
	// get id of a person you have a chat for ChatCell
	var id: String {
		if UserManager.shared.id == self.receiverId {
			return senderId
		} else {
			return receiverId
		}
	}
	
	var date: String {
		let date = Date(timeIntervalSince1970: TimeInterval(self.timestamp/1000))
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone.current
		dateFormatter.locale = NSLocale.current
		dateFormatter.dateFormat = "d MMM, hh:mm a"
		return dateFormatter.string(from: date)
	}
	
	func toDictionary() -> [String : Any] {
		var dictionary: [String:Any] = [:]
		dictionary["receiverId"] = self.receiverId
		dictionary["receiverName"] = self.receiverName
		dictionary["senderId"] = self.senderId
		dictionary["senderName"] = self.senderName
		dictionary["text"] = self.text
		dictionary["timestamp"] = self.timestamp
		
		return dictionary
	}
}
