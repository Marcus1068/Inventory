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

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate  {
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var iosversionLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var houseNameTextField: UITextField!
    
    // attributes
    
    // for using userDefaults local store
    // let userDefaults = UserDefaults.standard
    // for using iCloud key/value store to sync settings between multiple devices (iPhone, iPad e.g)
    let kvStore = NSUbiquitousKeyValueStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        os_log("About view controller", log: Log.viewcontroller, type: .info)
        
        versionNumberLabel.text = Global.appNameString + " " + Global.versionString
        //versionNumberLabel.tintColor = themeColor
        versionNumberLabel.textColor = themeColor
        let copyMsg = NSLocalizedString("(c) 2019 by Marcus Deuß", comment: "(c) 2019 by Marcus Deuß")
        copyrightLabel.text = copyMsg
        let msg = NSLocalizedString("Running on iOS ", comment: "Running on iOS")
        
        iosversionLabel.text = msg + DeviceInfo.showOSVersion()
        
        // Do any additional setup after loading the view.
        
        //useiCloudSettingsStorage()
    }
    
    // setup all things that need to be refreshed when view comes to screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // either use local of iCloud storage
        //useLocalSettingsStorage()
        useiCloudSettingsStorage()
        
        // when tapping somewhere on view dismiss keyboard
        self.hideKeyboardWhenTappedAround()
    }
    
    // when using iCloud key/value store to sync settings
    func useiCloudSettingsStorage(){
        if let user = kvStore.string(forKey: Global.keyUserName),
            let house = kvStore.string(forKey: Global.keyHouseName){
            //userInfo = UserInfo(userName: user, houseName: house)
            UserInfo.userName = user
            UserInfo.houseName = house
            
            userNameTextField.text = UserInfo.userName
            houseNameTextField.text = UserInfo.houseName
        }
        else{
            // default user and house name
            //userInfo = UserInfo()
            
            userNameTextField.text = UserInfo.userName
            houseNameTextField.text = UserInfo.houseName
        }
        
        // notify view controller when changes on other devices occur
        NotificationCenter.default.addObserver(self, selector: #selector(AboutViewController.kvHasChanged(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: kvStore)
    }
    
    // handle notification when iCloud changes occur
    @objc func kvHasChanged(notification: NSNotification){
        // update both text fields (complexer apps need to check for changes in all records
        userNameTextField.text = kvStore.string(forKey: Global.keyUserName)
        UserInfo.userName = userNameTextField.text!
        houseNameTextField.text = kvStore.string(forKey: Global.keyHouseName)
        UserInfo.houseName = houseNameTextField.text!
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
    
    // MARK: - Textfield actions
    
    // save user name and household name as soon as any input entered in user default
    @IBAction func userNameEditingChanged(_ sender: UITextField) {
        
        if (userNameTextField.text!.count > 0){
            //userDefaults.set(userNameTextField.text, forKey: Helper.keyUserName)
            kvStore.set(userNameTextField.text!, forKey: Global.keyUserName)
            kvStore.synchronize()
            UserInfo.userName = userNameTextField.text!
        }
    }
    
    @IBAction func houseNameEditingChanged(_ sender: UITextField) {
        if (houseNameTextField.text!.count > 0){
            //userDefaults.set(houseNameTextField.text, forKey: Helper.keyHouseName)
            kvStore.set(houseNameTextField.text!, forKey: Global.keyHouseName)
            kvStore.synchronize()
            UserInfo.houseName = houseNameTextField.text!
        }
    }
    
    // MARK: - UI buttons
    
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
            self.showSendMailErrorAlert()
        }
    }
    
    @IBAction func informationButton(_ sender: Any) {
        
        // hide keyboard
        self.view.endEditing(true)
        
        // open safari browser for more information, source code etc.
        if let url = URL(string: Global.website) {
            UIApplication.shared.open(url, options: [:])
        }
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
        let support = NSLocalizedString("Support", comment: "Support")
        mailComposerVC.setSubject(Global.appNameString + " " + (Global.versionString) + " " + support)
        let msg = NSLocalizedString("I have some improvement ideas: ", comment: "I have some improvement ideas: ")
        mailComposerVC.setMessageBody(msg, isHTML: false)
        
        return mailComposerVC
    }
    
    /// show error if mail sending does not work
    func showSendMailErrorAlert()
    {
        let msg = NSLocalizedString("Email could not be sent", comment: "Email could not be sent")
        let msg2 = NSLocalizedString("Your device could not send email", comment: "Your device could not send email")
        
        let alert = UIAlertController(title: msg, message: msg2, preferredStyle: .alert)
        
        let msg3 = NSLocalizedString("Please check your email configuration", comment: "Please check your email configuration")
        
        alert.addAction(UIAlertAction(title: msg3, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
        //let sendMailErrorAlert = UIAlertView(title: "Email konnte nicht gesendet werden", message: "Ihr Gerät konnte keine Email senden.  Bitte Email Konfiguration prüfen.", delegate: self, cancelButtonTitle: "OK")
        
        //alert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
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
}
