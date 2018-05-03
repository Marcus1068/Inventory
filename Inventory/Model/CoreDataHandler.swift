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
    class func saveRoom(room: Room) -> Room
    {
        let context = getContext()
        
        do {
            try context.save()
            return room
        } catch  {
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // check if room already exists
    class func fetchRoom(roomName: String) -> Bool{
        let context = getContext()
        
        let request : NSFetchRequest<Room> = Room.fetchRequest()
        // search predicate
        request.predicate = NSPredicate(format: "roomName = %@", roomName)
        
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return true
            }
        } catch {
            print("Error with fetch request in fetchRoom \(error)")
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
    class func saveCategory(category: Category) -> Category
    {
        let context = getContext()
        
        do {
            try context.save()
            return category
        } catch  {
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // check if category already exists
    class func fetchCategory(categoryName: String) -> Bool{
        let context = getContext()
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        // search predicate
        request.predicate = NSPredicate(format: "categoryName = %@", categoryName)
        
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return true
            }
        } catch {
            print("Error with fetch request in fetchCategory \(error)")
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
    class func saveOwner(owner: Owner) -> Owner
    {
        let context = getContext()
        
        do {
            try context.save()
            return owner
        } catch  {
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // check if owner already exists
    class func fetchOwner(ownerName: String) -> Bool{
        let context = getContext()
        
        let request : NSFetchRequest<Owner> = Owner.fetchRequest()
        // search predicate
        request.predicate = NSPredicate(format: "ownerName = %@", ownerName)
        
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return true
            }
        } catch {
            print("Error with fetch request in fetchOwner \(error)")
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
    class func saveBrand(brand: Brand) -> Brand
    {
        let context = getContext()
        
        do {
            try context.save()
            return brand
        } catch  {
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // check if brand already exists
    class func fetchBrand(brandName: String) -> Bool{
        let context = getContext()
        
        let request : NSFetchRequest<Brand> = Brand.fetchRequest()
        // search predicate
        request.predicate = NSPredicate(format: "brandName = %@", brandName)
        
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return true
            }
        } catch {
            print("Error with fetch request in fetchBrand \(error)")
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
        
        let context = getContext()
        
        // german room list default data
        let roomList: [String] = ["nicht definiert", "Wohnzimmer", "Buero", "Kinderzimmer 1",
                                  "Kinderzimmer 2", "Kueche", "Waschkeller", "Schlafzimmer", "Hobbykeller" ]
        
        for name in roomList{
            let room = Room(context: context)
            room.roomName = name
            _ = saveRoom(room: room)
        }
        
        let rooms = CoreDataHandler.fetchAllRooms()
        
        
        // default categories
        let categoryList: [String] = ["keine Kategorie", "Technik", "Moebel", "Computer",
                                         "Schmuck", "Spielzeug", "Fernseher", "Smartphone", "Tablet"]
        
        for name in categoryList{
            let category = Category(context: context)
            category.categoryName = name
            _ = saveCategory(category: category)
        }
        
        let categories = CoreDataHandler.fetchAllCategories()
        
        
        // default owners
        
        let ownerList: [String] = ["keiner", "Marcus", "Sandra", "Emily",
                                      "Vincent"]
        
        for name in ownerList{
            let owner = Owner(context: context)
            owner.ownerName = name
            _ = saveOwner(owner: owner)
        }
        
        let owners = CoreDataHandler.fetchAllOwners()
        
        // default brands
        
        let brandList: [String] = ["sonstige", "IKEA", "Apple", "Sonos",
                                   "Thermomix", "Sony", "Google", "Amazon"]
        
        for name in brandList{
            let brand = Brand(context: context)
            brand.brandName = name
            _ = saveBrand(brand: brand)
        }
        
        let brands = CoreDataHandler.fetchAllBrands()
        
        
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
        
        
        _ = saveInventory(inventoryName: "Weber Grill", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData3! as NSData, invoice: myinvoice, brand: brands[1], category: categories[1], owner: owners[1], room: rooms[1])
        
        _ = saveInventory(inventoryName: "Amazon Echo Spot", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData2! as NSData, invoice: myinvoice, brand: brands[1], category: categories[2], owner: owners[3], room: rooms[2])
        
        _ = saveInventory(inventoryName: "Macbook Pro 13", dateOfPurchase: date, price: 2399, remark: "tolles", serialNumber: "12345", warranty: 36, image: imageData5! as NSData, invoice: myinvoice, brand: brands[2], category: categories[2], owner: owners[3], room: rooms[2])
        
        _ = saveInventory(inventoryName: "Sony 43 Zoll TV", dateOfPurchase: date, price: 999, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData2! as NSData, invoice: myinvoice, brand: brands[2], category: categories[1], owner: owners[3], room: rooms[4])
        
        _ = saveInventory(inventoryName: "Sonos", dateOfPurchase: date, price: 799, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData3! as NSData, invoice: myinvoice, brand: brands[2], category: categories[3], owner: owners[2], room: rooms[3])
        
        _ = saveInventory(inventoryName: "Aquarium", dateOfPurchase: date, price: 300, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData1! as NSData, invoice: myinvoice, brand: brands[1], category: categories[4], owner: owners[1], room: rooms[4])
        
        _ = saveInventory(inventoryName: "Pixel 2XL", dateOfPurchase: date, price: 900, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData2! as NSData, invoice: myinvoice, brand: brands[1], category: categories[5], owner: owners[2], room: rooms[2])
        
        _ = saveInventory(inventoryName: "iPhone X", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData4! as NSData, invoice: myinvoice, brand: brands[1], category: categories[2], owner: owners[2], room: rooms[1])
        
        _ = saveInventory(inventoryName: "Irgendwas", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData4! as NSData, invoice: myinvoice, brand: brands[3], category: categories[2], owner: owners[2], room: rooms[1])
        
        _ = saveInventory(inventoryName: "iPhone 7", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData2! as NSData, invoice: myinvoice, brand: brands[4], category: categories[2], owner: owners[4], room: rooms[1])
        
        _ = saveInventory(inventoryName: "Samsung S7 Edge", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData5! as NSData, invoice: myinvoice, brand: brands[4], category: categories[3], owner: owners[1], room: rooms[3])
        
        _ = saveInventory(inventoryName: "iPhone 7Plus", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData1! as NSData, invoice: myinvoice, brand: brands[4], category: categories[3], owner: owners[4], room: rooms[1])
        
        _ = saveInventory(inventoryName: "Lego Apollo Rakete", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData2! as NSData, invoice: myinvoice, brand: brands[3], category: categories[3], owner: owners[4], room: rooms[1])
        
        _ = saveInventory(inventoryName: "Amazon Echo Spot Emily", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData6! as NSData, invoice: myinvoice, brand: brands[3], category: categories[4], owner: owners[3], room: rooms[2])
        
        _ = saveInventory(inventoryName: "Amazon Echo Spot", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData5! as NSData, invoice: myinvoice, brand: brands[3], category: categories[4], owner: owners[3], room: rooms[4])
        
        _ = saveInventory(inventoryName: "Amazon Echo Spot", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData2! as NSData, invoice: myinvoice, brand: brands[2], category: categories[1], owner: owners[3], room: rooms[2])
        
        _ = saveInventory(inventoryName: "Sony TV 55 Zoll", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData4! as NSData, invoice: myinvoice, brand: brands[2], category: categories[4], owner: owners[2], room: rooms[2])
        
        _ = saveInventory(inventoryName: "Samsung 40 TV", dateOfPurchase: date, price: 1299, remark: "tolles", serialNumber: "442312345", warranty: 24, image: imageData3! as NSData, invoice: myinvoice, brand: brands[2], category: categories[4], owner: owners[2], room: rooms[3])
        
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

