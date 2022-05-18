//
//  NotificationsController.swift
//  flicsy
//
//  Created by Taylor  Lallas on 5/18/22.
//

import Foundation
import UserNotifications
import UIKit
import Firebase

class NotificationsController: UIViewController, UNUserNotificationCenterDelegate {
    
    func scheduleLocal(time: Date) {
        registerCategories()
        let content = UNMutableNotificationContent()
        content.title = "Reveal your daily photo"
        content.body = "Open Flicsy to reflect on your surpise flic."
        content.sound = UNNotificationSound.default
        content.launchImageName = "AppIcon"
        content.categoryIdentifier = "revealReminder"
        
        let dateComp = Calendar.current.dateComponents([.weekday, .hour,
                                                        .minute], from: time)
        print(dateComp)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
//        let startSession = UNNotificationAction(identifier: "start", title: "Start a Therapy Session", options: [])
        let category = UNNotificationCategory(identifier: "revealReminder", actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options:.customDismissAction)
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //let userInfo = response.notification.request.content.userInfo
       // let sceneDel = SceneDelegate()
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier : //user swiped to unlock
            print ("default identifier")
        case "start" :
            print("opened from notification")
            Analytics.logEvent("opened_notification", parameters: ["time": Date()])
            //code to open to a specific scene
        default :
            break
        }
        completionHandler()
    }
    
    func establishNotificationPermissions() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .authorized {
                // Notification permission granted, do nothing
            } else if settings.authorizationStatus == .denied {
                // Notification permission was previously denied, go to settings & privacy to re-enable
            } else if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                        if settings.authorizationStatus == .authorized {
                            Analytics.logEvent("notification_authorized", parameters: ["authorized": true])
                        } else {
                            Analytics.logEvent("notification_authorized", parameters: ["authorized": false])
                        }
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        })
    }

    

    
}


