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
//  TopCategoriesInterfaceController.swift
//  Watch Extension
//
//  Created by Marcus Deuß on 28.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import WatchKit
import Foundation


class CategoryInterfaceController: WKInterfaceController {

    // contains list of categories with item occurance per category
    var categoryList : [String : Int] = [ : ]{
        didSet{
            OperationQueue.main.addOperation {
                self.tableRefresh()
            }
        }
    }
    
    @IBOutlet weak var table: WKInterfaceTable!
    
    // MARK: - table functions
    
    func tableRefresh(){
        table.setNumberOfRows(categoryList.count, withRowType: "CategoriesRowController")
        var index : Int = 0
        for (idx, val) in categoryList.sorted(by: {$0.value > $1.value}){
            let row = table.rowController(at: index) as! CategoriesRowController
            index += 1
            row.categoryLabel.setText(String(index) + ": " + idx)
            row.countLabel.setText(String(val))
        }
    }
    
    // MARK: - table functions
    //table selection method
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        //presentController(withName: "TopPrices", context: top)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        if let myCategoryList = context as? [String : Int] {
            self.categoryList = myCategoryList
        }
        
        self.setTitle(Local.mostUsedCategories)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        tableRefresh()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
