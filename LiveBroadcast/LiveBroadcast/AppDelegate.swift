//
//  AppDelegate.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 05/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import UIKit
import AVFoundation
import HaishinKit
import Firebase
import UserNotifications

let Delegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
     let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setPreferredSampleRate(44_100)
            // https://stackoverflow.com/questions/51010390/avaudiosession-setcategory-swift-4-2-ios-12-play-sound-on-silent
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch (let error){
            print("audiosession \(error)")
        }
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        setUpNotification()
        
        switch User.shared.userType {
        case .subscriber,.arist:
            let main = UIStoryboard(name: "Main", bundle: nil)
            let profileVC = main.instantiateViewController(withIdentifier: "ProfileViewController")
            Delegate.window?.rootViewController = profileVC
            
        default:
            break
        }
        
        return true
    }
    
    
    
    func setUpNotification() {
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        UIApplication.shared.registerForRemoteNotifications()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        handleNotification(response.notification.request)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        handleNotification(notification.request)
        completionHandler([.alert,.sound])
    }
    
    func handleNotification(_ request: UNNotificationRequest) {
        
        let userInfo = request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        if let _ = userInfo["stream"] as? String, let _ = userInfo["date"] as? String {
            //live event
            NotificationCenter.default.post(name: goLiveNotification, object: nil, userInfo: userInfo)
            return
        }
        
        if let _ = userInfo["date"] as? String {
            //scheduled event
            NotificationCenter.default.post(name: scheduleLiveNotification, object: nil, userInfo: userInfo)
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token(FCM token): \(fcmToken)")
    }
}

extension AppDelegate {
    func subscribe(to topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            print("Subscribed to firebase messaging with topic: \(topic) and error: \(error?.localizedDescription ?? "No error")" )
        }
    }
    
    func unsubscribe(from topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { (error) in
            print("Unsubscribed from firebase messaging with topic: \(topic) and error: \(error?.localizedDescription ?? "No error")" )
        }
    }
}

extension AppDelegate {
    func sendNotification(with payload: [String: Any]) {
        let url = URL(string: "https://fcm.googleapis.com/v1/projects/livebroadcast-f7a53/messages:send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(firebasOauthToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])
        
        let session = URLSession(configuration:URLSessionConfiguration.default)
        
        session.dataTask(with: request) { (data, response, error) in
            print("response \(String(describing: response)) error \(String(describing: error))")
            
            if let data = data, let foo = String.init(data: data, encoding: .utf8) {
                print("server response \(foo)")
            }
        }.resume()
    }
}
