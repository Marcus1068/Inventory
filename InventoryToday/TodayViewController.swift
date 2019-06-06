//
//  TodayViewController.swift
//  InventoryToday
//
//  Created by Marcus Deuß on 05.06.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreMedia
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var topPricesLabel: UILabel!
    @IBOutlet weak var topPricesValue: UILabel!
    @IBOutlet weak var openAction: UIButton!
    
    //let store = CoreDataStorage.shared
    let stats = Statistics.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        // Do any additional setup after loading the view.
        
        
        //let _ = store.getContext()
        
        // enable statistics collection
        //let stats = Statistics.shared
        
        topPricesLabel.text = "Summe aller Inventarobjekte"
        topPricesValue.text = String(stats.getInventoryItemCount())
        //store.showSampleData()
        print(stats.getInventoryItemCount())
        
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
        DispatchQueue.main.async
        {
            self.topPricesLabel.text = String(self.stats.getInventoryItemCount())
        }
        
        
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func openAction(_ sender: UIButton) {
        self.extensionContext?.open(URL(string: "open:")!, completionHandler: nil)

    }
    
    
}
