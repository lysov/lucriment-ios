//
//  TimeCell.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-02.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class TimeCell: UICollectionViewCell {
    
	@IBOutlet weak var timeLabel: UILabel!
	
	
	
	
	override var isSelected: Bool {
		didSet {
			self.contentView.backgroundColor = isSelected ? LUCColor.red : .white
			self.contentView.alpha = isSelected ? 0.8 : 1.0
			self.timeLabel.textColor = isSelected ? .white : LUCColor.black
		}
	}
}
