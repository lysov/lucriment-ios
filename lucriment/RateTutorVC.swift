//
//  RateTutorVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-10-08.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import Cosmos

class RateTutorVC: UIViewController {

	@IBOutlet weak var ratingCosmosView: CosmosView!
	@IBOutlet weak var textView: UITextView!
	var sessionDetailsVC: UserPastSessionDetailsVC!
	
	var text: String!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.textView.selectedTextRange = textView.textRange(from: self.textView.beginningOfDocument, to: self.textView.beginningOfDocument)
		self.textView.becomeFirstResponder()
		
		self.ratingCosmosView.settings.fillMode = .full
    }

	@IBAction func cancelButtonDidPress(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func doneButtonDidPress(_ sender: Any) {
		
		if let text = self.text {
			let author = self.sessionDetailsVC.session.studentName
			let authorId = self.sessionDetailsVC.session.studentId
			let rating = Int(self.ratingCosmosView.rating)
			let text = text
			let timeStamp = Int(Date().timeIntervalSince1970 * 1_000)
			
			let review = Review(author: author, authorId: authorId, rating: rating, text: text, timeStamp: timeStamp)
			
			DatabaseManager.shared.rate(.tutor, session: self.sessionDetailsVC.session, review: review.toDictionary()) { (error) in
				self.sessionDetailsVC.session.tutorReview = review
				self.sessionDetailsVC.tableView.reloadData()
				self.dismiss(animated: true, completion: nil)
			}
		} else {
			self.presentAlert()
		}
	}
}

// textView methods
extension RateTutorVC: UITextViewDelegate {
	
	func textViewDidChange(_ textView: UITextView) {
		self.text = self.textView.text
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		
		// Combine the textView text and the replacement text to
		// create the updated text string
		let currentText = textView.text as NSString
		let updatedText = currentText.replacingCharacters(in: range, with: text)
		
		// If updated text view will be empty, add the placeholder
		// and set the cursor to the beginning of the text view
		if updatedText.isEmpty {
			
			textView.text = "Review"
			self.text = ""
			textView.textColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0)
			
			textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
			
			return false
		}
			
			// Else if the text view's placeholder is showing and the
			// length of the replacement string is greater than 0, clear
			// the text view and set its color to black to prepare for
			// the user's entry
		else if textView.textColor == UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0) && !text.isEmpty {
			textView.text = nil
			textView.textColor = .black
		}
		
		return true
		
		
	}
	
	func textViewDidChangeSelection(_ textView: UITextView) {
		if self.view.window != nil {
			if textView.textColor == UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0) {
				textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
			}
		}
	}
}

extension RateTutorVC {
	internal func presentAlert() {
		let alert = UIAlertController(title: "Review cannot be empty", message: nil, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}
