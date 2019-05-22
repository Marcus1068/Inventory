//
//  Statistics.swift
//  Inventory
//
//  Created by Marcus Deuß on 22.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import Foundation
import CoreData
import os

// uses singleton pattern
// Usage: let stats = Statistics.shared, print(stats.images)
/// returns a lot of internal statistics useful for evaluating how many objects
class Statistics: CoreDataHandler{
    
    // MARK: - Properties
    
    // shared enables singleton usage
    static let shared = Statistics(setup: "Init")
    
    var setup: String
    var inventory: [Inventory]
    
    // MARK: - getter
    var images: Int {
        var numberOfImages = 0
        for inv in inventory{
            if inv.image != nil{
                numberOfImages += 1
            }
        }
        return numberOfImages
    }
    
    var pdfs: Int {
        var numberOfpdf = 0
        for inv in inventory{
            if inv.invoice != nil{
                numberOfpdf += 1
            }
        }
        return numberOfpdf
    }
    
    // MARK: - Initialization
    
    init(setup: String) {
        self.setup = setup
        
        inventory = CoreDataHandler.fetchInventory()
    }

    // MARK: - methods
    
    func getStatisticsForImages() -> Double{
        var sum : Double = 0.0
        
        for inv in inventory{
            if let size = inv.image?.length{
                sum += Double(size)
            }
        }
        return sum
    }
    
    func getInventoryItemCount() -> Int{
        return inventory.count
    }
    
    // will be called automatically by notification observer for core data
    public func refresh(){
        inventory = CoreDataHandler.fetchInventory()
    }
}
