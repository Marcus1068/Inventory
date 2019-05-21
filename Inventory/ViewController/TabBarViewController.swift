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

//  initial view controller
//
//  TabBarViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 20.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let myInventory = CoreDataHandler.fetchInventory()
        
        // generate initial data if none available
        if (myInventory.count == 0){
            let rooms = CoreDataHandler.fetchAllRooms()
            let categories = CoreDataHandler.fetchAllCategories()
            let owners = CoreDataHandler.fetchAllOwners()
            let brands = CoreDataHandler.fetchAllBrands()
            
            // only generate data if complete data is gone
            if rooms.count == 0 && categories.count == 0 && owners.count == 0 && brands.count == 0{
                CoreDataHandler.generateInitialAppData()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
  /*  override func becomeFirstResponder() -> Bool {
        return true
    } */

}
