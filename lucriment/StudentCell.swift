//
//  StudentCell.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-08.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class StudentCell: UITableViewCell {
	
	@IBOutlet weak var profileImageBackgroundView: UIView!
	@IBOutlet weak var defaultProfileImageView: UIImageView!
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var headlineLabel: UILabel!
	
	@IBOutlet weak var ratingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
		
		self.profileImageBackgroundView.layer.cornerRadius = self.profileImageBackgroundView.bounds.size.width/2
		self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
