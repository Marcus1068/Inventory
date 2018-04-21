//
//  AboutViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import MessageUI
import os.log

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate  {
    @IBOutlet weak var versionNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        versionNumberLabel.text = Helper.appNameString + " " + Helper.versionString
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func feedbackButton(_ sender: Any) {
        os_log("feedbackButton in AboutViewController", log: OSLog.default, type: .debug)
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func configuredMailComposeViewController() -> MFMailComposeViewController
    {
        os_log("configuredMailComposeViewController in AboutViewController", log: OSLog.default, type: .debug)
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(["mdeuss@gmail.com"])
        mailComposerVC.setSubject("Inventory Support \(Helper.versionString)")
        let msg = NSLocalizedString("I have some improvement ideas: ", comment: "I have some improvement ideas: ")
        mailComposerVC.setMessageBody(msg, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert()
    {
        os_log("showSendMailErrorAlert in AboutViewController", log: OSLog.default, type: .debug)
        
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
        os_log("mailComposeController in AboutViewController", log: OSLog.default, type: .debug)
        
        controller.dismiss(animated: true, completion: nil)
    }

}
