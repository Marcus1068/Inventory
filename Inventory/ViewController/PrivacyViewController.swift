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
//  PrivacyViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 16.04.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit
import os


class PrivacyViewController: UIViewController {

    @IBOutlet weak var privacyText: UITextView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var doneAction: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        os_log("PrivacyViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        var fileName : String
        
        switch Global.currentLocaleForDate(){
        case "de_DE", "de_AT", "de_CH", "de":
            fileName = "Privacy german"
            break
            
        default: // all other languages get english privacy statement
            fileName = "Privacy english"
            break
        }
        
        // load privacy statement according to german or english language
        if let rtfPath = Bundle.main.url(forResource: fileName, withExtension: "rtf") {
            do {
                let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: rtfPath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                self.privacyText.attributedText = attributedStringWithRtf
            } catch _ {
                os_log("PrivacyViewController viewDidLoad", log: Log.viewcontroller, type: .error)
            }
        }
        
        //privacyText.text = NSLocalizedString("Your data is safe!", comment: "Privacy Info")
        
        navigationBar.topItem?.title = NSLocalizedString("Privacy Information", comment: "Privacy Information")
        
        doneAction.setTitle(Global.done, for: .normal)
        // Do any additional setup after loading the view.
    }
    

    @IBAction func doneButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
