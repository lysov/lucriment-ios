//
//  EditUserProfileImageCell.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-12.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

protocol UserProfileImageDelegate {
	func choosePhoto()
}

class EditUserProfileImageCell: UITableViewCell {
	
	var delegate: UserProfileImageDelegate!
	
	@IBOutlet weak var profilePhotoBackgroundView: UIView!
	@IBOutlet weak var defaultProfilePhotoImageView: UIImageView!
	@IBOutlet weak var profilePhotoImageView: UIImageView!
	@IBOutlet weak var editProfilePhotoButton: UIButton!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.profilePhotoBackgroundView.layer.cornerRadius = profilePhotoBackgroundView.bounds.size.width/2
		self.profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.bounds.size.width/2
		let gesture = UITapGestureRecognizer(target: self, action: #selector(EditUserProfileImageCell.profilePhotoDidSelect))
		self.profilePhotoBackgroundView.addGestureRecognizer(gesture)
	}
	
	@IBAction func changeProfilePhotoButtonDidPress(_ sender: Any) {
		self.delegate.choosePhoto()
	}
	
	func profilePhotoDidSelect() {
		self.delegate.choosePhoto()
	}
}
