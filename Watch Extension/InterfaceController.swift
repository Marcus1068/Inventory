//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Marcus Deuß on 23.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var pickerOutlet: WKInterfacePicker!
    @IBOutlet weak var myLabel: WKInterfaceLabel!
    
    let titles = [
        "Most expensive","Most by room",
        "Most by category","success",
        "failure","retry"
    ]

    let stat = Statistics.shared
    var topList : [Inventory] = []
    
    // MARK: - callbacks
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        topList = stat.mostExpensiveItems(elementsCount: 3)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        refreshPickerItems()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // MARK: - actions
    
    @IBAction func pickerDidChange(_ value: Int) {
        print(value)
        //let text = titles.index(value, offsetBy: 0)
        myLabel.setText(titles[value])
    }
    
    // MARK: - helper methods
    
    func refreshPickerItems(){
        var pickerItems:[WKPickerItem] = []
        /*for item in titles{
            let pickerItem = WKPickerItem()
            pickerItem.title = item
            pickerItems += [pickerItem]
        }*/
        for item in topList{
            let pickerItem = WKPickerItem()
            pickerItem.title = item.inventoryName
            pickerItems += [pickerItem]
        }
        pickerOutlet.setItems(pickerItems)
    }
}
