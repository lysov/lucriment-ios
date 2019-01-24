//
//  ChatManager.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-13.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class ChatManager {
	
	static var shared = ChatManager()
	fileprivate let firebaseDatabaseReference = Database.database().reference()
	
	fileprivate var chatListenerReferese: DatabaseReference!
	fileprivate var handle: UInt!
	
	func downloadChats(_ completion: @escaping ([Chat]?, Error?) -> () ) {
		self.firebaseDatabaseReference.child("chats").child(UserManager.shared.id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				var chats = [Chat]()
				for chatSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
					
					var messages = [Message]()
					for messageSnapshot in chatSnapshot.children.allObjects as! [DataSnapshot] {
						
						if let message = messageSnapshot.value as? [String:Any] {
							if let receiverId = message["receiverId"] as? String,
								let receiverName = message["receiverName"] as? String,
								let senderId = message["senderId"] as? String,
								let senderName = message["senderName"] as? String,
								let text = message["text"] as? String,
								let timestamp = message["timestamp"] as? Int {
								messages.append(Message(receiverId: receiverId, receiverName: receiverName, senderId: senderId, senderName: senderName, text: text, timestamp: timestamp))
							} else {
								completion(nil, ChatManagerError.unknown)
							}
						} else {
							completion(nil, ChatManagerError.unknown)
						}
					}
					chats.append(Chat(messages: messages))
				}
				let orderedChats = Chat.order(chats)
				completion(orderedChats, nil)
			} else {
				completion(nil, ChatManagerError.noMessages)
			}
		}
	}
	
	func listenTo(_ chatId: String, _ completion: @escaping ([Message]?, Error?) -> () ) {
		self.chatListenerReferese = self.firebaseDatabaseReference.child("chats").child(UserManager.shared.id).child(chatId)
		self.handle = self.chatListenerReferese.observe(.value) { (snapshot: DataSnapshot) in
			if snapshot.exists() {
				var messages = [Message]()
				for messageSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
					if let message = messageSnapshot.value as? [String:Any] {
						if let receiverId = message["receiverId"] as? String,
							let receiverName = message["receiverName"] as? String,
							let senderId = message["senderId"] as? String,
							let senderName = message["senderName"] as? String,
							let text = message["text"] as? String,
							let timestamp = message["timestamp"] as? Int {
							messages.append(Message(receiverId: receiverId, receiverName: receiverName, senderId: senderId, senderName: senderName, text: text, timestamp: timestamp))
						} else {
							completion(nil, ChatManagerError.unknown)
						}
					} else {
						completion(nil, ChatManagerError.unknown)
					}
				}
				completion(messages, nil)
			} else {
				completion(nil, ChatManagerError.noMessages)
			}
		}
	}
	
	func removeObservers() {
		self.chatListenerReferese.removeObserver(withHandle: self.handle)
	}
	
	func send(_ message: Message) {
		let childByAutoIdKey = self.firebaseDatabaseReference.childByAutoId().key
		let receiverId = message.id
		self.firebaseDatabaseReference.child("chats").child(UserManager.shared.id).child(receiverId).child(childByAutoIdKey).setValue(message.toDictionary())
		if UserManager.shared.id != receiverId {
			self.firebaseDatabaseReference.child("chats").child(receiverId).child(UserManager.shared.id).child(childByAutoIdKey).setValue(message.toDictionary())
		}
		
		self.firebaseDatabaseReference.child("messageNotifications").child(receiverId).childByAutoId().child("from").setValue(UserManager.shared.id)
	}
}

enum ChatManagerError: Error {
	case firebase
	case unknown
	case noMessages
}

extension ChatManagerError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .firebase:
			return NSLocalizedString("Error connecting to the Firebase", comment: "ChatManagerError")
		case .unknown:
			return NSLocalizedString("Unknown Error", comment: "ChatManagerError")
		case .noMessages:
			return NSLocalizedString("No Messages", comment: "ChatManagerError")
		}
	}
}
