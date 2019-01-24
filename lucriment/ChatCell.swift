//
//  ChatCell.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-13.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
	
	@IBOutlet weak var profilePhotoBackgroundView: UIView!
	@IBOutlet weak var defaultProfilePhotoImageView: UIImageView!
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var messageLabel: TopAlignedLabel!
	@IBOutlet weak var timeLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.profilePhotoBackgroundView.layer.cornerRadius = profilePhotoBackgroundView.bounds.size.width/2
		self.profileImageView.layer.cornerRadius = profileImageView.bounds.size.width/2
	}
}
