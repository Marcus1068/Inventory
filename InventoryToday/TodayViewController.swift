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
//  TodayViewController.swift
//  InventoryToday
//
//  Created by Marcus Deuß on 05.06.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit
import NotificationCenter
//import CoreData

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var topPricesLabel: UILabel!
    @IBOutlet weak var topPricesValue: UILabel!
    @IBOutlet weak var openAction: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var inventory: [Inventory] = []
    var sortedByPrice: [Inventory] = []
    
    let store = CoreDataStorage.shared
    //let stats = Statistics.shared
    
    public func itemPricesSum() -> Int{
        var sum = 0
        
        for inv in inventory{
            sum += Int(inv.price)
        }
        
        return sum
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        // Do any additional setup after loading the view.
        
        //store = store.getContext()
        
        
        //inventory = store.fetchInventoryWithoutBinaryData()
        
        // enable statistics collection
        //let stats = Statistics.shared
        
        //topPricesLabel.text = String(itemPricesSum())
        //topPricesValue.text = String(inventory.count)
        
        inventory = store.fetchInventoryWithoutBinaryData()
        
        DispatchQueue.main.async
        {
            self.topPricesLabel.text = String(self.itemPricesSum())
            self.topPricesValue.text = String(self.inventory.count)
        }
        
    }
    
    // This method will be called each time you click on the More/Less button. At the moment activeDisplayMode can be equal to compact or expanded
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 200)
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        // enable statistics collection
        //let _ = store.getContext()

        inventory = store.fetchInventoryWithoutBinaryData()
        
        if inventory.count > 0{
            sortedByPrice = inventory.sorted(by: {$0.price > $1.price})
            var text : String = ""
            for i in sortedByPrice.first(elementCount: 5){
                text = text + i.inventoryName! + " " + String(i.price) + "\n"
            }
            textView.text = text
        }
        
        DispatchQueue.main.async
        {
            self.topPricesLabel.text = String(self.itemPricesSum())
            self.topPricesValue.text = String(self.inventory.count)
        }
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func openAction(_ sender: UIButton) {
        self.extensionContext?.open(URL(string: "open:")!, completionHandler: nil)
    }
    
}
