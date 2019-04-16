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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        os_log("PrivacyViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        
        privacyText.text = NSLocalizedString("Your data is safe!", comment: "Privacy Info")
        
        navigationBar.topItem?.title = NSLocalizedString("Privacy Information", comment: "Privacy Information")
        // Do any additional setup after loading the view.
    }
    

    @IBAction func doneButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
