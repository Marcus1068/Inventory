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
class Statistics: NSObject{
    
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
    

    /// return the size of complete inventory in megabyte
    /// will be calculated as all image sizes + all pdf file sizes + memory of object itself
    /// - Returns: Double containing size in MB
    public func getInventorySizeinMegaBytes() -> Double{
        var storageSize = 0.0
        
        for inv in inventory{
            if let imgSize = inv.image?.length{
                storageSize += Double(imgSize)
            }
            
            if let pdfSize = inv.invoice?.length{
                storageSize += Double(pdfSize)
            }
            
            storageSize += Double(MemoryLayout.size(ofValue: inv))
        }
        
        if storageSize > 0{
            return storageSize / 1024.0 / 1024.0
        }
        
        return 0.0
    }
    
    /// return sum of all item prices
    ///
    /// - Returns: an Int with the sum of all prices added
    public func itemPricesSum() -> Int{
        var sum = 0
        
        for inv in inventory{
            sum += Int(inv.price)
        }
        
        return sum
    }
    
    /// will be called automatically by notification observer for core data
    public func refresh(){
        inventory = CoreDataHandler.fetchInventory()
    }
    
    /// most items by room
    ///
    /// - Returns: a dict comtaining key as room name and value as item number of occurrences per room
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
    
    /// return a sorted string array of inventory names
    ///
    /// - Parameter elementsCount: number of array elements to be returned
    /// - Returns: inventory array
    func allInventory(elementsCount: Int) -> [Inventory]{
        return inventory.first(elementCount: elementsCount)
    }
    
    /// return an inventory array sorted by price and reduced to n elements
    ///
    /// - Parameter elementsCount: number of array elements to be returned
    /// - Returns: inventory array sorted by price with most expensive item first
    func mostExpensiveItems(elementsCount: Int) -> [Inventory]{
        let sortedByPrice = inventory.sorted(by: {$0.price > $1.price})
        
        return sortedByPrice.first(elementCount: elementsCount)
    }
}

// reduce the number of array elements to elementCount
extension Array {
    func first(elementCount: Int) -> Array {
        let min = Swift.min(elementCount, count)
        return Array(self[0..<min])
    }
}
