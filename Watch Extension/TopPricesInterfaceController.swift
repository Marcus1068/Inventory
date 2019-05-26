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
    var topPrices = TopPrice()
    
    // MARK: - table functions
    
    func tableRefresh(){
        /*var strArray : [String] = []
        for (idx, value) in topPrices.prices{
            strArray.append(idx + String(value))
        }*/
        
        tableForPrices.setNumberOfRows(topPrices.prices.count, withRowType: "PricesRowController")
        for index in 0 ..< tableForPrices.numberOfRows {
            let row = tableForPrices.rowController(at: index) as! PricesRowController
            //let str = topPrices.item[index] + String(topPrices.value[index])
            row.itemOutlet.setText(topPrices.item[index])
            row.priceOutlet.setText(topPrices.value[index])
        }
        
    }
    
    // MARK: - table functions
    //table selection method
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        print(rowIndex)
        //let flight = flights[rowIndex]
        //top.topPrices = topPrices
        //presentController(withName: "TopPrices", context: top)
    }
    
    
    // MARK: - callbacks
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        print("in TopPricesInterfaceController")
        
        // Configure interface objects here.
        if let topPriceList = context as? TopPrice {
            self.topPrices = topPriceList
        }
        
        // sorted dict of most expensive items
   /*     for (idx, val) in topPrices.prices.sorted(by: {$0.value > $1.value}){
            print(idx, val)
        } */
        
        //print(topPrices.prices.count)
        
        //self.setTitle("Testtest") // FIXME
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
