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

/// show about view with support email function
///
/// version number of app
class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate  {
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var iosversionLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var houseNameTextField: UITextField!
    
    // attributes
    
    // for using userDefaults local store
    let userDefaults = UserDefaults.standard
    // for using iCloud key/value store to sync settings between multiple devices (iPhone, iPad e.g)
    let kvStore = NSUbiquitousKeyValueStore()
    
    // setup dynamic font types for all labels
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateFontsforDynamicTypes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        os_log("About view controller", log: Log.viewcontroller, type: .info)
        
        versionNumberLabel.text = Global.appNameString + " " + Global.versionString
        //versionNumberLabel.tintColor = themeColor
        versionNumberLabel.textColor = themeColor
        let copyMsg = NSLocalizedString("(c) 2018 by Marcus Deuß", comment: "(c) 2018 by Marcus Deuß")
        copyrightLabel.text = copyMsg
        let msg = NSLocalizedString("Running on iOS ", comment: "Running on iOS")
        
        iosversionLabel.text = msg + DeviceInfo.showOSVersion()
        
        // Do any additional setup after loading the view.
        
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
            let userInfo = UserInfo(userName: user, houseName: house)
            
            userNameTextField.text = userInfo.userName
            houseNameTextField.text = userInfo.houseName
        }
        else{
            // default house name
            let userInfo = UserInfo()
            
            userNameTextField.text = userInfo.userName
            houseNameTextField.text = userInfo.houseName
        }
        
        // notify view controller when changes on other devices occur
        NotificationCenter.default.addObserver(self, selector: #selector(AboutViewController.kvHasChanged(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: kvStore)
    }
    
    // handle notification when iCloud changes occur
    @objc func kvHasChanged(notification: NSNotification){
        // update both text fields (complexer apps need to check for changes in all records
        userNameTextField.text = kvStore.string(forKey: Global.keyUserName)
        houseNameTextField.text = kvStore.string(forKey: Global.keyHouseName)
    }
    
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
    }
    
    // save user name and household name as soon as any input entered in user default
    @IBAction func userNameEditingChanged(_ sender: UITextField) {
        //userDefaults.set(userNameTextField.text, forKey: Helper.keyUserName)
        kvStore.set(userNameTextField.text!, forKey: Global.keyUserName)
        kvStore.synchronize()
    }
    
    @IBAction func houseNameEditingChanged(_ sender: UITextField) {
        //userDefaults.set(houseNameTextField.text, forKey: Helper.keyHouseName)
        kvStore.set(houseNameTextField.text!, forKey: Global.keyHouseName)
        kvStore.synchronize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        mailComposerVC.setSubject(Global.appNameString + " " + (Global.versionString) + " Support")
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
    
    // for using dynamic types: These are the six preset styles. When the view appears the helper method will be called. Implement the viewDidAppear method.
    func updateFontsforDynamicTypes() {
        //versionNumberLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        //copyrightLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        //iosversionLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        /*
         headlineLabel.font = UIFont.preferredFont(forTextStyle: .headline)
         subheadlineLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
         bodyLabel.font = UIFont.preferredFont(forTextStyle: .body)
         footnoteLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
         caption1Label.font = UIFont.preferredFont(forTextStyle: .caption1)
         caption2Label.font = UIFont.preferredFont(forTextStyle: .caption2)
         */
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
