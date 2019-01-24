//
//  EarningsCell.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-09.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class EarningsCell: UITableViewCell {

	@IBOutlet weak var studentNameLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	
	
	
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
