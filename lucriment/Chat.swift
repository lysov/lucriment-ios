//
//  Chat.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-13.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation

struct Chat {
	var messages: [Message]
	var lastMessage: Message? {
		return self.messages.last
	}
	
	static func order(_ chats: [Chat]) -> [Chat] {
		if chats.count >= 2 {
			return chats.sorted { (lhs, rhs) in
				return lhs.messages.last!.timestamp > rhs.messages.last!.timestamp
			}
		} else {
			return chats
		}
	}
}
