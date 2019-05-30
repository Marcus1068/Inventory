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
//  TopPricesControllerInterfaceController.swift
//  Watch Extension
//
//  Created by Marcus Deuß on 26.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import WatchKit
import Foundation


class TopPricesInterfaceController: WKInterfaceController {

    @IBOutlet weak var tableForPrices: WKInterfaceTable!
    
    // contains list of most expensive items
    var topPrices : [String : Int] = [ : ]{
        didSet{
            OperationQueue.main.addOperation {
                self.tableRefresh()
            }
        }
    }
    
    
    // MARK: - table functions
    
    func tableRefresh(){
        tableForPrices.setNumberOfRows(topPrices.count, withRowType: "PricesRowController")
        var index : Int = 0
        for (idx, val) in topPrices.sorted(by: {$0.value > $1.value}){
            let row = tableForPrices.rowController(at: index) as! PricesRowController
            index += 1
            row.itemOutlet.setText(String(index) + ": " + idx)
            row.priceOutlet.setText(String(val) + Local.currencySymbol!)
        }
    }
    
    // MARK: - table functions
    //table selection method
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        //print(rowIndex)
        
        //presentController(withName: "TopPrices", context: top)
    }
    
    
    // MARK: - callbacks
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        print("in TopPricesInterfaceController")
        
        // Configure interface objects here.
        if let topPriceList = context as? [String : Int] {
            self.topPrices = topPriceList
        }
        
 /*       // sorted dict of most expensive items
        for (idx, val) in topPrices.sorted(by: {$0.value > $1.value}){
            print(idx, val)
        } */
        
        self.setTitle(NSLocalizedString("Top Prices", comment: "Top Prices"))
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
