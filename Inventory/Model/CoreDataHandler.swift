//
//  CoreDataHandler.swift
//  Inventory
//
//  Created by Marcus Deuß on 23.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import CoreData
import os.log


class CoreDataHandler: NSObject {
    
    // internal: get database context
    class func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    
    // Save a room
    class func saveRoom(roomName: String) -> Room
    {
        os_log("saveRoom in AppDelegate", log: OSLog.default, type: .debug)
        
        let context = getContext()
        let room = Room(context: context)
        
        room.roomName = roomName
        
        do {
            try context.save()
            return room
        } catch  {
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    class func updateRoom(room: Room) -> Bool{
        let context = getContext()
        let request : NSFetchRequest<Room> = Room.fetchRequest()
        var found = false
        
        // search predicate
        request.predicate = NSPredicate(format: "roomName = %@", room.roomName!)
        
        do {
            _ = try context.fetch(request)
            found = true
        } catch {
            print("Error with fetch request in updateRoom \(error)")
        }
        
        if(found){
            do {
                try context.save()
                return true
            } catch  {
                let nserror = error as NSError
                
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        return false
    }
    
    // delete room object
    class func deleteRoom(room: Room) -> Bool{
        let context = getContext()
        
        context.delete(room)
        
        do {
            try context.save()
            return true
        } catch  {
            return false
        }
    }
    
    // delete all room objects
    class func deleteAllRooms() -> Bool{
        let context = getContext()
        
        let delete = NSBatchDeleteRequest(fetchRequest: Room.fetchRequest())
        
        do {
            try context.execute(delete)
            return true
        } catch  {
            return false
        }
    }
    
    // Save a category
    class func saveCategory(categoryName: String) -> Category
    {
        let context = getContext()
        
        let category = Category(context: context)
        
        category.categoryName = categoryName
        
        do {
            try context.save()
            return category
        } catch  {
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    class func updateCategory(category: Category) -> Bool{
        let context = getContext()
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        var found = false
        
        // search predicate
        request.predicate = NSPredicate(format: "categoryName = %@", category.categoryName!)
        
        do {
            _ = try context.fetch(request)
            found = true
        } catch {
            print("Error with fetch request in updateCategory \(error)")
        }
        
        if(found){
            do {
                try context.save()
                return true
            } catch  {
                let nserror = error as NSError
                
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        return false
    }
    
    // delete category object
    class func deleteCategory(category: Category) -> Bool{
        let context = getContext()
        
        context.delete(category)
        
        do {
            try context.save()
            return true
        } catch  {
            return false
        }
    }
    
    // delete all category objects
    class func deleteAllCategories() -> Bool{
        let context = getContext()
        
        let delete = NSBatchDeleteRequest(fetchRequest: Category.fetchRequest())
        
        do {
            try context.execute(delete)
            return true
        } catch  {
            return false
        }
    }
    
    // Save an owner
    class func saveOwner(ownerName: String) -> Owner
    {
        os_log("saveOwner in AppDelegate", log: OSLog.default, type: .debug)
        
        let context = AppDelegate.viewContext
        let owner = Owner(context: context)
        
        owner.ownerName = ownerName
        
        do {
            try context.save()
            return owner
        } catch  {
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    class func updateOwner(owner: Owner) -> Bool{
        let context = getContext()
        let request : NSFetchRequest<Owner> = Owner.fetchRequest()
        var found = false
        
        // search predicate
        request.predicate = NSPredicate(format: "ownerName = %@", owner.ownerName!)
        
        do {
            _ = try context.fetch(request)
            found = true
        } catch {
            print("Error with fetch request in updateOwner \(error)")
        }
        
        if(found){
            do {
                try context.save()
                return true
            } catch  {
                let nserror = error as NSError
                
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        return false
    }
    
    // delete owner object
    class func deleteOwner(owner: Owner) -> Bool{
        let context = getContext()
        
        context.delete(owner)
        
        do {
            try context.save()
            return true
        } catch  {
            return false
        }
    }
    
    // delete all owner objects
    class func deleteAllOwners() -> Bool{
        let context = getContext()
        
        let delete = NSBatchDeleteRequest(fetchRequest: Owner.fetchRequest())
        
        do {
            try context.execute(delete)
            return true
        } catch  {
            return false
        }
    }
    
    // Save a Brand
    class func saveBrand(brandName: String) -> Brand
    {
        os_log("saveBrand in AppDelegate", log: OSLog.default, type: .debug)
        
        let context = AppDelegate.viewContext
        let brand = Brand(context: context)
        
        brand.brandName = brandName
        
        do {
            try context.save()
            return brand
        } catch  {
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    class func updateBrand(brand: Brand) -> Bool{
        let context = getContext()
        let request : NSFetchRequest<Brand> = Brand.fetchRequest()
        var found = false
        
        // search predicate
        request.predicate = NSPredicate(format: "brandName = %@", brand.brandName!)
        
        do {
            _ = try context.fetch(request)
            found = true
        } catch {
            print("Error with fetch request in updateBrand \(error)")
        }
        
        if(found){
            do {
                try context.save()
                return true
            } catch  {
                let nserror = error as NSError
                
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        return false
    }
    
    // delete brand object
    class func deleteBrand(brand: Brand) -> Bool{
        let context = getContext()
        
        context.delete(brand)
        
        do {
            try context.save()
            return true
        } catch  {
            return false
        }
    }
    
    // delete all brand objects
    class func deleteAllBrands() -> Bool{
        let context = getContext()
        
        let delete = NSBatchDeleteRequest(fetchRequest: Brand.fetchRequest())
        
        do {
            try context.execute(delete)
            return true
        } catch  {
            return false
        }
    }
    
    // add a single row to Vokabel table
    class func saveInventory(inventoryName: String, dateOfPurchase: NSDate, price: Int32, remark: String, serialNumber: String, warranty: Int32, image: NSData, invoice: NSData, brand: Brand, category: Category, owner: Owner, room: Room) -> Inventory
    {
        let context = getContext()
        
        let inventory = Inventory(context: context)
        
        // set object with IU values
        inventory.inventoryName = inventoryName
        inventory.dateOfPurchase = dateOfPurchase
        inventory.price = price
        inventory.remark = remark
        inventory.serialNumber = serialNumber
        inventory.warranty = warranty
        inventory.image = image;
        inventory.invoice = invoice;
        inventory.inventoryBrand = brand
        inventory.inventoryCategory = category
        inventory.inventoryOwner = owner
        inventory.inventoryRoom = room
        // timeStamp generated automatically
        inventory.timeStamp = Date() as NSDate?
        
        // save data
        do {
            try context.save()
            return inventory
        } catch  {
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    class func updateInventory(inventory: Inventory) -> Bool{
        let context = getContext()
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        var found = false
        
        // search predicate
        request.predicate = NSPredicate(format: "inventoryName = %@", inventory.inventoryName!)
        
        do {
            _ = try context.fetch(request)
            found = true
        } catch {
            print("Error with fetch request in updateInventory \(error)")
        }
        
        if(found){
            do {
                try context.save()
                return true
            } catch  {
                let nserror = error as NSError
                
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        return false
    }
    
    // fetch all category array, otherwise return [] empty array
    class func fetchAllCategories() -> [Category]
    {
        os_log("fetchAllCategories", log: OSLog.default, type: .debug)
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "categoryName", ascending: true)]
        
        let context = getContext()
        
        do {
            let categories = try context.fetch(request)
            
            return categories
            
        } catch {
            print("Error with fetch request in fetchAllCategories \(error)")
        }
        
        return []
        
    }
    
    // fetch all brand array, otherwise return [] empty array
    class func fetchAllBrands() -> [Brand]
    {
        os_log("fetchAllBrands", log: OSLog.default, type: .debug)
        
        let request : NSFetchRequest<Brand> = Brand.fetchRequest()
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "brandName", ascending: true)]
        
        let context = getContext()
        
        do {
            let brands = try context.fetch(request)
            
            return brands
            
        } catch {
            print("Error with fetch request in fetchAllBrands \(error)")
        }
        
        return []
        
    }
    
    // fetch all owner array, otherwise return [] empty array
    class func fetchAllOwners() -> [Owner]
    {
        os_log("fetchAllOwners", log: OSLog.default, type: .debug)
        
        let request : NSFetchRequest<Owner> = Owner.fetchRequest()
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "ownerName", ascending: true)]
        
        let context = getContext()
        
        do {
            let owners = try context.fetch(request)
            
            return owners
            
        } catch {
            print("Error with fetch request in fetchAllOwners \(error)")
        }
        
        return []
        
    }
    
    // fetch all room array, otherwise return [] empty array
    class func fetchAllRooms() -> [Room]
    {
        os_log("fetchAllRooms", log: OSLog.default, type: .debug)
        
        let request : NSFetchRequest<Room> = Room.fetchRequest()
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "roomName", ascending: true)]
        
        let context = getContext()
        
        do {
            let rooms = try context.fetch(request)
            
            return rooms
            
        } catch {
            print("Error with fetch request in fetchAllRooms \(error)")
        }
        
        return []
        
    }
    
    // fetch array, if no array, return nil
    class func fetchInventory() -> [Inventory]
    {
        os_log("fetchInventory in AppDelegate", log: OSLog.default, type: .debug)
        
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]
        
        let context = getContext()
        
        do {
            let inventory = try context.fetch(request)
            
            return inventory
            
        } catch {
            print("Error with fetch request in fetchInventory \(error)")
        }
        
        //print(vokabeln?.count)
        
        return []
        
    }
    
    // fetch all inventory from a certain room array, otherwise return [] empty array
    class func fetchInventoryByRoom(roomName: String) -> [Inventory]
    {
        os_log("fetchInventoryByRoom", log: OSLog.default, type: .debug)
        
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        
        // search predicate
        request.predicate = NSPredicate(format: "inventoryRoom.roomName = %@", roomName)    // FIXME, migth crash
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]
        
        let context = getContext()
        
        do {
            let inventory = try context.fetch(request)
            
            return inventory
            
        } catch {
            print("Error with fetch request in fetchInventoryByRoom \(error)")
        }
        
        return []
    }
    
    // generate sample data for initial work
    // FIXME must be depening upon system language with switch/case of supported languages, default english
    class func generateSampleData()
    {
        os_log("generateSampleData", log: OSLog.default, type: .debug)
        
        // default rooms
        let raum0 = saveRoom(roomName: "nicht definiert")
        let raum1 = saveRoom(roomName: "Wohnzimmer")
        let raum2 = saveRoom(roomName: "Buero")
        let raum3 = saveRoom(roomName: "Kinderzimmer 1")
        let raum4 = saveRoom(roomName: "Kinderzimmer 2")
        let raum5 = saveRoom(roomName: "Kueche")
        let raum6 = saveRoom(roomName: "Waschkeller")
        let raum7 = saveRoom(roomName: "Schlafzimmer")
        let raum8 = saveRoom(roomName: "Hobbykeller")
        
        
        // default categories
        
        let kategorie0 = saveCategory(categoryName: "keine Kategorie")
        let kategorie1 = saveCategory(categoryName: "Technik")
        let kategorie2 = saveCategory(categoryName: "Moebel")
        let kategorie3 = saveCategory(categoryName: "Computer")
        let kategorie4 = saveCategory(categoryName: "Schmuck")
        let kategorie5 = saveCategory(categoryName: "Spielzeug")
        let kategorie6 = saveCategory(categoryName: "Fernseher")
        let kategorie7 = saveCategory(categoryName: "Smartphone")
        let kategorie8 = saveCategory(categoryName: "Tablet")
        
        // default owners
        
        let person0 = saveOwner(ownerName: "keiner")
        let person1 = saveOwner(ownerName: "Marcus")
        let person2 = saveOwner(ownerName: "Sandra")
        let person3 = saveOwner(ownerName: "Emily")
        let person4 = saveOwner(ownerName: "Vincent")
        
        
        // default brands
        
        let brand0 = saveBrand(brandName: "sonstige")
        let brand1 = saveBrand(brandName: "IKEA")
        let brand2 = saveBrand(brandName: "Apple")
        let brand3 = saveBrand(brandName: "Sonos")
        let brand4 = saveBrand(brandName: "Thermomix")
        let brand5 = saveBrand(brandName: "Sony")
        let brand6 = saveBrand(brandName: "Google")
        
        
        let date = Date() as NSDate // today
        let arr : [UInt32] = [32,4,123,4,5,2]
        let myImage = #imageLiteral(resourceName: "Owner Icon")
        let myImage2 = #imageLiteral(resourceName: "Category Icon")
        let myImage3 = #imageLiteral(resourceName: "Camera Icon")
        let myImage4 = #imageLiteral(resourceName: "Computer Icon")
        let myImage5 = #imageLiteral(resourceName: "Phone Icon")
        let myImage6 = #imageLiteral(resourceName: "Room Icon")
        let imageData1 = UIImageJPEGRepresentation(myImage, 0.1)
        let imageData2 = UIImageJPEGRepresentation(myImage2, 0.1)
        let imageData3 = UIImageJPEGRepresentation(myImage3, 0.1)
        let imageData4 = UIImageJPEGRepresentation(myImage4, 0.1)
        let imageData5 = UIImageJPEGRepresentation(myImage5, 0.1)
        let imageData6 = UIImageJPEGRepresentation(myImage6, 0.1)
        let myinvoice = NSData(bytes: arr, length: arr.count * 32)
        
        
        _ = saveInventory(inventoryName: "Weber Grill", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData3! as NSData, invoice: myinvoice, brand: brand0, category: kategorie5, owner: person1, room: raum2)
        
        _ = saveInventory(inventoryName: "Amazon Echo Spot", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData2! as NSData, invoice: myinvoice, brand: brand3, category: kategorie1, owner: person2, room: raum2)
        
        _ = saveInventory(inventoryName: "Macbook Pro 13", dateOfPurchase: date, price: 2399, remark: "tolles", serialNumber: "12345", warranty: 36, image: imageData5! as NSData, invoice: myinvoice, brand: brand1, category: kategorie3, owner: person1, room: raum1)
        
        _ = saveInventory(inventoryName: "Sony 43 Zoll TV", dateOfPurchase: date, price: 999, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData2! as NSData, invoice: myinvoice, brand: brand5, category: kategorie6, owner: person2, room: raum3)
        
        _ = saveInventory(inventoryName: "Sonos", dateOfPurchase: date, price: 799, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData3! as NSData, invoice: myinvoice, brand: brand1, category: kategorie6, owner: person2, room: raum3)
        
        _ = saveInventory(inventoryName: "Aquarium", dateOfPurchase: date, price: 300, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData1! as NSData, invoice: myinvoice, brand: brand0, category: kategorie2, owner: person3, room: raum1)
        
        _ = saveInventory(inventoryName: "Pixel 2XL", dateOfPurchase: date, price: 900, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData2! as NSData, invoice: myinvoice, brand: brand6, category: kategorie7, owner: person1, room: raum1)
        
        _ = saveInventory(inventoryName: "iPhone X", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData4! as NSData, invoice: myinvoice, brand: brand2, category: kategorie7, owner: person1, room: raum4)
        
        _ = saveInventory(inventoryName: "Irgendwas", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData4! as NSData, invoice: myinvoice, brand: brand4, category: kategorie4, owner: person1, room: raum0)
        
        _ = saveInventory(inventoryName: "iPhone 7", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData2! as NSData, invoice: myinvoice, brand: brand0, category: kategorie8, owner: person4, room: raum5)
        
        _ = saveInventory(inventoryName: "Samsung S7 Edge", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData5! as NSData, invoice: myinvoice, brand: brand0, category: kategorie0, owner: person0, room: raum6)
        
        _ = saveInventory(inventoryName: "iPhone 7Plus", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData1! as NSData, invoice: myinvoice, brand: brand0, category: kategorie8, owner: person2, room: raum7)
        
        _ = saveInventory(inventoryName: "Lego Apollo Rakete", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData2! as NSData, invoice: myinvoice, brand: brand3, category: kategorie1, owner: person4, room: raum8)
        
        _ = saveInventory(inventoryName: "Amazon Echo Spot Emily", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData6! as NSData, invoice: myinvoice, brand: brand3, category: kategorie1, owner: person3, room: raum3)
        
        _ = saveInventory(inventoryName: "Amazon Echo Spot", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData5! as NSData, invoice: myinvoice, brand: brand3, category: kategorie1, owner: person1, room: raum4)
        
        _ = saveInventory(inventoryName: "Amazon Echo Spot", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData2! as NSData, invoice: myinvoice, brand: brand3, category: kategorie1, owner: person4, room: raum5)
        
        _ = saveInventory(inventoryName: "Sony TV 55 Zoll", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData4! as NSData, invoice: myinvoice, brand: brand3, category: kategorie1, owner: person4, room: raum8)
        
        _ = saveInventory(inventoryName: "Samsung 40 TV", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData3! as NSData, invoice: myinvoice, brand: brand3, category: kategorie1, owner: person3, room: raum8)
        
        CoreDataHandler.showSampleData()
    }
    
    // just for testing and debugging, will not be used in final app
    class func showSampleData()
    {
        let inventory = fetchInventory()
        
        let rooms = fetchAllRooms()
        print ("Anzahl rooms:\(rooms.count)")
        let categories = fetchAllCategories()
        print ("Anzahl categories:\(categories.count)")
        let owners = fetchAllOwners()
        print ("Anzahl owners:\(owners.count)")
        let brands = fetchAllBrands()
        print ("Anzahl brands:\(brands.count)")
        
        for i in inventory{
            print("Inventory = \(i.inventoryName!), Raum: \(String(describing: i.inventoryRoom?.roomName))), Kategorie: \(String(describing: i.inventoryCategory?.categoryName))) , Besitzer: \(String(describing: i.inventoryOwner?.ownerName)), Marke: \(String(describing: i.inventoryBrand?.brandName)) ")
        }
        
        for j in rooms{
            print("Room = \(j.roomName!)")
        }
        
        for k in categories{
            print("Category = \(k.categoryName!)")
        }
        
        for l in brands{
            print("Brand = \(l.brandName!)")
        }
        
        for m in owners{
            print("Owner = \(m.ownerName!)")
        }
        
        let invWohn = fetchInventoryByRoom(roomName: "Wohnzimmer")  // FIXME hardcoded string
        print ("Anzahl Produkte im Wohnzimmer: \(invWohn.count)")
    }
    
}

