//
//  ReachabilityManager.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-23.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import Foundation
import ReachabilitySwift

// Protocol for listenig network status change
public protocol NetworkStatusListener : class {
	func networkStatusDidChange(status: Reachability.NetworkStatus)
}

class ReachabilityManager: NSObject {
	// Array of delegates which are interested to listen to network status change
	var listeners = [NetworkStatusListener]()
	var IPAddress: String!
	
	internal static var reachabilityManager: ReachabilityManager!
	
	static func shared() -> ReachabilityManager {
		if let _ = self.reachabilityManager {
			return self.reachabilityManager
		} else {
			self.reachabilityManager = ReachabilityManager()
			return self.reachabilityManager
		}
	}
	
	// Boolean to track network reachability
	var isNetworkAvailable : Bool {
		return reachabilityStatus != .notReachable
	}
	// Tracks current NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN)
	var reachabilityStatus: Reachability.NetworkStatus = .notReachable
	
	// Reachability instance for Network status monitoring
	internal let reachability = Reachability()!
	
	func reachabilityChanged(notification: Notification) {
		let reachability = notification.object as! Reachability
		
		switch reachability.currentReachabilityStatus {
		case .notReachable:
			self.reachabilityStatus = .notReachable
			self.IPAddress = nil
			debugPrint("Network became unreachable")
		case .reachableViaWiFi:
			self.reachabilityStatus = .reachableViaWiFi
			self.IPAddress = self.getIPAddress()
			debugPrint("Network reachable through WiFi")
		case .reachableViaWWAN:
			self.reachabilityStatus = .reachableViaWWAN
			self.IPAddress = self.getIPAddress()
			debugPrint("Network reachable through Cellular Data")
		}
		
		// Sending message to each of the delegates
		for listener in listeners {
			listener.networkStatusDidChange(status: reachability.currentReachabilityStatus)
		}
	}
	
	/// Adds a new listener to the listeners array
	///
	/// - parameter delegate: a new listener
	func addListener(listener: NetworkStatusListener){
		listeners.append(listener)
	}
	
	/// Removes a listener from listeners array
	///
	/// - parameter delegate: the listener which is to be removed
	func removeListener(listener: NetworkStatusListener){
		listeners = listeners.filter{ $0 !== listener}
	}
	
	// Starts monitoring the network availability status
	func startMonitoring() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: ReachabilityChangedNotification, object: reachability)
		do{
			try reachability.startNotifier()
		} catch {
			debugPrint("Could not start reachability notifier")
		}
	}
	
	// Stops monitoring the network availability status
	func stopMonitoring(){
		reachability.stopNotifier()
		NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
	}
	
	// Return IP address of WiFi interface (en0) as a String, or `nil`
	fileprivate func getIPAddress() -> String? {
		var address : String?
		
		// Get list of all interfaces on the local machine:
		var ifaddr : UnsafeMutablePointer<ifaddrs>?
		guard getifaddrs(&ifaddr) == 0 else { return nil }
		guard let firstAddr = ifaddr else { return nil }
		
		// For each interface ...
		for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
			let interface = ifptr.pointee
			
			// Check for IPv4 or IPv6 interface:
			let addrFamily = interface.ifa_addr.pointee.sa_family
			if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
				
				// Check interface name:
				let name = String(cString: interface.ifa_name)
				if  name == "en0" {
					
					// Convert interface address to a human readable string:
					var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
					getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
					            &hostname, socklen_t(hostname.count),
					            nil, socklen_t(0), NI_NUMERICHOST)
					address = String(cString: hostname)
				}
				if  name == "pdp_ip0" {
					
					// Convert interface address to a human readable string:
					var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
					getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
					            &hostname, socklen_t(hostname.count),
					            nil, socklen_t(0), NI_NUMERICHOST)
					address = String(cString: hostname)
				}
			}
		}
		freeifaddrs(ifaddr)
		
		return address
	}
}
