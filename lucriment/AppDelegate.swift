 //
//  AppDelegate.swift
//  lucriment
//
//  Created by Anton Lysov on 2017-08-23.
//  Copyright © 2017 Lucriment Inc. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import GooglePlaces
import GoogleMaps
import Fabric
import Crashlytics
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	let gcmMessageIDKey = "gcm.message_id"

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		ReachabilityManager.shared().startMonitoring()
		
		// Fabric
		Fabric.with([Crashlytics.self])
		
		// Google Maps API
		GMSPlacesClient.provideAPIKey("TYPE_YOUR_GOOGLE_MAPS_API_KEY")
		GMSServices.provideAPIKey("TYPE_YOUR_GOOGLE_MAPS_API_KEY")
		
		// Use Firebase library to configure APIs
		FirebaseApp.configure()
		// Configures UserManager
		let _ = UserManager.shared
		GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
		FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
		
		// Firebase Notifications
		Messaging.messaging().delegate = self
		
		if #available(iOS 10.0, *) {
			// For iOS 10 display notification (sent via APNS)
			UNUserNotificationCenter.current().delegate = self
			
			let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
			UNUserNotificationCenter.current().requestAuthorization(
				options: authOptions,
				completionHandler: {_, _ in })
		} else {
			let settings: UIUserNotificationSettings =
				UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
			application.registerUserNotificationSettings(settings)
		}
		
		application.registerForRemoteNotifications()
		
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		let isFacebookURL = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options [UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
		
		let isGooglePlusURL = GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
		return isGooglePlusURL || isFacebookURL
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
		ReachabilityManager.shared().stopMonitoring()
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		ReachabilityManager.shared().startMonitoring()
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
		// If you are receiving a notification message while your app is in the background,
		// this callback will not be fired till the user taps on the notification launching the application.
		// TODO: Handle data of notification
		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)
		// Print message ID.
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: from 1st \(messageID)")
		}
		
		// Print full message.
		print(userInfo)
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
	                 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		// If you are receiving a notification message while your app is in the background,
		// this callback will not be fired till the user taps on the notification launching the application.
		// TODO: Handle data of notification
		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)
		// Print message ID.
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: from 2nd\(messageID)")
		}
		
		// Print full message.
		print(userInfo)
		
		completionHandler(UIBackgroundFetchResult.newData)
	}
	// [END receive_message]
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print("Unable to register for remote notifications: \(error.localizedDescription)")
	}
	
	// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
	// If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
	// the FCM registration token.
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		print("APNs token retrieved: \(deviceToken)")
		
		// With swizzling disabled you must set the APNs token here.
		// Messaging.messaging().apnsToken = deviceToken
	}
	
	// presents InitialVC
	func presentInitialVC() {
		self.window = UIWindow(frame: UIScreen.main.bounds)
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
		let navigationController = mainStoryboard.instantiateInitialViewController()
		if let window = self.window {
			window.rootViewController = navigationController
			window.makeKeyAndVisible()
		}
	}
	
	// presents presentTabBarController
	func presentStudentTabBarController() {
		self.window = UIWindow(frame: UIScreen.main.bounds)
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "Student", bundle: nil)
		let tabBarController = mainStoryboard.instantiateInitialViewController()
		UserManager.shared.mode = .student
		if let window = self.window {
			window.rootViewController = tabBarController
			window.makeKeyAndVisible()
		}
	}
	
	// presents TutorBarController
	func presentTutorBarController() {
		self.window = UIWindow(frame: UIScreen.main.bounds)
		let mainStoryboard: UIStoryboard = UIStoryboard(name: "Tutor", bundle: nil)
		let tabBarController = mainStoryboard.instantiateInitialViewController()
		UserManager.shared.mode = .tutor
		if let window = self.window {
			window.rootViewController = tabBarController
			window.makeKeyAndVisible()
		}
	}
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
	
	// Receive displayed notifications for iOS 10 devices.
	func userNotificationCenter(_ center: UNUserNotificationCenter,
	                            willPresent notification: UNNotification,
	                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		let userInfo = notification.request.content.userInfo
		
		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)
		// Print message ID.
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}
		
		// Print full message.
		print(userInfo)
		
		// Change this to your preferred presentation option
		completionHandler([.alert,.sound,.badge])
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter,
	                            didReceive response: UNNotificationResponse,
	                            withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo
		// Print message ID.
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}
		
		// Print full message.
		print(userInfo)
		
		completionHandler()
	}
}

extension AppDelegate : MessagingDelegate {
	
	func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
		print("Firebase registration token: \(fcmToken)")
	}
	
	// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
	// To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
	func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
		print("Received data message: \(remoteMessage.appData)")
	}
}
