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
//  AboutViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import MessageUI
import os
import AudioToolbox
import WatchConnectivity

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate  {
    @IBOutlet weak var appVersionNumberLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var iosversionLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var appInformationButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var userManualButton: UIButton!
    @IBOutlet weak var openSourceLabel: UILabel!
    @IBOutlet weak var appSettingsButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    // attributes
    
    // for using userDefaults local store
    // let userDefaults = UserDefaults.standard
    // for using iCloud key/value store to sync settings between multiple devices (iPhone, iPad e.g)
    let kvStore = NSUbiquitousKeyValueStore()
    
    //var sessionHandler : WatchSessionManager?
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.sessionHandler = (UIApplication.shared.delegate as? AppDelegate)?.sessionHandler
        
        //os_log("AboutViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        // setup colors for UI controls
        appInformationButton.tintColor = themeColorUIControls
        feedbackButton.tintColor = themeColorUIControls
        privacyButton.tintColor = themeColorUIControls
        userManualButton.tintColor = themeColorUIControls
        //appVersionNumberLabel.textColor = themeColorUIControls
        appSettingsButton.tintColor = themeColorUIControls
        
        appVersionNumberLabel.text = UIApplication.appName! + " " + UIApplication.appVersion! + " (" + UIApplication.appBuild! + ")"
        appVersionNumberLabel.textColor = themeColorText
        
        copyrightLabel.text = NSLocalizedString("(c) 2019 by M. Deuß", comment: "(c) 2019 by M. Deuß")
        iosversionLabel.text = NSLocalizedString("Running on iOS ", comment: "Running on iOS") + DeviceInfo.getOSVersion()
        
        // hide this label when iPhone screen size too small
    /*    if UIDevice.current.iPhone5{
            openSourceLabel.isHidden = true
        } */
        // Do any additional setup after loading the view.
        
        //useiCloudSettingsStorage()
    }
    
    // setup all things that need to be refreshed when view comes to screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //os_log("AboutViewController viewWillAppear", log: Log.viewcontroller, type: .info)
        
        // either use local of iCloud storage
        //useLocalSettingsStorage()
        useiCloudSettingsStorage()
        
        // when tapping somewhere on view dismiss keyboard
        self.hideKeyboardWhenTappedAround()
        
    }
    
    // when using iCloud key/value store to sync settings
    func useiCloudSettingsStorage(){
            userNameTextField.text = UserInfo.userName
            addressTextField.text = UserInfo.addressName
        
        // notify view controller when changes on other devices occur
        NotificationCenter.default.addObserver(self, selector: #selector(AboutViewController.kvHasChanged(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: kvStore)
    }
    
    // handle notification when iCloud changes occur
    @objc func kvHasChanged(notification: NSNotification){
        // update both text fields (complexer apps need to check for changes in all records
        userNameTextField.text = kvStore.string(forKey: Global.keyUserName)
        UserInfo.userName = userNameTextField.text!
        addressTextField.text = kvStore.string(forKey: Global.keyHouseName)
        UserInfo.addressName = addressTextField.text!
    }
    
    /*
    // when using local storage
    func useLocalSettingsStorage(){
        // load user defaults
        // first run test - no defaults
        if let user = userDefaults.string(forKey: Global.keyUserName),
            let house = userDefaults.string(forKey: Global.keyHouseName){
            let userInfo = UserInfo(userName: user, houseName: house)
            
            userNameTextField.text = userInfo.userName
            houseNameTextField.text = userInfo.houseName
            
            //print(userInfo.userName, userInfo.houseName)
        }
        else{
            // default house name
            let userInfo = UserInfo(userName: NSLocalizedString("User Name", comment: "User Name"), houseName: NSLocalizedString("House Name", comment: "House Name"))
            
            userNameTextField.text = userInfo.userName
            houseNameTextField.text = userInfo.houseName
            
            //print(userInfo.userName, userInfo.houseName)
        }
    } */
    
    // MARK: - popover/popup windows methods
    
    func popOver(text: NSAttributedString, sender: UIButton){
        // create popover via storyboard instead of segue
        let myVC = storyboard?
            .instantiateViewController(withIdentifier: "PopupViewController")   // defined in Storyboard identifier
            as! PopupViewController
        myVC.myText = text
        // this needs to define calling view controller type
        myVC.aboutVC = self
        
        // show the popover
        myVC.modalPresentationStyle = .popover
        let popPC = myVC.popoverPresentationController!
        popPC.sourceView = sender
        popPC.sourceRect = sender.bounds
        popPC.permittedArrowDirections = .up
        popPC.delegate = self
        present(myVC, animated:true, completion: nil)
        
        // initialize arrays
        //Statistics.shared.start()
        //FIXME just for debugging
        
        for (str, index) in Statistics.shared.countItemsByRoomDict(){
            print("Room: \(str) count: \(index)" )
        }
        
        
        for (str, index) in Statistics.shared.countItemsByOwnerDict(){
            print("Owner: \(str) count: \(index)" )
        }
        
        for (str, index) in Statistics.shared.countItemsByCategoryDict(){
            print("Category: \(str) count: \(index)" )
        }
        
        for (str, index) in Statistics.shared.countItemsByBrandDict(){
            print("Brand: \(str) count: \(index)" )
        }
        
        let invNames = Statistics.shared.allInventory(elementsCount: 5)
        for inv in invNames{
            print(inv.inventoryName!)
        }
        
        let topPrices = Statistics.shared.mostExpensiveItems(elementsCount: 5)
        for inv in topPrices{
            print("Name: \(inv.inventoryName!), price: \(String(inv.price))")
        }
        
        
        // watch send message
        
       /*
        counter += 1
        connectivityHandler!.session.sendMessage(["msg" : "Message \(counter)"], replyHandler: nil) { (error) in
            //os_log("AboutViewController viewWillAppear: error %@", log: Log.viewcontroller, type: .info, error)
            //NSLog("%@", "Error sending message: \(error)")
            // vibrate iPhone
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        } */
        
        // app context
        let watchSessionManager = WatchSessionManager.sharedManager
        if let validSession = watchSessionManager.validSession {
            let iPhoneAppContext = ["switchStatus": "Vincent"]
            
            do {
                try validSession.updateApplicationContext(iPhoneAppContext)
            } catch {
                print("Something went wrong")
            }
            
            let iPhoneApp = ["switchStatus": "Emily"]
            
            do {
                try validSession.updateApplicationContext(iPhoneApp)
            } catch {
                print("Something went wrong")
            }
            
            let iPhoneAppHans = ["Name": "Hans"]
            
            do {
                try validSession.updateApplicationContext(iPhoneAppHans)
            } catch {
                print("Something went wrong")
            }
            //try? watchSessionManager.updateApplicationContext(applicationContext: ["switchStatus": "Papa"])
            //try? watchSessionManager.updateApplicationContext(applicationContext: ["number": 12])
            
            
            let returnMessage: [String : Int] = [
                "Amount" : Statistics.shared.itemPricesSum(),
                "key2" : 2,
                "key3" : 3,
                "number" : 12
            ]
            
            try? watchSessionManager.updateApplicationContext(applicationContext: returnMessage)
        }
        
    }
    
    // needed for iPhone compatibilty when using popup controller
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: - Textfield actions
    
    // save user name and address as soon as any input entered in user default
    @IBAction func userNameEditingChanged(_ sender: UITextField) {
        if (userNameTextField.text!.count > 0){
            //userDefaults.set(userNameTextField.text, forKey: Helper.keyUserName)
            kvStore.set(userNameTextField.text!, forKey: Global.keyUserName)
            kvStore.synchronize()
            UserInfo.userName = userNameTextField.text!
        }
    }
    
    @IBAction func addressEditingChanged(_ sender: UITextField) {
        if (addressTextField.text!.count > 0){
            //userDefaults.set(houseNameTextField.text, forKey: Helper.keyHouseName)
            kvStore.set(addressTextField.text!, forKey: Global.keyHouseName)
            kvStore.synchronize()
            UserInfo.addressName = addressTextField.text!
        }
    }
    
    // MARK: - UI buttons
    
    // show app settings
    @IBAction func appSettingsAction(_ sender: UIButton) {
        Global.callAppSettings()
    }
    
    /// call email window for feedback dialog
    ///
    /// - Parameter sender: which button called
    @IBAction func feedbackButton(_ sender: Any) {
        // hide keyboard
        self.view.endEditing(true)
        
        let mailComposeViewController = configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else
        {
            displayAlert(title: Global.emailNotSent, message: Global.emailDevice, buttonText: Global.emailConfig)
        }
    }
    
    /// show web site opening a safari windows
    ///
    /// - Parameter sender: which button called
    @IBAction func informationButton(_ sender: Any) {
        // hide keyboard
        self.view.endEditing(true)
        
        // open safari browser for more information, source code etc.
        if let url = URL(string: Global.website) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    
    /// show popover with some useful help information
    ///
    /// - Parameter sender: which button called
    @IBAction func helpButton(_ sender: UIButton) {
        
        var fileName : String
        
        switch Global.currentLocaleForDate(){
        case "de_DE", "de_AT", "de_CH", "de":
            fileName = "Aboutview Help German"
            break
            
        default: // all other languages get english
            fileName = "Aboutview Help English"
            break
        }
        
        popOver(text: Global.getRTFFileFromBundle(fileName: fileName), sender: sender)
    }
    
    /*
    // MARK: - Email delegate
    */
    
    /// Prepares mail sending controller
    ///
    /// **Extremely** important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
    /// - Returns: mailComposerVC
    func configuredMailComposeViewController() -> MFMailComposeViewController
    {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([Global.emailAdr])
        mailComposerVC.setSubject(UIApplication.appName! + " " + (UIApplication.appVersion!) + " " + Global.support)
        let msg = NSLocalizedString("I have some suggestions: ", comment: "I have some suggestions: ")
        mailComposerVC.setMessageBody(msg, isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }

}
