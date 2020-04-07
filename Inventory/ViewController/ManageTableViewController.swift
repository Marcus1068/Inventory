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
//  ManageViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

// will be used to call room edit, add views etc.

import UIKit
import os

class ManageTableViewController: UITableViewController, UIPointerInteractionDelegate {

    @IBOutlet weak var staticCellRoomEdit: UITableViewCell!
    @IBOutlet weak var staticCellCategoriesEdit: UITableViewCell!
    @IBOutlet weak var staticCellBrandEdit: UITableViewCell!
    @IBOutlet weak var staticCellOwnerEdit: UITableViewCell!
    @IBOutlet weak var staticCellRoomAdd: UITableViewCell!
    @IBOutlet weak var staticCellCategoryAdd: UITableViewCell!
    @IBOutlet weak var staticCellBrandAdd: UITableViewCell!
    @IBOutlet weak var staticCellOwnerAdd: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //os_log("ManageTableViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        // Do any additional setup after loading the view.
        
        //self.tableView.layer.cornerRadius = 8.0
        //self.tableView.layer.masksToBounds = true
        
        //self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
        // this will avoid displaying empty rows in the table
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        self.title = NSLocalizedString("Manage items", comment: "Manage items table view title")
        //navigationController?.navigationBar.barTintColor = themeColor
        
        self.tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.bottom, animated: true)
        
        //tableView.isScrollEnabled = false
        
        // pointer interaction
        if #available(iOS 13.4, *) {
            customPointerInteraction(on: staticCellRoomEdit, pointerInteractionDelegate: self)
            customPointerInteraction(on: staticCellCategoriesEdit, pointerInteractionDelegate: self)
            customPointerInteraction(on: staticCellBrandEdit, pointerInteractionDelegate: self)
            customPointerInteraction(on: staticCellOwnerEdit, pointerInteractionDelegate: self)
            customPointerInteraction(on: staticCellRoomAdd, pointerInteractionDelegate: self)
            customPointerInteraction(on: staticCellCategoryAdd, pointerInteractionDelegate: self)
            customPointerInteraction(on: staticCellBrandAdd, pointerInteractionDelegate: self)
            customPointerInteraction(on: staticCellOwnerAdd, pointerInteractionDelegate: self)
        } else {
            // Fallback on earlier versions
        }
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //os_log("ManageTableViewController viewWillAppear", log: Log.viewcontroller, type: .info)
        
        self.tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.bottom, animated: true)
  /*      if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }*/
    }

    
    // define table view header size
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 61.0
    }
    
    // define table view header layout
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "HelveticaNeue", size: 20)!
       // header.textLabel?.textColor = UIColor.lightGray
        // header.backgroundView?.backgroundColor = themeColorUIControls
    }
    
    // manual segue control for touch bar needed
    @objc func roomEditAction(){
        performSegue(withIdentifier: "manageSegueRoomEdit", sender: nil)
    }
    
    @objc func categoryEditAction(){
        performSegue(withIdentifier: "manageSegueCategoryEdit", sender: nil)
    }
    
    @objc func brandEditAction(){
        performSegue(withIdentifier: "manageSegueBrandEdit", sender: nil)
    }
    
    @objc func ownerEditAction(){
        performSegue(withIdentifier: "manageSegueOwnerEdit", sender: nil)
    }
    
    @objc func roomAddAction(){
        performSegue(withIdentifier: "manageSegueRoomAdd", sender: nil)
    }
    
    @objc func categoryAddAction(){
        performSegue(withIdentifier: "manageSegueCategoryAdd", sender: nil)
    }
    
    @objc func brandAddAction(){
        performSegue(withIdentifier: "manageSegueBrandAdd", sender: nil)
    }
    
    @objc func ownerAddAction(){
        performSegue(withIdentifier: "manageSegueOwnerAdd", sender: nil)
    }
    
    #if targetEnvironment(macCatalyst)
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        
        touchBar.defaultItemIdentifiers = [.touchRoomEdit, .touchCategoryEdit, .touchBrandEdit, .touchOwnerEdit, .flexibleSpace, .touchRoom, .touchCategory, .touchBrand, .touchOwner]
        
        // edit buttons
        let roomEdit = NSButtonTouchBarItem(identifier: .touchRoomEdit, image: UIImage(systemName: "bed.double.fill")!, target: self, action: #selector(roomEditAction))
        roomEdit.bezelColor = Global.colorGreen
        
        let categoryEdit = NSButtonTouchBarItem(identifier: .touchCategoryEdit, image: UIImage(systemName: "book")!, target: self, action: #selector(categoryEditAction))
        categoryEdit.bezelColor = Global.colorGreen
        
        let brandEdit = NSButtonTouchBarItem(identifier: .touchBrandEdit, image: UIImage(systemName: "cube.box")!, target: self, action: #selector(brandEditAction))
        brandEdit.bezelColor = Global.colorGreen
        
        let ownerEdit = NSButtonTouchBarItem(identifier: .touchOwnerEdit, image: UIImage(systemName: "person.2.fill")!, target: self, action: #selector(ownerEditAction))
        ownerEdit.bezelColor = Global.colorGreen
        
        // add buttons
        let roomAdd = NSButtonTouchBarItem(identifier: .touchRoom, image: UIImage(systemName: "bed.double.fill")!, target: self, action: #selector(roomAddAction))
        roomAdd.bezelColor = Global.colorBlue
        
        let categoryAdd = NSButtonTouchBarItem(identifier: .touchCategory, image: UIImage(systemName: "book")!, target: self, action: #selector(categoryAddAction))
        categoryAdd.bezelColor = Global.colorBlue
        
        let brandAdd = NSButtonTouchBarItem(identifier: .touchBrand, image: UIImage(systemName: "cube.box")!, target: self, action: #selector(brandAddAction))
        brandAdd.bezelColor = Global.colorBlue
        
        let ownerAdd = NSButtonTouchBarItem(identifier: .touchOwner, image: UIImage(systemName: "person.2.fill")!, target: self, action: #selector(ownerAddAction))
        ownerAdd.bezelColor = Global.colorBlue
        
        touchBar.templateItems = [roomEdit, categoryEdit, brandEdit, ownerEdit, roomAdd, categoryAdd, brandAdd, ownerAdd]
        
        return touchBar
    }

    #endif
    
}
