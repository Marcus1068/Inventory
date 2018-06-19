//
//  Helper.swift
//  Inventory
//
//  Created by Marcus Deuß on 17.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class Helper: NSObject {
    
    // used in about view controller and for sending support emails
    static let versionString = "0.2"
    
    // name of the app in about view
    static let appNameString = "Inventory"
    static let emailAdr = "mdeuss@gmail.com"
    static let website = "http://www.marcus-deuss.de"
    static let cvsFile = "inventoryexport.csv"
    
    // general functions
    
    
    // sending a local notification
    
    /// send a local notification (does not require server)
    ///
    /// - Parameters:
    ///   - title: notification title
    ///   - subtitle: notification subtitle
    ///   - body: notification body text
    ///   - badge: when using badge show number of messages in icon
    class func sendLocalNotification(title: String, subtitle: String, body: String, badge: NSNumber) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = badge
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                        repeats: false)
        
        let requestIdentifier = "demoNotification"
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request,
                                               withCompletionHandler: { (error) in
                                                // Handle error
        })
    }
    
    // get a UUID
    // request.predicate = NSPredicate(format: "uuid == %@", withUuid)
    
    class func generateUUID() -> String{
        
        return UUID().uuidString
    }

    class func generateUUID() -> UUID{
        return UUID()
    }
}

