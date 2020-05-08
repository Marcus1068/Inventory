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
    
    
    // add keyboard shortcuts to iPadOS screen when user long presses CMD key
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "D", modifierFlags: .command, action: #selector(doneButton), discoverabilityTitle: Global.done),
            
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //os_log("PrivacyViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        // setup colors for UI controls
        doneAction.tintColor = themeColorUIControls
        
        var fileName : String
        
        switch Local.currentLocaleForDate(){
        case "de_DE", "de_AT", "de_CH", "de":
            fileName = "Privacy german"
            break
            
        default: // all other languages get english privacy statement
            fileName = "Privacy english"
            break
        }
        
        privacyText.attributedText = Global.getRTFFileFromBundle(fileName: fileName)
        privacyText.textColor = UIColor.systemGray
        
        navigationBar.topItem?.title = NSLocalizedString("Privacy Information", comment: "Privacy Information")
        
        doneAction.setTitle(Global.done, for: .normal)
        // Do any additional setup after loading the view.
    }
    
    // need this to scroll textview to top at start
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async{
            let desiredOffset = CGPoint(x: 0, y: -self.privacyText.contentInset.top)
            self.privacyText.setContentOffset(desiredOffset, animated: false)
        }
    }
    

    @IBAction func doneButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    #if targetEnvironment(macCatalyst)
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        
        touchBar.defaultItemIdentifiers = [.touchDone]
        
        let done = NSButtonTouchBarItem(identifier: .touchDone, title: Global.done, target: self, action: #selector(doneButton(_:)))
        done.bezelColor = Global.colorGreen
        
        touchBar.templateItems = [done]
        
        return touchBar
    }

    #endif
}
