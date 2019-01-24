//
//  ProfilePhotoCell.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-24.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class ProfilePhotoCell: UITableViewCell {
	
	@IBOutlet weak var profilePhotoBackgroundView: UIView!
	@IBOutlet weak var defaultProfilePhotoImageView: UIImageView!
	@IBOutlet weak var profilePhotoImageView: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.profilePhotoBackgroundView.layer.cornerRadius = profilePhotoBackgroundView.bounds.size.width/2
		self.profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.bounds.size.width/2
	}
}
