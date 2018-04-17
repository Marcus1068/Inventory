//
//  AppDelegate.swift
//  Inventory
//
//  Created by Marcus Deuß on 17.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import CoreData
import os.log
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // insert some sample data in case the Core Data has not been filled with contents
        //let request : NSFetchRequest<Vokabel> = Vokabel.fetchRequest()
        // sort criteria
        //request.sortDescriptors = [NSSortDescriptor(key: "deutsch", ascending: true)]
        
        //vokabeln = try! AppDelegate.viewContext.fetch(request)
        generateSampleData()
        
        let inventory = fetchInventory()
        if (inventory.count == 0)
        {
            generateSampleData()
        }
        
        // for debug only
        showSampleData()
        
        return true
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Core Data stack
    
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
    
    // convenience method for accessing persistent store container
    // access the container like this:
    // let coreDataContainer = AppDelegate.persistentContainer
    static var persistentContainer: NSPersistentContainer
    {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    // convenience method for accessing view context
    // usage: let context = AppDelegate.viewContext
    
    static var viewContext: NSManagedObjectContext
    {
        return persistentContainer.viewContext
    }
    
    
    // MARK: - Core Data Saving support
    
    func saveContext()
    {
        let context = AppDelegate.viewContext
        
        if context.hasChanges
        {
            do
            {
                try context.save()
            }
            catch
            {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // generate sample data for initial work
    func generateSampleData()
    {
        os_log("generateSampleData", log: OSLog.default, type: .debug)
        
        // default categories
        
        let kategorie0 = saveCategory(categoryName: "keine Kategorie")
        let kategorie1 = saveCategory(categoryName: "Technik")
        let kategorie2 = saveCategory(categoryName: "Möbel")
        let kategorie3 = saveCategory(categoryName: "Computer")
        let kategorie4 = saveCategory(categoryName: "Schmuck")
        let kategorie5 = saveCategory(categoryName: "Spielzeug")
        let kategorie6 = saveCategory(categoryName: "Fernseher")
        let kategorie7 = saveCategory(categoryName: "Smartphone")
        let kategorie8 = saveCategory(categoryName: "Tablet")
        
        // default owners
        
        let person0 = saveOwner(ownerName: "kein Besitzer")
        let person1 = saveOwner(ownerName: "Marcus")
        let person2 = saveOwner(ownerName: "Sandra")
        let person3 = saveOwner(ownerName: "Emily")
        let person4 = saveOwner(ownerName: "Vincent")
        let person5 = saveOwner(ownerName: "Opa Bremen")
        
        // default brands
        
        let brand0 = saveBrand(brandName: "sonstige")
        let brand1 = saveBrand(brandName: "IKEA")
        let brand2 = saveBrand(brandName: "Apple")
        let brand3 = saveBrand(brandName: "Sonos")
        let brand4 = saveBrand(brandName: "Thermomix")
        let brand5 = saveBrand(brandName: "Sony")
        let brand6 = saveBrand(brandName: "Google")
        
        // default rooms
        let raum0 = saveRoom(roomName: "nicht definiert")
        let raum1 = saveRoom(roomName: "Wohnzimmer")
        let raum2 = saveRoom(roomName: "Büro")
        let raum3 = saveRoom(roomName: "Kinderzimmer 1")
        let raum4 = saveRoom(roomName: "Kinderzimmer 2")
        let raum5 = saveRoom(roomName: "Küche")
        let raum6 = saveRoom(roomName: "Arbeitskeller")
        let raum7 = saveRoom(roomName: "Schlafzimmer")
        let raum8 = saveRoom(roomName: "Hobbykeller")
        
        let date = Date() as NSDate // today
        let image = NSData();   // FIXME stupid sample data
        let invoice = NSData();
        
        saveInventory(inventoryName: "Macbook Pro 13", dateOfPurchase: date, price: 2399, remark: "tolles Gerät", serialNumber: "12345", warranty: 36, image: image, invoice: invoice, brand: brand1, category: kategorie3, owner: person1, room: raum1)
        saveInventory(inventoryName: "Sony 43 Zoll TV", dateOfPurchase: date, price: 999, remark: "tolles Gerät", serialNumber: "442312345", warranty: 24, image: image, invoice: invoice, brand: brand5, category: kategorie6, owner: person2, room: raum3)
        saveInventory(inventoryName: "Sonos Playbar", dateOfPurchase: date, price: 799, remark: "Gerät", serialNumber: "442312345", warranty: 24, image: image, invoice: invoice, brand: brand3, category: kategorie1, owner: person2, room: raum3)
        saveInventory(inventoryName: "Aquarium", dateOfPurchase: date, price: 300, remark: "Gerät", serialNumber: "442312345", warranty: 24, image: image, invoice: invoice, brand: brand0, category: kategorie2, owner: person3, room: raum1)
        saveInventory(inventoryName: "Pixel 2XL", dateOfPurchase: date, price: 900, remark: "Gerät", serialNumber: "442312345", warranty: 24, image: image, invoice: invoice, brand: brand6, category: kategorie7, owner: person1, room: raum1)
        saveInventory(inventoryName: "iPhone X", dateOfPurchase: date, price: 1299, remark: "Gerät", serialNumber: "442312345", warranty: 24, image: image, invoice: invoice, brand: brand2, category: kategorie7, owner: person1, room: raum4)
        saveInventory(inventoryName: "Irgendwas", dateOfPurchase: date, price: 1299, remark: "Gerät", serialNumber: "442312345", warranty: 24, image: image, invoice: invoice, brand: brand4, category: kategorie4, owner: person1, room: raum0)
        saveInventory(inventoryName: "Weber Grill", dateOfPurchase: date, price: 1299, remark: "Gerät", serialNumber: "442312345", warranty: 24, image: image, invoice: invoice, brand: brand0, category: kategorie5, owner: person1, room: raum2)
        saveInventory(inventoryName: "iPhone 7", dateOfPurchase: date, price: 1299, remark: "Gerät", serialNumber: "442312345", warranty: 24, image: image, invoice: invoice, brand: brand0, category: kategorie8, owner: person4, room: raum5)
        saveInventory(inventoryName: "Samsung S7 Edge", dateOfPurchase: date, price: 1299, remark: "Gerät", serialNumber: "442312345", warranty: 24, image: image, invoice: invoice, brand: brand0, category: kategorie0, owner: person0, room: raum6)
        saveInventory(inventoryName: "iPhone 7Plus", dateOfPurchase: date, price: 1299, remark: "Gerät", serialNumber: "442312345", warranty: 24, image: image, invoice: invoice, brand: brand0, category: kategorie8, owner: person5, room: raum7)
        saveInventory(inventoryName: "Lego Apollo Rakete", dateOfPurchase: date, price: 1299, remark: "Gerät", serialNumber: "442312345", warranty: 24, image: image, invoice: invoice, brand: brand0, category: kategorie8, owner: person4, room: raum8)
        
    }
    
    // just for testing and debugging, will not be used in final app
    func showSampleData()
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
            print("Inventory = \(i.inventoryName!), Raum: \(i.inventoryRoom?.roomName!)), Kategorie: \(i.inventoryCategory?.categoryName!)) , Besitzer: \(i.inventoryOwner?.ownerName), Marke: \(i.inventoryBrand?.brandName) ")
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
    
    
    // Save a room
    func saveRoom(roomName: String) -> Room
    {
        os_log("saveRoom in AppDelegate", log: OSLog.default, type: .debug)
        
        let context = AppDelegate.viewContext
        let room = Room(context: context)
        
        room.roomName = roomName
        
        saveContext()
        
        return room
        
    }
    
    // Save a category
    func saveCategory(categoryName: String) -> Category
    {
        os_log("saveCategory in AppDelegate", log: OSLog.default, type: .debug)
        
        let context = AppDelegate.viewContext
        let category = Category(context: context)
        
        category.categoryName = categoryName
        
        saveContext()
        
        return category
    }
    
    // Save an owner
    func saveOwner(ownerName: String) -> Owner
    {
        os_log("saveOwner in AppDelegate", log: OSLog.default, type: .debug)
        
        let context = AppDelegate.viewContext
        let owner = Owner(context: context)
        
        owner.ownerName = ownerName
        
        saveContext()
        
        return owner
    }
    
    // Save a Brand
    func saveBrand(brandName: String) -> Brand
    {
        os_log("saveBrand in AppDelegate", log: OSLog.default, type: .debug)
        
        let context = AppDelegate.viewContext
        let brand = Brand(context: context)
        
        brand.brandName = brandName
        
        saveContext()
        
        return brand
    }
    
    // add a single row to Vokabel table
    func saveInventory(inventoryName: String, dateOfPurchase: NSDate, price: Int32, remark: String, serialNumber: String, warranty: Int32, image: NSData, invoice: NSData, brand: Brand, category: Category, owner: Owner, room: Room)
    {
        os_log("saveInventory in AppDelegate", log: OSLog.default, type: .debug)
        
        let context = AppDelegate.viewContext
        
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
        inventory.timeStamp = Date() as NSDate?
    
        // save data
        saveContext()
    }
    
    // fetch all category array, otherwise return [] empty array
    func fetchAllCategories() -> [Category]
    {
        os_log("fetchAllCategories", log: OSLog.default, type: .debug)
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        //let yesterday = Date(timeIntervalSinceNow: -24*60*60) as NSDate
        
        // search predicate
        // request.predicate = NSPredicate(format: "any vokabeln.created > %@", yesterday)
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "categoryName", ascending: true)]
        
        let context = AppDelegate.viewContext
        
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
        os_log("fetchAllBrands", log: OSLog.default, type: .debug)
        
        let request : NSFetchRequest<Brand> = Brand.fetchRequest()
        
        //let yesterday = Date(timeIntervalSinceNow: -24*60*60) as NSDate
        
        // search predicate
        // request.predicate = NSPredicate(format: "any vokabeln.created > %@", yesterday)
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "brandName", ascending: true)]
        
        let context = AppDelegate.viewContext
        
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
        os_log("fetchAllOwners", log: OSLog.default, type: .debug)
        
        let request : NSFetchRequest<Owner> = Owner.fetchRequest()
        
        //let yesterday = Date(timeIntervalSinceNow: -24*60*60) as NSDate
        
        // search predicate
        // request.predicate = NSPredicate(format: "any vokabeln.created > %@", yesterday)
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "ownerName", ascending: true)]
        
        let context = AppDelegate.viewContext
        
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
        os_log("fetchAllRooms", log: OSLog.default, type: .debug)
        
        let request : NSFetchRequest<Room> = Room.fetchRequest()
        
        //let yesterday = Date(timeIntervalSinceNow: -24*60*60) as NSDate
        
        // search predicate
        // request.predicate = NSPredicate(format: "any vokabeln.created > %@", yesterday)
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "roomName", ascending: true)]
        
        let context = AppDelegate.viewContext
        
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
        os_log("fetchInventory in AppDelegate", log: OSLog.default, type: .debug)
        
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        
        //var vokabeln : [Vokabel] = []
        
        //let yesterday = Date(timeIntervalSinceNow: -24*60*60) as NSDate
        
        // search predicate
        // request.predicate = NSPredicate(format: "any vokabeln.created > %@", yesterday)
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]
        
        let context = AppDelegate.viewContext
        
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
    func fetchInventoryByRoom(roomName: String) -> [Inventory]
    {
        os_log("fetchInventoryByRoom", log: OSLog.default, type: .debug)
        
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        
        //let yesterday = Date(timeIntervalSinceNow: -24*60*60) as NSDate
        
        // search predicate
        request.predicate = NSPredicate(format: "inventoryRoom.roomName = %@", roomName)    // FIXME, migth crash
        
        // sort criteria
        request.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]
        
        let context = AppDelegate.viewContext
        
        do {
            let inventory = try context.fetch(request)
            
            return inventory
            
        } catch {
            print("Error with fetch request in fetchInventoryByRoom \(error)")
        }
        
        return []
    }

    
    // sending a local notification
    
    func sendLocalNotification(title: String, subtitle: String, body: String, badge: NSNumber) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = badge
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                        repeats: false)
        
        let requestIdentifier = "demoNotification"
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request,
                                               withCompletionHandler: { (error) in
                                                // Handle error
        })
    }

}

