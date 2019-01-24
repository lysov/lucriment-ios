//
//  ReceiverCell.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-19.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class ReceiverCell: UITableViewCell {
	
	@IBOutlet weak var message: UITextView!
	@IBOutlet weak var messageBackground: UIImageView!
	
	func clearCellData()  {
		self.message.text = nil
		self.message.isHidden = false
		self.messageBackground.image = nil
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.selectionStyle = .none
		self.message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
		self.messageBackground.layer.cornerRadius = 15
		self.messageBackground.clipsToBounds = true
	}
}
