//
//  AboutViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import MessageUI

/// show about view with support email function
///
/// version number of app
class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate  {
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var iosversionLabel: UILabel!
    
    // setup dynamic font types for all labels
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateFontsforDynamicTypes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        versionNumberLabel.text = Helper.appNameString + " " + Helper.versionString
        //versionNumberLabel.tintColor = themeColor
        versionNumberLabel.textColor = themeColor
        let copyMsg = NSLocalizedString("(c) 2018 by Marcus Deuß", comment: "(c) 2018 by Marcus Deuß")
        copyrightLabel.text = copyMsg
        let msg = NSLocalizedString("Running on iOS ", comment: "Running on iOS")
        
        iosversionLabel.text = msg + DeviceInfo.showOSVersion()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func feedbackButton(_ sender: Any) {
        
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
        // open safari browser for more information, source code etc.
        if let url = URL(string: Helper.website) {
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
        mailComposerVC.setToRecipients([Helper.emailAdr])
        mailComposerVC.setSubject(Helper.appNameString + " " + (Helper.versionString) + " Support")
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
