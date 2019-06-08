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


class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var topPricesLabel: UILabel!
    @IBOutlet weak var topPricesValue: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var valueTextView: UITextView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countValueLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var inventory: [Inventory] = []
    var sortedByPrice: [Inventory] = []
    
    let store = CoreDataStorage.shared
    
    let segmentArray : [String] = [Local.price, Local.room, Local.category, Local.brand, Local.owner]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        topPricesLabel.isHidden = true
        topPricesValue.isHidden = true
        textView.isHidden = true
        valueTextView.isHidden = true
        //segmentControl.isHidden = true
        countLabel.isHidden = true
        countValueLabel.isHidden = true
        overviewLabel.isHidden = true
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        replaceSegmentContents(segments: segmentArray, control: segmentControl)
        self.segmentControl.selectedSegmentIndex = 0
        
        update(status: Local.price)
        
    }
    
    func itemPricesSum() -> Int{
        var sum = 0
        
        for inv in inventory{
            sum += Int(inv.price)
        }
        
        return sum
    }
    
    /// most items by brand
    ///
    /// - Returns: a dict comtaining key as brand name and value as item number of occurrences per brand
    /// - Example: ["BAR": 1, "FOOBAR": 1, "FOO": 2]
    func countItemsByBrandDict() -> [(key: String, value: Int)]{
        var arr : [String] = []
        
        for inv in inventory{
            arr.append(inv.inventoryBrand?.brandName ?? "")
        }
        
        let dict = arr.reduce(into: [:]) { counts, word in counts[word, default: 0] += 1 }
        
        return dict.sorted { $0.value > $1.value }
    }
    
    /// most items by category
    ///
    /// - Returns: a dict comtaining key as category name and value as item number of occurrences per category
    /// - Example: ["BAR": 1, "FOOBAR": 1, "FOO": 2]
    func countItemsByCategoryDict() -> [(key: String, value: Int)]{
        var arr : [String] = []
        
        for inv in inventory{
            arr.append(inv.inventoryCategory?.categoryName ?? "")
        }
        
        let dict = arr.reduce(into: [:]) { counts, word in counts[word, default: 0] += 1 }
        
        return dict.sorted { $0.value > $1.value }
    }
    
    /// most items by room
    ///
    /// - Returns: a dict containing key as room name and value as item number of occurrences per room
    /// - Example: ["BAR": 1, "FOOBAR": 1, "FOO": 2]
    func countItemsByRoomDict() -> [(key: String, value: Int)]{
        var arr : [String] = []
        
        for inv in inventory{
            arr.append(inv.inventoryRoom?.roomName ?? "")
        }
        
        let dict = arr.reduce(into: [:]) { counts, word in counts[word, default: 0] += 1 }
        
        return dict.sorted { $0.value > $1.value }
    }
    
    /// most items by owner
    ///
    /// - Returns: a dict comtaining key as owner name and value as item number of occurrences per owner
    /// - Example: ["BAR": 1, "FOOBAR": 1, "FOO": 2]
    func countItemsByOwnerDict() -> [(key: String, value: Int)]{
        var arr : [String] = []
        
        for inv in inventory{
            arr.append(inv.inventoryOwner?.ownerName ?? "")
        }
        
        let dict = arr.reduce(into: [:]) { counts, word in counts[word, default: 0] += 1 }
        
        return dict.sorted { $0.value > $1.value }
    }
    
    // based on selected segment setup text views
    func segmentChosen(myCountFunc: () -> [(key: String, value: Int)]){
        self.textView.text = ""
        self.valueTextView.text = ""
        
        // get 5 most used rooms
        if self.inventory.count > 0{
            let dict = myCountFunc()
            var textLabel : String = ""
            var textValue : String = ""
            
            var count : Int = 0
            for (key, value) in dict{
                textLabel = textLabel + key + "\n"
                textValue = textValue + String(value) + "\n"
                count += 1
                
                if count == 5{
                    break
                }
            }
            self.textView.text = textLabel
            self.valueTextView.text = textValue
        }
    }
    
    func priceSegmentChosen(){
        self.textView.text = ""
        self.valueTextView.text = ""
        
        // get 5 most expensive items
        if self.inventory.count > 0{
            self.sortedByPrice = self.inventory.sorted(by: {$0.price > $1.price})
            var textLabel : String = ""
            var textValue : String = ""
            
            for i in self.sortedByPrice.first(elementCount: 5){
                textLabel = textLabel + i.inventoryName! + "\n"
                textValue = textValue + String(i.price) + Local.currencySymbol! + "\n"
            }
            
            self.textView.text = textLabel
            self.valueTextView.text = textValue
        }
    }
    
    // This method will be called each time you click on the More/Less button. At the moment activeDisplayMode can be equal to compact or expanded
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 250)
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        

        topPricesLabel.isHidden = false
        topPricesValue.isHidden = false
        textView.isHidden = false
        valueTextView.isHidden = false
        //segmentControl.isHidden = true
        countLabel.isHidden = false
        countValueLabel.isHidden = false
        overviewLabel.isHidden = false
        
        
        completionHandler(NCUpdateResult.newData)
    }
    
    // fill a segment control with values
    func replaceSegmentContents(segments: [String], control: UISegmentedControl) {
        control.removeAllSegments()
        for segment in segments {
            control.insertSegment(withTitle: segment, at: control.numberOfSegments, animated: false)
        }
    }
    
    // update all labels with new data
    func update(status: String){
        inventory = store.fetchInventoryWithoutBinaryData()
        
        overviewLabel.text = NSLocalizedString("Top 5:", comment: "Top 5")
        DispatchQueue.main.async
            {
                switch status{
                case Local.price:
                    self.priceSegmentChosen()
                case Local.room:
                    self.segmentChosen(myCountFunc: self.countItemsByRoomDict)
                case Local.category:
                    self.segmentChosen(myCountFunc: self.countItemsByCategoryDict)
                case Local.brand:
                    self.segmentChosen(myCountFunc: self.countItemsByBrandDict)
                case Local.owner:
                    self.segmentChosen(myCountFunc: self.countItemsByOwnerDict)
                default:
                    self.priceSegmentChosen()
                }
                
                self.topPricesLabel.text = NSLocalizedString("Cost of inventory", comment: "Cost of inventory")
                self.topPricesValue.text = String(self.itemPricesSum()) + Local.currencySymbol!
                
                self.countLabel.text = NSLocalizedString("Number of objects", comment: "Number of objects")
                self.countValueLabel.text = String(self.inventory.count)
                
        }
    }
    
    //@IBAction func openAction(_ sender: UIButton) {
        //self.extensionContext?.open(URL(string: "open:")!, completionHandler: nil)
    //}
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        switch segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex){
        case Local.price:
            update(status: Local.price)
        case Local.room:
            update(status: Local.room)
        case Local.category:
            update(status: Local.category)
        case Local.brand:
            update(status: Local.brand)
        case Local.owner:
            update(status: Local.owner)
        default:
            update(status: Local.price)
        }
    }
    
}
