//
//  HeadlineCell.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-08.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class HeadlineCell: UITableViewCell {
	
	@IBOutlet weak var textView: UITextView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		textView.text = "60 maximum allowed characters."
		textView.textColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0)
		textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
		let gesture = UITapGestureRecognizer(target: self, action: #selector(HeadlineCell.didSelectCell))
		addGestureRecognizer(gesture)
	}
	
	func didSelectCell() {
		self.textView.becomeFirstResponder()
	}
}
