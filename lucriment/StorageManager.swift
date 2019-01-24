//
//  StorageManager.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-11.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseStorage

class StorageManager {
	
	static var shared = StorageManager()
	fileprivate let _storageRef = Storage.storage().reference()
	
	func downloadProfileImageFor(_ id: String, _ completion: @escaping (UIImage?, Error?) -> ()) {
		let imagesRef = _storageRef.child("ProfileImages/\(id)")
			
		imagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
			if let error = error {
				completion(nil, error)
			} else {
				if let data = data, let image = UIImage(data: data) {
					completion(image, nil)
				} else {
					completion(nil, StorageManagerError.firebase)
				}
			}
		}
	}
	
	func upload(profileImage: UIImage, _ completion: @escaping (String?, Error?) -> ()) {
		if let userId = Auth.auth().currentUser?.uid {
			let imagesRef = _storageRef.child("ProfileImages/\(userId)")
			let metadata = StorageMetadata()
			metadata.contentType = "image/jpeg"
			if let uploadImage = UIImagePNGRepresentation(profileImage) {
				imagesRef.putData(uploadImage, metadata: metadata, completion: { (metadata, error) in
					if let error = error {
						completion(nil, error)
					} else {
						if let profileImagePath = metadata?.downloadURLs?.first {
							// multipath update for the profile image under tutor and user do the below line on complete
							UserManager.shared.profileImage = profileImagePath.absoluteString
							completion(profileImagePath.absoluteString, nil)
						} else {
							completion(nil, StorageManagerError.firebase)
						}
					}
				})
			} else {
				completion(nil, StorageManagerError.firebase)
			}
		} else {
			completion(nil, StorageManagerError.firebase)
		}
	}
}

enum StorageManagerError: Error {
	case firebase
	case unknown
}

extension StorageManagerError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .firebase:
			return NSLocalizedString("Error connecting to the Firebase", comment: "ChatManagerError")
		case .unknown:
			return NSLocalizedString("Unknown Error", comment: "ChatManagerError")
		}
	}
}
