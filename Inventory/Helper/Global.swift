/*
 
 Copyright 2019 Marcus Deuß
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

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
import LocalAuthentication
import AVFoundation
import CoreData

class Global: UIViewController {
    
    // compression factor in reducing jpg file size to 1/10th (value goes from 0.0 to 1.0)
    static let imageQuality: CGFloat = 0.0
    
    // system sound for drop operation
    static let systemSound = 1322
    
    // App store link
    static let AppLink = "https://itunes.apple.com/de/app/inventory-app/id1386694734?l=de&ls=1&mt=8"
    
    // name of the app in about view
    static let emailAdr = "mdeuss+inventory@gmail.com"
    static let website = "https://marcus-deuss.de/?page_id=13"
    static let csvFile = "inventoryAppExport.csv"
    static let pdfFile = NSLocalizedString("Inventory App Report.pdf", comment: "Inventory App Report.pdf") // FIXME: why translate?
    
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
    static let error = NSLocalizedString("Error", comment: "Error")
    static let done = NSLocalizedString("Done", comment: "Done")
    static let none = NSLocalizedString("None", comment: "None")
    static let duplicate = NSLocalizedString("Duplicate", comment: "Duplicate")
    static let edit = NSLocalizedString("Edit", comment: "Edit")
    static let copy = NSLocalizedString("Copy", comment: "Copy")
    static let printInvoice = NSLocalizedString("Print Invoice", comment: "Print Invoice")
    
    static let documentNotFound = NSLocalizedString("Document not found!", comment: "Document not found")
    static let chooseDifferentName = NSLocalizedString("Please choose a different name", comment: "Please choose a different name")
    static let emailNotSent = NSLocalizedString("Email could not be sent", comment: "Email could not be sent")
    static let emailDevice = NSLocalizedString("Your device could not send email", comment: "Your device could not send email")
    static let emailConfig = NSLocalizedString("Please check your email configuration", comment: "Please check your email configuration")
    static let support = NSLocalizedString("Support", comment: "Support")
    
    static let takePhoto = NSLocalizedString("Take Photo", comment: "Take Photo")
    static let cameraRoll = NSLocalizedString("Camera Roll", comment: "Camera Roll")
    static let photoLibrary = NSLocalizedString("Photo Library", comment: "Photo Library")
    
    // general functions
    
    //User region setting return
    static let locale = Locale.current
    
    //Returns true if the locale uses the metric system (Note: Only three countries do not use the metric system: the US, Liberia and Myanmar.)
    static let isMetric = locale.usesMetricSystem
    
    //Returns the currency code of the locale. For example, for “zh-Hant-HK”, returns “HKD”.
    static let currencyCode  = locale.currencyCode
    
    //Returns the currency symbol of the locale. For example, for “zh-Hant-HK”, returns “HK$”.
    static let currencySymbol = locale.currencySymbol
    
    static let languageCode = locale.languageCode
    
    class func currentLocaleForDate() -> String{
        return languageCode!
    }
    
    // define column names for import and export functions for csv file
    static let inventoryName_csv = "inventoryName"
    static let dateofPurchase_csv = "dateofPurchase"
    static let price_csv = "price"
    static let serialNumber_csv = "serialNumber"
    static let remark_csv = "remark"
    static let timeStamp_csv = "timeStamp"
    static let roomName_csv = "roomName"
    static let ownerName_csv = "ownerName"
    static let categoryName_csv = "categoryName"
    static let brandName_csv = "brandName"
    static let warranty_csv = "warranty"
    static let imageFileName_csv = "imageFileName"
    static let invoiceFileName_csv = "invoiceFileName"
    static let id_csv = "id"
    
    static let csvMetadata = "\(Global.inventoryName_csv),\(Global.dateofPurchase_csv),\(Global.price_csv),\(Global.serialNumber_csv),\(Global.remark_csv),\(Global.timeStamp_csv),\(Global.roomName_csv),\(Global.ownerName_csv),\(Global.categoryName_csv),\(Global.brandName_csv),\(Global.warranty_csv),\(Global.imageFileName_csv),\(Global.invoiceFileName_csv),\(Global.id_csv)\n"
    
    
    // MARK: - helper functions
    
    // sending a local notification
    
    /// send a local notification (does not require server)
    ///
    /// - Parameters:
    ///   - title: notification title
    ///   - subtitle: notification subtitle
    ///   - body: notification body text
    ///   - badge: when using badge show number of messages in icon
    /// - Returns: <none>
    
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
    
    /// generate a UUID
    ///
    /// - Parameters:
    ///
    ///
    /// - Returns: UUID as String
    
    class func generateUUID() -> String{
        return UUID().uuidString
    }
    
    /// generate a UUID
    ///
    /// - Returns: a new UUID
    class func generateUUID() -> UUID{
        return UUID()
    }
    

    /// get max of two values
    ///
    /// - Parameters:
    ///   - array: integer array
    ///
    /// - Returns: (minumum value, maximum value)? or nil if array empty

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
    
    /// call iOS app settings dialog from inside the app
    ///
    /// - Parameters:
    ///
    ///
    /// - Returns:
    
    class func callAppSettings(){
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    // Finished opening URL
                })
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
    
    /// show an alert dialog
    ///
    /// - Parameters:
    ///   - title: notification title
    ///   - message: notification message
    ///
    /// - Returns:
/*
    class func showAlertController(title: String, message: String) {
        if title.count == 0{
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Global.ok, style: .default, handler: nil))
        }
        else{
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Global.ok, style: .default, handler: nil))
        }
        //present(alertController, animated: true, completion: nil)
    }
    */
    
    /// authenticate with touch id or face id
    ///
    /// - Parameters:
    ///
    /// - Returns: true if auth did work, false otherwise

    class func authWithTouchID(_ sender: Any) -> Bool{
        // Get the authentication context from the Local Authentication framework
        let context = LAContext()
        var error: NSError?
        var successFlag : Bool = false
        
        // The canEvaluatePolicy method checks if Touch ID is available on the device
        // check if Touch ID is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // The policy is evaluated where the third parameter is a completion handler block.
            let reason = NSLocalizedString("Authenticate with Touch ID", comment: "Authenticate with Touch ID")
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success, error) in
                    // An Alert message is shown wether the Touch ID authentication succeeded or not
                    if success {
                        //displayAlert(title: "Touch ID", message: "Touch ID Authentication Succeeded", buttonText: self.ok)
                        //self.showAlertController(title: "", message: "Touch ID Authentication Succeeded")
                        os_log("Global authWithTouchID: touch ID Authentication succeeded", log: Log.viewcontroller, type: .info)
                        
                        successFlag = true
                    }
                    else {
                        //displayAlert(title: <#T##String#>, message: <#T##String#>, buttonText: <#T##String#>)
                        //self.showAlertController(title: "", message: "Touch ID Authentication Failed")
                        os_log("Global authWithTouchID: touch ID Authentication failed", log: Log.viewcontroller, type: .error)
                    }
            })
        }
            // If Touch ID is not available an Alert message is shown.
        else {
            //displayAlert(title: <#T##String#>, message: <#T##String#>, buttonText: <#T##String#>)
            //showAlertController(title: "", message: "Touch ID not available")
            os_log("Global authWithTouchID: touch ID not available", log: Log.viewcontroller, type: .error)
        }
        
        return successFlag
    }
    
    /// check for camera permissions
    ///
    /// - Parameters:
    ///
    /// - Returns: true if camera allowed, false otherwise

    class func checkCameraPermission() -> Bool{
        //os_log("Global checkCameraPermission", log: Log.viewcontroller, type: .info)
        
        var allowed : Bool = true
        
        // check for camera permissions
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            allowed = true
            break
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    allowed = true
                }
            }
            
        case .denied: // The user has previously denied access.
            allowed = false
            break
            
        case .restricted: // The user can't grant access due to restrictions.
            allowed = false
            break
            
        @unknown default:
            os_log("Global checkCameraPermission", log: Log.viewcontroller, type: .error)
        }
        
        return allowed
    }
    
    /// generates a string like invname_20191022060310
    ///
    /// - Parameter invname: inventory name
    /// - Returns: inventory name with date components added
    static func generateFilename(invname: String) -> String{
        //os_log("Global generateFilename", log: Log.viewcontroller, type: .info)
        
        let cal = Calendar.current
        let now = Date()
        let comps = cal.dateComponents([.day, .month, .year, .hour, .minute, .second], from: now)
        
        let imageName = invname + "_" + String(comps.year!) + "_" + String(comps.day!) + "_" + String(comps.month!) + "_" + String(comps.hour!) + "_" + String(comps.minute!) + "_" + String(comps.second!)
        
        return imageName
    }
    
    /// creates a temporary file after drop operation
    ///
    /// - Parameter fileItems: the file that gets dropped over the app
    /// - Returns: a URL with the file stored in cache directory
    static func createTempDropObject(fileItems: [DropFile]) -> URL?{
        //os_log("Global createTempDropObject", log: Log.viewcontroller, type: .info)
        
        let docURL = (FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)).last as NSURL?
        let dropFilePath = docURL!.appendingPathComponent("File")!.appendingPathExtension("pdf")
        
        for file in fileItems {
            do {
                try file.fileData?.write(to:dropFilePath)
            } catch {
                os_log("Global createTempDropObject", log: Log.viewcontroller, type: .error)
            }
        }
        
        return dropFilePath
    }
    
    /// scales an image to a different size
    ///
    /// - Parameters:
    ///   - image: the image to be scaled
    ///   - width: the width of the new image
    /// - Returns: a new image with different width
    static func scaleImage (image:UIImage, width: CGFloat) -> UIImage {
        let oldWidth = image.size.width
        let scaleFactor = width / oldWidth
        
        let newHeight = image.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    /// read a rtf file from main bundle and return as attributed string for putting into UITextfield
    ///
    /// - Parameter fileName: the rtf filename used in main bundle
    /// - Returns: an attributed string made from rtf file or a file not found message
    static func getRTFFileFromBundle(fileName: String) -> NSAttributedString{
        let str = "rtf file not found!"
        let attributedText = NSAttributedString(string: str)
        
        if let rtfPath = Bundle.main.url(forResource: fileName, withExtension: "rtf") {
            do {
                let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: rtfPath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                
                return attributedStringWithRtf
            } catch _ {
                os_log("AboutViewController helpButton", log: Log.viewcontroller, type: .error)
            }
        }
        
        return attributedText
    }
}

// extensions
extension String {
    /*
     Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
     - Parameter length: Desired maximum lengths of a string
     - Parameter trailing: A 'String' that will be appended after the truncation.
     
     - Returns: 'String' object.
     Swift 4.0 Example
     let str = "I might be just a little bit too long".truncate(10) // "I might be…"
     */
    func truncate(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
    
    // return an array of lines of strings
    var lines: [String] {
        return self.components(separatedBy: "\n")
    }
}

// used to create folders inside of document folder like this:
// For example, to create the folder "MyStuff", you would call it like this:
// let myStuffURL = URL.createFolder(folderName: "MyStuff")
extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
}

// get app version number from Xcode version number
extension UIApplication {
    // xcode version string
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    // xcode build number
    static var appBuild: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
    
    // xcode app name
    static var appName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}

// dismiss keyboard with gesture recognizer when tapping outside of text fields
// this extension method can be used in all view controllers of the app
extension UIViewController {
    // use this method in viewDidLoad of any view controller that uses text edit fields
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // general alert extension with just one button to be pressed
    func displayAlert(title: String, message: String, buttonText: String) {
        
        // Create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        // Add an action
        alert.addAction(UIAlertAction(title: buttonText, style: .default, handler: { action in
            
            // Dismiss when the button is pressed
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        // Add it to viewController
        self.present(alert, animated: true, completion: nil)
    }
}

// for action sheets on ipad and iPhone, works on both devices, otherwise app crashes
// displays action sheet in the middle of iPad screen, on bottom on iPhone screen as usual
extension UIViewController {
    public func addActionSheetForiPad(actionSheet: UIAlertController) {
        if let popoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
    }
}

extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //os_log("ImageViewController viewForZooming", log: Log.viewcontroller, type: .info)
        
        return imageView
    }
}
