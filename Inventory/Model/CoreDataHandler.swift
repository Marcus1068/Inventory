//
//  CoreDataHandler.swift
//  Inventory
//
//  Created by Marcus Deuß on 23.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import CoreData
import os

class CoreDataHandler: NSObject {
    
    
    // MARK: db context
    // internal: get database context
    class func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    class func persistentContainer() -> NSPersistentContainer
    {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    // save everything
    class func saveContext(){
        let context = getContext()
        
        do {
            try context.save()
            
        } catch  {
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: room stuff
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
    
    // check if room already exists
    class func fetchRoom(roomName: String) -> Room?{
        let context = getContext()
        
        let request : NSFetchRequest<Room> = Room.fetchRequest()
        request.fetchLimit = 1
        
        // search predicate
        request.predicate = NSPredicate(format: "roomName = %@", roomName)
        
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return result.first
            }
        } catch {
            print("Error with fetch request in fetchRoom \(error)")
        }
        return nil
    }
    
    // fetch room icon
    class func fetchRoomIcon(roomName: String) -> Room?{
        let context = getContext()
        
        let request : NSFetchRequest<Room> = Room.fetchRequest()
        // search predicate
        request.predicate = NSPredicate(format: "roomName = %@", roomName)
        
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                // FI)XME hack!!!
                return result[0]
            }
        } catch {
            print("Error with fetch request in fetchRoom \(error)")
        }
        
        return nil
        
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
    
    // MARK: category stuff
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
    
    // check if category already exists
    class func fetchCategory(categoryName: String) -> Category?{
        let context = getContext()
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        request.fetchLimit = 1
        
        // search predicate
        request.predicate = NSPredicate(format: "categoryName = %@", categoryName)
        
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return result.first
            }
        } catch {
            print("Error with fetch request in fetchCategory \(error)")
        }
        
        return nil
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
    
    // MARK: owner stuff
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
    
    // check if owner already exists
    class func fetchOwner(ownerName: String) -> Owner?{
        let context = getContext()
        
        let request : NSFetchRequest<Owner> = Owner.fetchRequest()
        request.fetchLimit = 1
        
        // search predicate
        request.predicate = NSPredicate(format: "ownerName = %@", ownerName)
        
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return result.first
            }
        } catch {
            print("Error with fetch request in fetchOwner \(error)")
        }
        
        return nil
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
    
    // MARK: brand stuff
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
    
    // check if brand already exists
    class func fetchBrand(brandName: String) -> Brand?{
        let context = getContext()
        
        let request : NSFetchRequest<Brand> = Brand.fetchRequest()
        request.fetchLimit = 1
        
        // search predicate
        request.predicate = NSPredicate(format: "brandName = %@", brandName)
        
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return result.first
            }
        } catch {
            print("Error with fetch request in fetchBrand \(error)")
        }
        
        return nil
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
    
    // MARK: inventory stuff
    
    // fetch UUID from inventory, found = true
    class func getInventoryUUID(uuid: UUID) -> Bool{
        
        let context = getContext()
        
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        request.fetchLimit = 1
        
        // search predicate
        request.predicate = NSPredicate(format: "id = %@", uuid as CVarArg)
        
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return true
            }
        } catch {
            print("Error with fetch request in getInventoryUUID \(error)")
        }
        
        return false
    }
    
    // add a single row to inventory table
    class func saveInventory(inventory: Inventory) -> Inventory{
        let context = getContext()
        // save data
        do {
            try context.save()
            return inventory
        } catch  {
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // add a single row to inventory table
    class func saveInventory(inventoryName: String, dateOfPurchase: NSDate, price: Int32, remark: String, serialNumber: String, warranty: Int32, image: NSData, invoice: NSData, imageFileName: String, invoiceFileName: String, brand: Brand, category: Category, owner: Owner, room: Room) -> Inventory
    {
        let context = getContext()
        
        let inventory = Inventory(context: context)
        
        // set object with IU values
        inventory.id = UUID()
        inventory.inventoryName = inventoryName
        inventory.dateOfPurchase = dateOfPurchase
        inventory.price = price
        inventory.remark = remark
        inventory.serialNumber = serialNumber
        inventory.warranty = warranty
        inventory.image = image;
        inventory.imageFileName = imageFileName
        inventory.invoice = invoice;
        inventory.invoiceFileName = invoiceFileName
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
    
    // update inventory object
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
    
    // delete inventory object
    class func deleteInventory(inventory: Inventory) -> Bool{
        let context = getContext()
        
        context.delete(inventory)
        
        do {
            try context.save()
            return true
        } catch  {
            return false
        }
    }
    
    // MARK: fetch ALL stuff
    // fetch all category array, otherwise return [] empty array
    class func fetchAllCategories() -> [Category]
    {
        os_log("CoreDataHandler fetchAllCategories", log: Log.coredata, type: .info)
        
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
        os_log("CoreDataHandler fetchAllBrands", log: Log.coredata, type: .info)
        
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
        os_log("CoreDataHandler fetchAllOwners", log: Log.coredata, type: .info)
        
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
        os_log("CoreDataHandler fetchAllRooms", log: Log.coredata, type: .info)
        
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
        os_log("CoreDataHandler fetchInventory", log: Log.coredata, type: .info)
        
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]
        request.fetchBatchSize = 20
        
        let context = getContext()
        
        do {
            let inventory = try context.fetch(request)
            
            return inventory
            
        } catch {
            print("Error with fetch request in fetchInventory \(error)")
        }
        
        return []
    }
    
    
    // fetch all inventory from a certain room array, otherwise return [] empty array
    class func fetchInventoryByRoom(roomName: String) -> [Inventory]
    {
        os_log("CoreDataHandler fetchInventoryByRoom", log: Log.coredata, type: .info)
        
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        
        // search predicate
        request.predicate = NSPredicate(format: "inventoryRoom.roomName = %@", roomName)    // FIXME, migth crash
        
        //print(request.predicate.debugDescription)
        
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
    
    // MARK: generate sample data
    
    // generate sample data for initial work
    // FIXME must be depening upon system language with switch/case of supported languages, default english
    class func generateSampleData()
    {
        os_log("CoreDataHandler generateSampleData", log: Log.coredata, type: .info)
        
        let context = getContext()
        
        let notDefined = NSLocalizedString("<not defined>", comment: "<not defined>")
        let noCategory = NSLocalizedString("<no category>", comment: "<no category>")
        let noOwner = NSLocalizedString("<nobody>", comment: "<nobody>")
        let noBrand = NSLocalizedString("<other>", comment: "<other>")
        
        let tech = NSLocalizedString("Technics", comment: "Technics")
        let furniture = NSLocalizedString("Furniture", comment: "Furniture")
        let computer = NSLocalizedString("Computer", comment: "Computer")
        let juwelry = NSLocalizedString("Juwelry", comment: "Juwelry")
        let toy = NSLocalizedString("Toy", comment: "Toy")
        let tv = NSLocalizedString("TV", comment: "TV")
        let smartphone = NSLocalizedString("Smartphone", comment: "Smartphone")
        let tablet = NSLocalizedString("Tablet", comment: "Tablet")
        let videogame = NSLocalizedString("Video Game", comment: "Video Game")
        
        let livingroom = NSLocalizedString("Living room", comment: "Living room")
        let office = NSLocalizedString("Office", comment: "Office")
        let nursery1 = NSLocalizedString("Nursery 1", comment: "Nursery 1")
        let nursery2 = NSLocalizedString("Nursery 2", comment: "Nursery 2")
        let kitchen = NSLocalizedString("Kitchen", comment: "Kitchen")
        let basement1 = NSLocalizedString("Basement 1", comment: "Basement 1")
        let basement2 = NSLocalizedString("Basement 2", comment: "Basement 2")
        let bedroom = NSLocalizedString("Bedroom", comment: "Bedroom")
        
        // german room list default data
        
        let roomList: [String] = [notDefined, livingroom, office, nursery1,
                                  nursery2, kitchen, basement1, bedroom, basement2]
        
        for name in roomList{
            let room = Room(context: context)
            room.roomName = name
            let myImage = #imageLiteral(resourceName: "icons8-home-filled-50")
            let imageData = myImage.jpegData(compressionQuality: 1.0)
            room.roomImage = imageData! as NSData
            _ = saveRoom(room: room)
        }
        
        let rooms = CoreDataHandler.fetchAllRooms()
        
        
        // default categories
        let categoryList: [String] = [noCategory, tech, furniture, computer,
                                         juwelry, toy, tv, smartphone, tablet, videogame]
        
        for name in categoryList{
            let category = Category(context: context)
            category.categoryName = name
            _ = saveCategory(category: category)
        }
        
        let categories = CoreDataHandler.fetchAllCategories()
        
        
        // default owners
        
        let ownerList: [String] = [noOwner, "Mark", "Eva", "Jane", "Johann"]
        
        for name in ownerList{
            let owner = Owner(context: context)
            owner.ownerName = name
            _ = saveOwner(owner: owner)
        }
        
        let owners = CoreDataHandler.fetchAllOwners()
        
        // default brands
        
        let brandList: [String] = [noBrand, "IKEA", "Apple", "Sonos",
                                   "Thermomix", "Sony", "Google", "Amazon", "Nintendo"]
        
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
        _ = myImage.jpegData(compressionQuality: 1.0)
        _ = myImage2.jpegData(compressionQuality: 1.0)
        let imageData3 = myImage3.jpegData(compressionQuality: 1.0)
        _ = myImage4.jpegData(compressionQuality: 1.0)
        _ = myImage5.jpegData(compressionQuality: 1.0)
        _ = myImage6.jpegData(compressionQuality: 1.0)
        let myinvoice = NSData(bytes: arr, length: arr.count * 32)
        
        let invList: [String] = ["Weber Grill", "Macbook Pro", "Amazon Echo Spot", "Sony TV",
                                   "Samsung TV", "Thermomix", "Apple TV 4K", "Apple TV HD"]
        
        // generate sample data randomly
        for i in 1..<30{
            let remark = "Remark " + String(i)
            let serial = "S. no. " + String(i) + "N" + String(i*3) + "Z" + String(i+7)
            
            let invId = Int.random(in: 0 ..< invList.count)
            let brandId = Int.random(in: 0 ..< brandList.count)
            let catId = Int.random(in: 0 ..< categoryList.count)
            let ownerId = Int.random(in: 0 ..< ownerList.count)
            let roomId = Int.random(in: 0 ..< roomList.count)
            
            _ = saveInventory(inventoryName: invList[invId], dateOfPurchase: date, price: Int32(i*5), remark: remark, serialNumber: serial, warranty: 6, image: imageData3! as NSData, invoice: myinvoice, imageFileName: "", invoiceFileName: "", brand: brands[brandId], category: categories[catId], owner: owners[ownerId], room: rooms[roomId])
        }
        
        // FIXME must be removed for release
        CoreDataHandler.showSampleData()
    }
    
    // just for testing and debugging, will not be used in final app
    class func showSampleData()
    {
        os_log("CoreDataHandler showSampleData", log: Log.coredata, type: .info)
        
        let inventory = fetchInventory()
        
        let rooms = fetchAllRooms()
        print ("count rooms:\(rooms.count)")
        let categories = fetchAllCategories()
        print ("count categories:\(categories.count)")
        let owners = fetchAllOwners()
        print ("count owners:\(owners.count)")
        let brands = fetchAllBrands()
        print ("count brands:\(brands.count)")
        
        for i in inventory{
            print("Inventory = \(i.inventoryName!), Room: \(String(describing: i.inventoryRoom?.roomName))), Category: \(String(describing: i.inventoryCategory?.categoryName))) , Owner: \(String(describing: i.inventoryOwner?.ownerName)), Brand: \(String(describing: i.inventoryBrand?.brandName)) ")
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
        
        let invWohn = fetchInventoryByRoom(roomName: "Living room")
        print ("count items in living room: \(invWohn.count)")
    }
    
}

