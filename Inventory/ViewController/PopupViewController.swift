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
//  PopupViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 14.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {

    @IBOutlet weak var infotxt: UITextView!
    
    var myText : String?
    weak var aboutVC: AboutViewController!  // reference to calling view controller
    
    // needed to calculate dynamic resizing of content in text view
    override var preferredContentSize: CGSize{
        get{
            if infotxt != nil, let pvc = presentingViewController{
                return infotxt.sizeThatFits(pvc.view.bounds.size)
            }
            return super.preferredContentSize
        }
        set { super.preferredContentSize = newValue}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if myText != nil{
            infotxt.text = myText
        }
    }
}
