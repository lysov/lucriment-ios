//
//  InfoCell.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-08.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class InfoCell: UITableViewCell {

	@IBOutlet var cellText: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
