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
    static let shared = Statistics()
    
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
    
    // fetch array, if no array, return nil
    func fetchInventory() -> [Inventory]
    {
        //os_log("CoreDataHandler fetchInventory", log: Log.coredata, type: .info)
        
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]
        request.fetchBatchSize = 20
        
        let context = persistentContainer.viewContext
        
        do {
            let inventory = try context.fetch(request)
            
            return inventory
            
        } catch {
            print("Error with fetch request in fetchInventory \(error)")
        }
        
        return []
    }
    
    // MARK: - Initialization
    
    override init() {
        //super.init()
        
        // setup all properties
        self.setup = "setup"
        inventory = []
    }
    
    func start(){
        self.inventory = fetchInventory()
    }

    
    
    lazy var persistentContainer: NSPersistentContainer =
        {
            /*
             The persistent container for the application. This implementation
             creates and returns a container, having loaded the store for the
             application to it. This property is optional since there are legitimate
             error conditions that could cause the creation of the store to fail.
             */
            let container = NSPersistentContainer(name: "Inventory")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
    }()
    
    
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
        inventory = self.fetchInventory()
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
