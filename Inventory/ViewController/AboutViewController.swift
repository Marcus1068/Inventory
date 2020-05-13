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

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate, UIPointerInteractionDelegate  {
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
    @IBOutlet weak var whatsNewButton: UIButton!
    @IBOutlet weak var resetDataButton: UIButton!
    
    // attributes
    

    // for using userDefaults local store
    // let userDefaults = UserDefaults.standard
    // for using iCloud key/value store to sync settings between multiple devices (iPhone, iPad e.g)
    let kvStore = NSUbiquitousKeyValueStore()
    
    //var sessionHandler : WatchSessionManager?
    var counter = 0
    
    
    // add keyboard shortcuts to iPadOS screen when user long presses CMD key
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "", image: nil, action: #selector(appSettingsAction), input: "E", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.appSettings, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(informationAction), input: "I", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.appInformation, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(feedbackAction), input: "F", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.appFeedback, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(privacyAction), input: "P", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.appPrivacy, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(userManualAction), input: "M", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.appManual, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(whatsNewAction(_:)), input: "N", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.whatsNew, state: .on)
        ]
    }
    
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
        whatsNewButton.tintColor = themeColorUIControls
        resetDataButton.tintColor = themeColorUIControls
        
        appVersionNumberLabel.text = UIApplication.appName! + " " + Global.appVersion
        appVersionNumberLabel.textColor = themeColorText
        
        copyrightLabel.text = NSLocalizedString("(c) 2018-2020 M. Deuß", comment: "(c) by M. Deuß")
        iosversionLabel.text = NSLocalizedString("Running on", comment: "Running on") + " " + DeviceInfo.getOSName() + " " + DeviceInfo.getOSVersion()
        
        // hide this label when iPhone screen size too small
    /*    if UIDevice.current.iPhone5{
            openSourceLabel.isHidden = true
        } */
        // Do any additional setup after loading the view.
        
        //useiCloudSettingsStorage()
        
        // pointer interaction
        if #available(iOS 13.4, *) {
            customPointerInteraction(on: appInformationButton, pointerInteractionDelegate: self)
            customPointerInteraction(on: feedbackButton, pointerInteractionDelegate: self)
            customPointerInteraction(on: privacyButton, pointerInteractionDelegate: self)
            customPointerInteraction(on: userManualButton, pointerInteractionDelegate: self)
            customPointerInteraction(on: appSettingsButton, pointerInteractionDelegate: self)
            customPointerInteraction(on: helpButton, pointerInteractionDelegate: self)
            customPointerInteraction(on: whatsNewButton, pointerInteractionDelegate: self)
            customPointerInteraction(on: resetDataButton, pointerInteractionDelegate: self)
        } else {
            // Fallback on earlier versions
        }
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
        userNameTextField.text = kvStore.string(forKey: Local.keyUserName)
        UserInfo.userName = userNameTextField.text!
        addressTextField.text = kvStore.string(forKey: Local.keyHouseName)
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
        
  /*
        let _ = Statistics.shared.allInventory(elementsCount: 10)
        
        
        // watch send message
        // watch app context
        let watchSessionManager = WatchSessionManager.sharedManager
        
        //let imageSpeaker = UIImage(named: "Speaker")
        //let imageData = imageSpeaker?.jpegData(compressionQuality: 1.0)!
        
        let returnMessage: [String : Any] = [
            DataKey.AmountMoney : Statistics.shared.itemPricesSum(),
            DataKey.ItemCount : Statistics.shared.getInventoryItemCount()
            //DataKey.TopCategories : 66
            //DataKey.ImageData : imageData!
        ]
        
        watchSessionManager.sendMessage(message: returnMessage)
        
        watchSessionManager.sendTopPricesListToWatch(count: 10)
        
        let _ = watchSessionManager.transferUserInfo(userInfo: returnMessage)
        
        watchSessionManager.sendItemsByRoomListToWatch()
        watchSessionManager.sendItemsByCategoryListToWatch()
        watchSessionManager.sendItemsByBrandListToWatch()
        watchSessionManager.sendItemsByOwnerListToWatch()
        
        let image = #imageLiteral(resourceName: "Owner Icon")
        let data = image.jpegData(compressionQuality: 0.9)
        //print("send data image")
        
        watchSessionManager.sendMessageData(data: data!) */
        
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
            kvStore.set(userNameTextField.text!, forKey: Local.keyUserName)
            kvStore.synchronize()
            UserInfo.userName = userNameTextField.text!
        }
    }
    
    @IBAction func addressEditingChanged(_ sender: UITextField) {
        if (addressTextField.text!.count > 0){
            //userDefaults.set(houseNameTextField.text, forKey: Helper.keyHouseName)
            kvStore.set(addressTextField.text!, forKey: Local.keyHouseName)
            kvStore.synchronize()
            UserInfo.addressName = addressTextField.text!
        }
    }
    
    // MARK: - UI buttons
    
    @IBAction func resetDataAction(_ sender: UIButton) {
        confirmDelete()
    }
    
    @IBAction func whatsNewAction(_ sender: UIButton) {
        let fileName: String
        switch Local.currentLocaleForDate(){
        case "de_DE", "de_AT", "de_CH", "de":
            fileName = "WhatsNew German"
            break
            
        default: // all other languages get english privacy statement
            fileName = "WhatsNew English"
            break
        }
        
        popOver(text: Global.getRTFFileFromBundle(fileName: fileName), sender: sender)
        
    }
    
    // show app settings
    @IBAction func appSettingsAction(_ sender: UIButton) {
        Global.callAppSettings()
    }
    
    /// call email window for feedback dialog
    ///
    /// - Parameter sender: which button called
    @IBAction func feedbackAction(_ sender: Any) {
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
    @IBAction func informationAction(_ sender: Any) {
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
        
        switch Local.currentLocaleForDate(){
        case "de_DE", "de_AT", "de_CH", "de":
            fileName = "Aboutview Help German"
            break
            
        default: // all other languages get english
            fileName = "Aboutview Help English"
            break
        }
        
        popOver(text: Global.getRTFFileFromBundle(fileName: fileName), sender: sender)
    }
    
    @objc func userManualAction(){
        performSegue(withIdentifier: "segueManualShow", sender: nil)
    }
    
    @objc func privacyAction(){
        performSegue(withIdentifier: "seguePrivacy", sender: nil)
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
    
    // UIAlert for asking user if delete is really ok
    // UIAlert view is not modal so we need to do it this way
    func confirmDelete() {
        let title = NSLocalizedString("Delete all inventory", comment: "Delete all inventory")
        let message = NSLocalizedString("Are you sure you really want to delete your inventory? Please make backup before with export function!", comment: "Are you sure you really want to delete")
        
        let myActionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // use closure to delete database entries
        let DeleteAction = UIAlertAction(title: Global.delete, style: UIAlertAction.Style.destructive){ (ACTION) in
            let store = CoreDataStorage.shared
            store.deleteAllData()
        }
        myActionSheet.addAction(DeleteAction)
        
        let CancelAction = UIAlertAction(title: Global.cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
            // do nothing when cancel
        }
        myActionSheet.addAction(CancelAction)
        
        addActionSheetForiPad(actionSheet: myActionSheet)
        present(myActionSheet, animated: true, completion: nil)
    }

    #if targetEnvironment(macCatalyst)
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        
        touchBar.defaultItemIdentifiers = [.touchAppSettings, .touchAppInformation, .touchAppFeedback, .touchPrivacy, .touchAppManual]
        
        let appSettings = NSButtonTouchBarItem(identifier: .touchAppSettings, title: Global.appSettings, target: self, action: #selector(appSettingsAction(_:)))
        appSettings.bezelColor = Global.colorGreen
        
        let appInformation = NSButtonTouchBarItem(identifier: .touchAppInformation, title: Global.appInformation, target: self, action: #selector(informationAction(_:)))
        appInformation.bezelColor = Global.colorGreen
        
        let appFeedback = NSButtonTouchBarItem(identifier: .touchAppFeedback, title: Global.appFeedback, target: self, action: #selector(feedbackAction(_:)))
        appFeedback.bezelColor = Global.colorGreen
        
        let privacy = NSButtonTouchBarItem(identifier: .touchPrivacy, title: Global.appPrivacy, target: self, action: #selector(privacyAction))
        privacy.bezelColor = Global.colorGreen
        
        let appManual = NSButtonTouchBarItem(identifier: .touchAppManual, title: Global.appManual, target: self, action: #selector(userManualAction))
        appManual.bezelColor = Global.colorGreen
        
        touchBar.templateItems = [appSettings, appInformation, appFeedback, privacy, appManual]
        
        return touchBar
    }

    #endif
}

