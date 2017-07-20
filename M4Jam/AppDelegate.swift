//
//  AppDelegate.swift
//  M4Jam
//
//  Created by Ryann Consalo on 2017/07/03.
//  Copyright © 2017 Ryann Consalo. All rights reserved.
//

import UIKit
import UserNotifications
import Google



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {

    var window: UIWindow?
    
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"
    let subscriptionTopic = "/topics/global"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //registerForPushNotifications()
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        // [END_EXCLUDE]
        // Register for remote notifications
        if #available(iOS 8.0, *) {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // Fallback
            let types: UIRemoteNotificationType = [.alert, .badge, .sound]
            application.registerForRemoteNotifications(matching: types)
        }
        
        // [END register_for_remote_notifications]
        // [START start_gcm_service]
        let gcmConfig = GCMConfig.default()
        gcmConfig?.receiverDelegate = self as! GCMReceiverDelegate
        GCMService.sharedInstance().start(with: gcmConfig)
        // [END start_gcm_service]
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        GCMService.sharedInstance().disconnect()
        // [START_EXCLUDE]
        self.connectedToGCM = false
        // [END_EXCLUDE]
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        GCMService.sharedInstance().connect(handler: { error -> Void in
            if let error = error as? NSError {
                print("Could not connect to GCM: \(error.localizedDescription)")
            } else {
                self.connectedToGCM = true
                print("Connected to GCM")
                // [START_EXCLUDE]
                self.subscribeToTopic()
                // [END_EXCLUDE]
            }
        })
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }

    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
        //let instanceIDConfig = GGLInstanceIDConfig.default()
        //instanceIDConfig?.delegate = self as! GGLInstanceIDDelegate
        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
       /* GGLInstanceID.sharedInstance().start(with: instanceIDConfig)
        NSEnumerationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken as AnyObject,
                               kGGLInstanceIDAPNSServerTypeSandboxOption:true as AnyObject]
        GGLInstanceID.sharedInstance().token(withAuthorizedEntity: gcmSenderID,
                                             scope: kGGLInstanceIDScopeGCM, options: NSEnumerationOptions, handler: NSAssertionHandler)
        */
        // [END receive_apns_token]
        // [START get_gcm_reg_token]
        // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
        let instanceIDConfig = GGLInstanceIDConfig.default()
        instanceIDConfig?.delegate = self
        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
        GGLInstanceID.sharedInstance().start(with: instanceIDConfig)
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken as AnyObject,
                               kGGLInstanceIDAPNSServerTypeSandboxOption:true as AnyObject]
        GGLInstanceID.sharedInstance().token(withAuthorizedEntity: gcmSenderID,
                                             scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
        // [END get_gcm_reg_token]
        
        
        
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func registrationHandler(_ registrationToken: String?, error: Error?) {
        if let registrationToken = registrationToken {
            self.registrationToken = registrationToken
            print("Registration Token: \(registrationToken)")
            self.subscribeToTopic()
            let userInfo = ["registrationToken": registrationToken]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: self.registrationKey), object: nil, userInfo: userInfo)
        } else if let error = error {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: self.registrationKey), object: nil, userInfo: userInfo)
        }
    }
    
    
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        if registrationToken != nil && connectedToGCM {
            GCMPubSub.sharedInstance().subscribe(withToken: self.registrationToken, topic: subscriptionTopic,
                                                 options: nil, handler: { error -> Void in
                                                    if let error = error as? NSError {
                                                        // Treat the "already subscribed" error more gently
                                                        if error.code == 3001 {
                                                            print("Already subscribed to \(self.subscriptionTopic)")
                                                        } else {
                                                            print("Subscription failed: \(error.localizedDescription)")
                                                        }
                                                    } else {
                                                        self.subscribedToTopic = true
                                                        NSLog("Subscribed to \(self.subscriptionTopic)")
                                                    }
            })
        }
    }
    
    func application( _ application: UIApplication,
                      didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("Notification received: \(userInfo)")
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo)
        // Handle the received message
        // [START_EXCLUDE]
        NotificationCenter.default.post(name: Notification.Name(rawValue: messageKey), object: nil,
                                        userInfo: userInfo)
        // [END_EXCLUDE]
    }
    
    func application( _ application: UIApplication,
                      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                      fetchCompletionHandler handler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Notification received: \(userInfo)")
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo)
        // Handle the received message
        // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
        // [START_EXCLUDE]
        NotificationCenter.default.post(name: Notification.Name(rawValue: messageKey), object: nil,
                                        userInfo: userInfo)
        handler(UIBackgroundFetchResult.noData)
        // [END_EXCLUDE]
    }
    // [END ack_message_reception]
    
    
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().token(withAuthorizedEntity: gcmSenderID,
                                             scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }

    
}

