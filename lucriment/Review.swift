//
//  Review
//  lucriment
//
//  Created by Anton Lysov on 2017-10-09.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation

struct Review {
	
	var author: String
	var authorId: String
	var rating: Int
	var text: String
	var timeStamp: Int
	
	func toDictionary() -> [String : Any] {
		var dictionary = [String: Any]()
		
		dictionary["author"] = self.author
		dictionary["authorId"] = self.authorId
		dictionary["rating"] = self.rating
		dictionary["text"] = self.text
		dictionary["timeStamp"] = self.timeStamp
		
		return dictionary
	}
	
}
