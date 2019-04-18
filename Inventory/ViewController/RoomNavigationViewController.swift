//
//  RoomNavigationViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os

class RoomNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("RoomNavigationViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }

        // Do any additional setup after loading the view.
    }

}
