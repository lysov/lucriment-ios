//
//  LoadingOverlay.swift
//  app
//
//  Created by Igor de Oliveira Sa on 25/03/15.
//  Copyright (c) 2015 Igor de Oliveira Sa. All rights reserved.
//
//  Usage:
//
//  # Show Overlay
//  LoadingOverlay.shared.showOverlay(self.navigationController?.view)
//
//  # Hide Overlay
//  LoadingOverlay.shared.hideOverlayView()

import UIKit
import Foundation
import MBProgressHUD

public class ActivityIndicator {
	
	private var activityIndicator: MBProgressHUD!
	private var overlayView = UIView()
	
	class var shared: ActivityIndicator {
		struct Static {
			static let instance = ActivityIndicator()
		}
		return Static.instance
	}
	
	public func showAbove(_ view: UIView!) {
		overlayView = UIView(frame: UIScreen.main.bounds)
		overlayView.backgroundColor = UIColor(red:0.13, green:0.66, blue:0.88, alpha:1)
		self.activityIndicator = MBProgressHUD.showAdded(to: overlayView, animated: true)
		self.activityIndicator.label.text = "Loading..."
		view.addSubview(overlayView)
	}
	
	public func hide() {
		self.activityIndicator.hide(animated: true)
		overlayView.removeFromSuperview()
	}
}
