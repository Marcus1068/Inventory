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

    // contains list of most expensive items
    var topPrices : [String : Int] = [ : ]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        if let topPrices = context as? [String : Int] {
            self.topPrices = topPrices
        }
        
        // sorted dict of most expensive items
        for (idx, val) in topPrices.sorted(by: {$0.value > $1.value}){
            print(idx, val)
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
