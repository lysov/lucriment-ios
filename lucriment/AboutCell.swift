//
//  AboutCell.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-26.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit

class AboutCell: UITableViewCell {
	
	@IBOutlet weak var textView: UITextView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		textView.text = "500 maximum allowed characters."
		textView.textColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0)
		textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
		let gesture = UITapGestureRecognizer(target: self, action: #selector(AboutCell.didSelectCell))
		addGestureRecognizer(gesture)
	}
	
	func didSelectCell() {
		self.textView.becomeFirstResponder()
	}
}
