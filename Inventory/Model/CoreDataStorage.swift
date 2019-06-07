/*
 
 Copyright 2019 Marcus Deuß
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

//
//  CoreDataStorage.swift
//  Inventory
//
//  Created by Marcus Deuß on 23.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//


import UIKit
import Foundation
import CoreData

// needed for accessing core data when using app group container
class NSCustomPersistentContainer: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Local.appGroup)
        return storeURL!
    }
    
}

public class CoreDataStorage {
    // MARK: - Core Data stack
    
    // shared enables singleton usage
    static let shared = CoreDataStorage()
    
    init(){
        // init
    }
    
    func deleteDocumentAtUrl(url: URL){
        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil, byAccessor: {
            (urlForModifying) -> Void in
            do {
                try FileManager.default.removeItem(at: urlForModifying)
            }catch let error {
                print("Failed to remove item with error: \(error.localizedDescription)")
            }
        })
    }
    
    lazy var applicationSupportDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named 'Bundle identifier' in the application's Application Support directory.
        let urls = Foundation.FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    
    // access persistent container
    lazy var persistentContainer: NSPersistentContainer =
    {
 
        // Change from NSPersistentContainer to custom class because of app groups
        let container = NSCustomPersistentContainer(name: "Inventory")
        
        let oldStoreUrl = self.applicationSupportDirectory.appendingPathComponent("Inventory.sqlite")
        let directory: NSURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Local.appGroup)! as NSURL
        let newStoreUrl = directory.appendingPathComponent("Inventory.sqlite")!
        
        let psc = container.persistentStoreCoordinator
        
        // need core data migration
        if !FileManager.default.fileExists(atPath: newStoreUrl.path){
            do{
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: oldStoreUrl, options: nil)
                if let store = psc.persistentStore(for: oldStoreUrl){
                    do{
                        //try psc.migratePersistentStore(store, to: newStoreUrl, options: nil, withType: NSSQLiteStoreType)
                        try psc.replacePersistentStore(at: newStoreUrl, destinationOptions: nil, withPersistentStoreFrom: oldStoreUrl, sourceOptions: nil, ofType: NSSQLiteStoreType)
                        
                        try psc.destroyPersistentStore(at: oldStoreUrl, ofType: NSSQLiteStoreType, options: nil)
                        
                        let backupUrl1 = self.applicationSupportDirectory.appendingPathComponent("Inventory.sqlite")
                        let backupUrl2 = self.applicationSupportDirectory.appendingPathComponent("Inventory.sqlite-wal")
                        let backupUrl3 = self.applicationSupportDirectory.appendingPathComponent("Inventory.sqlite-shm")
                        let sourceSqliteURLs = [backupUrl1, backupUrl2, backupUrl3]
                        
                        for index in 0..<sourceSqliteURLs.count {
                            do{
                                try FileManager.default.removeItem(at: sourceSqliteURLs[index])
                            }catch let error {
                                print("Failed to delete file with error: \(error.localizedDescription)")
                            }
                        }
                        
                    }catch let error {
                        print("Failed to migrate store with error: \(error.localizedDescription)")
                    }
                    
                    //container = NSPersistentContainer(name: "Inventory")
 
                }
                
            }
            catch let error {
                print("Failed to add store with error: \(error.localizedDescription)")
            }
        }
      
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
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
    
    
    // convenience method for accessing persistent store container
    // access the container like this:
    // let coreDataContainer = AppDelegate.persistentContainer
    
    // MARK: db context
    // internal: get database context
    func getContext() -> NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    // save everything
    func saveContext(){
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
    func saveRoom(room: Room) -> Room
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
    func fetchRoom(roomName: String) -> Bool{
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
    func fetchRoom(roomName: String) -> Room?{
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
    func fetchRoomIcon(roomName: String) -> Room?{
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
    func deleteRoom(room: Room) -> Bool{
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
    func deleteAllRooms() -> Bool{
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
    func saveCategory(category: Category) -> Category
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
    func fetchCategory(categoryName: String) -> Bool{
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
    func fetchCategory(categoryName: String) -> Category?{
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
    func deleteCategory(category: Category) -> Bool{
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
    func deleteAllCategories() -> Bool{
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
    func saveOwner(owner: Owner) -> Owner
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
    func fetchOwner(ownerName: String) -> Bool{
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
    func fetchOwner(ownerName: String) -> Owner?{
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
    func deleteOwner(owner: Owner) -> Bool{
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
    func deleteAllOwners() -> Bool{
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
    func saveBrand(brand: Brand) -> Brand
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
    func fetchBrand(brandName: String) -> Bool{
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
    func fetchBrand(brandName: String) -> Brand?{
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
    func deleteBrand(brand: Brand) -> Bool{
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
    func deleteAllBrands() -> Bool{
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
    func getInventoryUUID(uuid: UUID) -> Bool{
        
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
    func saveInventory(inventory: Inventory) -> Inventory{
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
    func saveInventory(inventoryName: String, dateOfPurchase: NSDate, price: Int32, remark: String, serialNumber: String, warranty: Int32, image: NSData, invoice: NSData, imageFileName: String, invoiceFileName: String, brand: Brand, category: Category, owner: Owner, room: Room) -> Inventory
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
    func updateInventory(inventory: Inventory) -> Bool{
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
    func deleteInventory(inventory: Inventory) -> Bool{
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
    func fetchAllCategories() -> [Category]
    {
        //os_log("CoreDataHandler fetchAllCategories", log: Log.coredata, type: .info)
        
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
    func fetchAllBrands() -> [Brand]
    {
        //os_log("CoreDataHandler fetchAllBrands", log: Log.coredata, type: .info)
        
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
    func fetchAllOwners() -> [Owner]
    {
        //os_log("CoreDataHandler fetchAllOwners", log: Log.coredata, type: .info)
        
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
    func fetchAllRooms() -> [Room]
    {
        //os_log("CoreDataHandler fetchAllRooms", log: Log.coredata, type: .info)
        
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
    func fetchInventory() -> [Inventory]
    {
        //os_log("CoreDataHandler fetchInventory", log: Log.coredata, type: .info)
        
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
    
    // fetch array, if no array, return nil
    func fetchInventoryWithoutBinaryData() -> [Inventory]
    {
        //os_log("CoreDataHandler fetchInventory", log: Log.coredata, type: .info)
        
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]
        request.fetchBatchSize = 20
        request.propertiesToFetch = ["inventoryName", "price"]
        
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
    func fetchInventoryByRoom(roomName: String) -> [Inventory]
    {
        //os_log("CoreDataHandler fetchInventoryByRoom", log: Log.coredata, type: .info)
        
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        
        // search predicate
        request.predicate = NSPredicate(format: "inventoryRoom.roomName = %@", roomName)
        
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
    // FIXME: must be depening upon system language with switch/case of supported languages, default english
    func generateInitialAppData()
    {
        //os_log("CoreDataHandler generateInitialAppData", log: Log.coredata, type: .info)
        
        let context = getContext()
        
        // general text
        let notDefined = NSLocalizedString("<not defined>", comment: "<not defined>")
        let noCategory = NSLocalizedString("<no category>", comment: "<no category>")
        let noOwner = NSLocalizedString("<nobody>", comment: "<nobody>")
        let noBrand = NSLocalizedString("<other>", comment: "<other>")
        
        // category data
        let tech = NSLocalizedString("Technics", comment: "Technics")
        let furniture = NSLocalizedString("Furniture", comment: "Furniture")
        let computer = NSLocalizedString("Computer", comment: "Computer")
        let juwelry = NSLocalizedString("Juwelry", comment: "Juwelry")
        let toy = NSLocalizedString("Toy", comment: "Toy")
        let tv = NSLocalizedString("TV", comment: "TV")
        let smartphone = NSLocalizedString("Smartphone", comment: "Smartphone")
        let tablet = NSLocalizedString("Tablet", comment: "Tablet")
        let videogame = NSLocalizedString("Video Game", comment: "Video Game")
        
        // room data
        let livingroom = NSLocalizedString("Living room", comment: "Living room")
        let office = NSLocalizedString("Office", comment: "Office")
        let nursery1 = NSLocalizedString("Nursery 1", comment: "Nursery 1")
        let nursery2 = NSLocalizedString("Nursery 2", comment: "Nursery 2")
        let kitchen = NSLocalizedString("Kitchen", comment: "Kitchen")
        let basement1 = NSLocalizedString("Basement 1", comment: "Basement 1")
        let basement2 = NSLocalizedString("Basement 2", comment: "Basement 2")
        let bedroom = NSLocalizedString("Bedroom", comment: "Bedroom")
        
        // room list
        
        let roomList: [String] = [notDefined, livingroom, office, nursery1,
                                  nursery2, kitchen, basement1, bedroom, basement2]
        
        var myRoomImage : UIImage
        for name in roomList{
            let room = Room(context: context)
            room.roomName = name
            
            switch name{
            case livingroom:
                myRoomImage = #imageLiteral(resourceName: "icons8-retro-tv-filled-50")
                break
                
            case bedroom:
                myRoomImage = #imageLiteral(resourceName: "icons8-bett-50")
                break
                
            case office:
                myRoomImage = #imageLiteral(resourceName: "icons8-arbeitsplatz-50")
                break
                
            case basement1, basement2:
                myRoomImage = #imageLiteral(resourceName: "icons8-keller-filled-50")
                break
                
            case kitchen:
                myRoomImage = #imageLiteral(resourceName: "icons8-kochtopf-50")
                break
                
            case nursery1, nursery2:
                myRoomImage = #imageLiteral(resourceName: "icons8-teddy-50")
                break
                
            default:
                myRoomImage = #imageLiteral(resourceName: "icons8-home-filled-50")
                break
            }
            
            //let myImage = #imageLiteral(resourceName: "icons8-home-filled-50")
            let imageData = myRoomImage.jpegData(compressionQuality: 1.0)
            room.roomImage = imageData! as NSData
            _ = saveRoom(room: room)
        }
        
        let rooms = fetchAllRooms()
        
        
        // default categories
        let categoryList: [String] = [noCategory, tech, furniture, computer,
                                      juwelry, toy, tv, smartphone, tablet, videogame]
        
        for name in categoryList{
            let category = Category(context: context)
            category.categoryName = name
            _ = saveCategory(category: category)
        }
        
        let categories = fetchAllCategories()
        
        
        // default owners
        
        let ownerList: [String] = [noOwner, "Mark", "Eva", "Jennifer", "Josef"]
        
        for name in ownerList{
            let owner = Owner(context: context)
            owner.ownerName = name
            _ = saveOwner(owner: owner)
        }
        
        let owners = fetchAllOwners()
        
        // default brands
        
        let brandList: [String] = [noBrand, "IKEA", "Apple", "Sonos",
                                   "Thermomix", "Sony", "Google", "Amazon", "Nintendo", "KitchenAid", "Xiaomi", "Samsung"]
        
        for name in brandList{
            let brand = Brand(context: context)
            brand.brandName = name
            _ = saveBrand(brand: brand)
        }
        
        let brands = fetchAllBrands()
        
        
        let date = Date() as NSDate // today
        let arr : [UInt32] = [32,4,123,4,5,2]
        //let myImage = #imageLiteral(resourceName: "Owner Icon")
        //let myImage2 = #imageLiteral(resourceName: "Category Icon")
        //let myImage3 = #imageLiteral(resourceName: "Camera Icon")
        //let myImage4 = #imageLiteral(resourceName: "Computer Icon")
        //let myImage5 = #imageLiteral(resourceName: "Phone Icon")
        //let myImage6 = #imageLiteral(resourceName: "Room Icon")
        //_ = myImage.jpegData(compressionQuality: 1.0)
        //_ = myImage2.jpegData(compressionQuality: 1.0)
        //let imageData3 = myImage3.jpegData(compressionQuality: 1.0)
        //_ = myImage4.jpegData(compressionQuality: 1.0)
        //_ = myImage5.jpegData(compressionQuality: 1.0)
        //_ = myImage6.jpegData(compressionQuality: 1.0)
        let myinvoice = NSData(bytes: arr, length: arr.count * 32)
        
        //      let invList: [String] = ["Weber Grill", "Macbook Pro", "Amazon Echo Spot", "Sony TV",
        //                                 "Samsung TV", "Thermomix", "Apple TV 4K", "Apple TV HD"]
        
        let imageSpeaker = UIImage(named: "Speaker")
        let imageSpeakerData = imageSpeaker?.jpegData(compressionQuality: 1.0)
        let imageThermo = UIImage(named: "Thermo")
        let imageThermoData = imageThermo?.jpegData(compressionQuality: 1.0)
        let imageKitchen = UIImage(named: "Kitchen")
        let imageKitchenData = imageKitchen?.jpegData(compressionQuality: 1.0)
        let imageToaster = UIImage(named: "Toaster")
        let imageToasterData = imageToaster?.jpegData(compressionQuality: 1.0)
        let imageGame = UIImage(named: "Game")
        let imageGameData = imageGame?.jpegData(compressionQuality: 1.0)
        //let imageKitchenData = imageKitchen.jpegData(compressionQuality: 1.0)
        //let invList: [String] = ["Weber Grill", "Macbook Pro", "Amazon Echo Spot", "Sony TV",
        //                          "Samsung TV", "Thermomix", "Apple TV 4K", "Apple TV HD"]
        
        // generate sample data randomly
        
        /*
         for i in 1..<6{
         let remark = "Remark " + String(Int.random(in: 1...100))
         let serial = "S. no. " + String(Int.random(in: 1...100)) + "N" + String(Int.random(in: 1...100)) + "Z" + String(Int.random(in: 1...100))
         
         let invId = Int.random(in: 0 ..< invList.count)
         let brandId = Int.random(in: 0 ..< brandList.count)
         let catId = Int.random(in: 0 ..< categoryList.count)
         let ownerId = Int.random(in: 0 ..< ownerList.count)
         let roomId = Int.random(in: 0 ..< roomList.count)
         
         _ = saveInventory(inventoryName: invList[invId], dateOfPurchase: date, price: Int32(i*5), remark: remark, serialNumber: serial, warranty: 6, image: imageData3! as NSData, invoice: myinvoice, imageFileName: "", invoiceFileName: "", brand: brands[brandId], category: categories[catId], owner: owners[ownerId], room: rooms[roomId])
         }
         */
        
        let remark = NSLocalizedString("Remark", comment: "Remark") + " " + String(Int.random(in: 1...100))
        let serial = NSLocalizedString("Serial no.", comment: "Serial no.") + " " + String(Int.random(in: 1...100)) + "N" + String(Int.random(in: 1...100)) + "Z" + String(Int.random(in: 1...100))
        
        _ = saveInventory(inventoryName: NSLocalizedString("Kitchen Helper", comment: "Kitchen Helper"), dateOfPurchase: date, price: Int32(699), remark: remark, serialNumber: serial, warranty: 12, image: imageKitchenData! as NSData, invoice: myinvoice, imageFileName: "", invoiceFileName: "", brand: brands[5], category: categories[8], owner: owners[2], room: rooms[6])
        
        _ = saveInventory(inventoryName: NSLocalizedString("Toaster", comment: "Toaster"), dateOfPurchase: date, price: Int32(200), remark: remark, serialNumber: serial, warranty: 12, image: imageToasterData! as NSData, invoice: myinvoice, imageFileName: "", invoiceFileName: "", brand: brands[5], category: categories[8], owner: owners[2], room: rooms[6])
        
        _ = saveInventory(inventoryName: NSLocalizedString("Game", comment: "Game"), dateOfPurchase: date, price: Int32(35), remark: remark, serialNumber: serial, warranty: 12, image: imageGameData! as NSData, invoice: myinvoice, imageFileName: "", invoiceFileName: "", brand: brands[0], category: categories[9], owner: owners[1], room: rooms[2])
        
        _ = saveInventory(inventoryName: NSLocalizedString("Wizzard", comment: "Wizzard"), dateOfPurchase: date, price: Int32(1190), remark: remark, serialNumber: serial, warranty: 24, image: imageThermoData! as NSData, invoice: myinvoice, imageFileName: "", invoiceFileName: "", brand: brands[10], category: categories[8], owner: owners[2], room: rooms[6])
        
        _ = saveInventory(inventoryName: NSLocalizedString("Speaker", comment: "Speaker"), dateOfPurchase: date, price: Int32(199), remark: remark, serialNumber: serial, warranty: 24, image: imageSpeakerData! as NSData, invoice: myinvoice, imageFileName: "", invoiceFileName: "", brand: brands[8], category: categories[8], owner: owners[3], room: rooms[2])
        
        
        
        // FIXME: must be removed for release
        //CoreDataStorage.showSampleData()
    }
    
    // just for testing and debugging, will not be used in final app
    func showSampleData()
    {
        //os_log("CoreDataHandler showSampleData", log: Log.coredata, type: .info)
        
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
        
        let livingroom = NSLocalizedString("Living room", comment: "Living room")
        
        let invWohn = fetchInventoryByRoom(roomName: livingroom)
        print ("count: items in living room: \(invWohn.count)")
    }
    
}

