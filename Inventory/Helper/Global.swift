//
//  Global.swift
//  Inventory
//  contains global variables and methods, all funcs are static so no variable needed
//
//  Created by Marcus Deuß on 17.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import os

class Global: NSObject {
    
    // used in about view controller and for sending support emails
    static let versionString = "0.9alpha"
    
    // name of the app in about view
    static let appNameString = "Inventory"
    static let emailAdr = "mdeuss+inventory@gmail.com"
    static let website = "http://www.marcus-deuss.de"
    static let cvsFile = "inventoryexport.csv"
    static let pdfFile = NSLocalizedString("Inventory Report.pdf", comment: "Inventory Report.pdf")
    
    // user default keys, also used for key/value iCloud store
    static let keyUserName = "UserName"
    static let keyHouseName = "UserHouse"
    
    // localization string
    static let item = NSLocalizedString("Item", comment: "Item")
    static let category = NSLocalizedString("Category", comment: "Category")
    static let owner = NSLocalizedString("Owner", comment: "Owner")
    static let room = NSLocalizedString("Room", comment: "Room")
    static let brand = NSLocalizedString("Brand", comment: "Brand")
    static let price = NSLocalizedString("Price", comment: "Price")
    static let all = NSLocalizedString("All", comment: "All")
    
    
    static let ok = NSLocalizedString("OK", comment: "OK")
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel")
    static let delete = NSLocalizedString("Delete", comment: "Delete")
    static let confirm = NSLocalizedString("Confirm", comment: "Confirm")
    static let dismiss = NSLocalizedString("Dismiss", comment: "Dismiss")
    static let chooseDifferentName = NSLocalizedString("Please choose a different name", comment: "Please choose a different name")
    static let emailNotSent = NSLocalizedString("Email could not be sent", comment: "Email could not be sent")
    static let emailDevice = NSLocalizedString("Your device could not send email", comment: "Your device could not send email")
    static let emailConfig = NSLocalizedString("Please check your email configuration", comment: "Please check your email configuration")
    
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
    
    // get min and max from Int array
    class func minMax(array: [Int]) -> (min: Int, max: Int)? {
        if array.isEmpty { return nil }
        var currentMin = array[0]
        var currentMax = array[0]
        for value in array[1..<array.count] {
            if value < currentMin {
                currentMin = value
            } else if value > currentMax {
                currentMax = value
            }
        }
        return (currentMin, currentMax)
    }
/*
    // fade in UI control
    class func showUIControl(_ v: UIView){
        UIView.animate(0.35)
        v.isHidden = false
        v.alpha = 1
    }
    
    // fade in UI control
    class func hideUIControl(_ v: UIView){
        UIView.animate(withDuration: 0.35)
        v.isHidden = true
        v.alpha = 0
    } */
}

