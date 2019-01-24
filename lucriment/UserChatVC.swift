//
//  UserChatVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-19.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class UserChatVC: UIViewController {
	
	// Network Disconnection
	@IBOutlet weak var activityView: UIView!
	@IBOutlet weak var noNetworkConnectionLabel: UILabel!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	//MARK: Properties
	@IBOutlet var inputBar: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var inputTextField: UITextField!
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
	override var inputAccessoryView: UIView? {
		get {
			self.inputBar.frame.size.height = self.barHeight
			self.inputBar.clipsToBounds = true
			return self.inputBar
		}
	}
	override var canBecomeFirstResponder: Bool{
		return true
	}
	
	let barHeight: CGFloat = 50

	var messages = [Message]()
	
	//MARK: Methods
	func customization() {
		//self.imagePicker.delegate = self
		self.tableView.estimatedRowHeight = self.barHeight
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.contentInset.bottom = self.barHeight
		self.tableView.scrollIndicatorInsets.bottom = self.barHeight
		self.navigationItem.title = self.delegate.user.name
	}
	
	var delegate: UserDelegate!
	
	//MARK: ViewController lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		self.customization()
		ChatManager.shared.listenTo(self.delegate.user.id) { (messages, error) in
			if let error = error {
				print(error.localizedDescription)
			} else {
				if let messages = messages {
					self.messages = messages
					DispatchQueue.main.async {
						self.tableView.reloadData()
						self.tableView.scrollToRow(at: IndexPath.init(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
					}
				}
			}
		}
		self.presentActivityView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable, self.activityView.isHidden == false {
			self.presentNoNetworkActivityView()
		}
		else if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.showNoNetworkNotification()
		} else {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			DispatchQueue.main.async {
				// download data
				UserManager.shared.refresh { (error) in
					if let error = error {
						print(error.localizedDescription)
					} else {
						self.tableView.reloadData()
					}
					self.dismissActivityView()
				}
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.inputBar.backgroundColor = UIColor.clear
		self.view.layoutIfNeeded()
		NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
		ChatManager.shared.removeObservers()
	}
	
	@IBAction func sendMessage(_ sender: Any) {
		if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			self.showNoNetworkNotification()
		} else {
			if let text = self.inputTextField.text {
				if text.characters.count > 1, text.characters.count <= 1000 {
					print(self.delegate.user.id)
					print(self.delegate.user.name)
					print(UserManager.shared.id)
					print(UserManager.shared.fullName)
					print(Date().millisecondsSince1970)
					let message = Message(receiverId: self.delegate.user.id, receiverName: self.delegate.user.name, senderId: UserManager.shared.id, senderName: UserManager.shared.fullName, text: text, timestamp: Int(Date().millisecondsSince1970))
					ChatManager.shared.send(message)
					self.inputTextField.text = ""
				}
			}
		}
	}
	
	//MARK: NotificationCenter handlers
	func showKeyboard(notification: Notification) {
		if let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
			let height = frame.cgRectValue.height
			self.tableView.contentInset.bottom = height
			self.tableView.scrollIndicatorInsets.bottom = height
			if self.messages.count > 0 {
				self.tableView.scrollToRow(at: IndexPath.init(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
			}
		}
	}
}

extension UserChatVC: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.messages.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch self.messages[indexPath.row].owner {
		case .receiver:
			let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
			cell.clearCellData()
			cell.message.text = self.messages[indexPath.row].text
			return cell
		case .sender:
			let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
			cell.clearCellData()
			
			if let image = self.delegate.image {
				cell.profilePic.image = image
			} else {
				cell.profilePic.image = #imageLiteral(resourceName: "Chat Image")
			}
			cell.message.text = self.messages[indexPath.row].text
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if tableView.isDragging {
			cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
			UIView.animate(withDuration: 0.3, animations: {
				cell.transform = CGAffineTransform.identity
			})
		}
	}
}

extension UserChatVC: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

// MARK:- Network Disconnection
extension UserChatVC {
	func presentActivityView() {
		self.activityView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
		self.activityIndicatorView.color = LUCColor.gray
		self.activityIndicatorView.startAnimating()
		self.activityIndicatorView.isHidden = false
		self.view.addSubview(self.activityView)
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	
	func dismissActivityView() {
		self.noNetworkConnectionLabel.isHidden = true
		self.activityIndicatorView.stopAnimating()
		self.activityView.isHidden = true
		self.activityView.removeFromSuperview()
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
	
	func presentNoNetworkActivityView() {
		self.activityIndicatorView.stopAnimating()
		self.activityIndicatorView.isHidden = true
		self.noNetworkConnectionLabel.isHidden = false
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
	
	func presentNoMessagesView() {
		self.noNetworkConnectionLabel.isHidden = true
		self.activityIndicatorView.stopAnimating()
		self.activityIndicatorView.isHidden = true
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
	
	func showNoNetworkNotification() {
		let notificationView: MessageView = try! SwiftMessages.viewFromNib(named: "NoNetworkNotification")
		notificationView.preferredHeight = 35
		var config = SwiftMessages.Config()
		config.duration = .seconds(seconds: 3)
		
		SwiftMessages.show(config: config, view: notificationView)
	}
}

protocol UserDelegate {
	var user: User! { get }
	var image: UIImage! { get }
}
