//
//  TextFieldCell.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-26.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {
	
	@IBOutlet var textField: UITextField!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		let gesture = UITapGestureRecognizer(target: self, action: #selector(TextFieldCell.didSelectCell))
		addGestureRecognizer(gesture)
	}
	
	func didSelectCell() {
		self.textField.becomeFirstResponder()
	}
}
