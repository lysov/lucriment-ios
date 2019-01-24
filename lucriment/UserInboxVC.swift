//
//  UserInboxVC.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-09-13.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import SwiftMessages

class UserInboxVC: UITableViewController, UserDelegate {
	
	// No Messages
	@IBOutlet weak var backgroundView: UIView!
	
	// Network Disconnection
	@IBOutlet weak var activityView: UIView!
	@IBOutlet weak var noNetworkConnectionLabel: UILabel!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

	// Model
	var chats = [Chat]()
	var images = [String: UIImage?]()
	
	// UserInfoDelegate Implementation
	var user: User!
	var chat: Chat!
	var image: UIImage!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(UserInboxVC.refresh), for: .valueChanged)
		self.refreshControl?.layoutIfNeeded()
		
        self.tableView.tableFooterView = UIView()
		self.setupTableViewBackgroundView()
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
				ChatManager.shared.downloadChats { (chats, error) in
					if let error = error as? ChatManagerError {
						print(error.localizedDescription)
						self.dismissActivityView()
					} else {
						if let chats = chats {
							self.chats = chats
							
							self.tableView.reloadData()
							self.dismissActivityView()
							
							// downloads images for the chats
							self.images = [String: UIImage?]()
							for chat in self.chats {
								if let id = chat.lastMessage?.id {
									StorageManager.shared.downloadProfileImageFor(id) { (image, error)  in
										if let error = error {
											print(error.localizedDescription)
											self.images[id] = image
										} else {
											self.images[id] = image
											self.tableView.reloadData()
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

extension UserInboxVC {
	func refresh(sender: Any) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		if ReachabilityManager.shared().reachabilityStatus == .notReachable, self.activityView.isHidden == true {
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.refreshControl?.endRefreshing()
			self.showNoNetworkNotification()
		} else if ReachabilityManager.shared().reachabilityStatus == .notReachable {
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.refreshControl?.endRefreshing()
		} else {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			DispatchQueue.main.async {
				ChatManager.shared.downloadChats { (chats, error) in
					if let error = error as? ChatManagerError {
						print(error.localizedDescription)
						self.refreshControl?.endRefreshing()
						self.dismissActivityView()
					} else {
						if let chats = chats {
							self.chats = chats
							
							self.refreshControl?.endRefreshing()
							self.tableView.reloadData()
							self.dismissActivityView()
							
							// downloads images for the chats
							self.images = [String: UIImage?]()
							for chat in self.chats {
								if let id = chat.lastMessage?.id {
									StorageManager.shared.downloadProfileImageFor(id) { (image, error)  in
										if let error = error {
											print(error.localizedDescription)
											self.images[id] = image
										} else {
											self.images[id] = image
											self.tableView.reloadData()
										}
									}
								}
							}
							
						}
					}
				}
			}
		}
	}
}

extension UserInboxVC {
	
	func setupTableViewBackgroundView() {
		self.tableView.backgroundView = self.backgroundView
		self.tableView.backgroundView?.isHidden = true
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		
		let row = indexPath.row
		
		// UserInfoDelegate
		let chat = self.chats[row]
		if let id = chat.lastMessage?.id, let image = self.images[id] {
			self.image = image
		} else {
			self.image = nil
		}
		if let name = self.chats[row].lastMessage?.name, let id = chat.lastMessage?.id {
			self.user = User(name: name, id: id)
		}
		
		self.presentUserChatVC()
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "chatCell")! as! ChatCell
		
		cell.profileImageView.isHidden = true
		cell.profileImageView.image = nil
		if let id = self.chats[row].lastMessage?.id, let image = self.images[id] {
			cell.profileImageView.image = image
			cell.profileImageView.isHidden = false
		}
		cell.nameLabel.text = self.chats[row].lastMessage?.name
		cell.messageLabel.text = self.chats[row].lastMessage?.text
		cell.timeLabel.text = self.chats[row].lastMessage?.date
		return cell
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if self.chats.count == 0 {
			self.tableView.separatorStyle = .none
			self.tableView.backgroundView?.isHidden = false
		} else {
			self.tableView.separatorStyle = .singleLine
			self.tableView.backgroundView?.isHidden = true
		}
		
		return self.chats.count
	}
}

// MARK:- Network Disconnection
extension UserInboxVC {
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

extension UserInboxVC {
	// presents UserChatVC
	fileprivate func presentUserChatVC() {
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "StudentInbox", bundle: nil)
		let vc = mainStoryboard.instantiateViewController(withIdentifier: "UserChatVC") as! UserChatVC
		vc.delegate = self as UserDelegate
		self.navigationController?.pushViewController(vc, animated: true)
	}
}
