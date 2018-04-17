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
        let inventory = fetchInventories()
        if (inventory.count == 0)
        {
            saveSampleData()
        }
        
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
            let container = NSPersistentContainer(name: "InventoryContainer")
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
    func saveSampleData()
    {
        os_log("saveSampleData in AppDelegate", log: OSLog.default, type: .debug)
        /*
        // sample words
        saveVokabel(deutsch: "Haus", englisch: "house", latein: "latein_bla", grossklein: false)
        saveVokabel(deutsch: "Auto", englisch: "car", latein: "latein_bla", grossklein: false)
        saveVokabel(deutsch: "Ich bin", englisch: "I am", latein: "latein_bla", grossklein: true)
        saveVokabel(deutsch: "Wir sind", englisch: "we are", latein: "latein_bla", grossklein: false)
        saveVokabel(deutsch: "Dach", englisch: "roof", latein: "latein_bla", grossklein: false)
        saveVokabel(deutsch: "Gurke", englisch: "cucumber", latein: "latein_bla", grossklein: false)
        saveVokabel(deutsch: "Pfeffer", englisch: "pepper", latein: "latein_bla", grossklein: false)
        saveVokabel(deutsch: "Salz", englisch: "salt", latein: "latein_bla", grossklein: false)
        saveVokabel(deutsch: "Suppe", englisch: "soup", latein: "latein_bla", grossklein: false)
        saveVokabel(deutsch: "Maus", englisch: "mouse", latein: "latein_bla", grossklein: false)
        saveVokabel(deutsch: "Küche", englisch: "kitchen", latein: "latein_bla", grossklein: false)
        
        
        let date = Date() // today
        let yesterday = Date(timeIntervalSinceNow: -24*60*60)
        let yesterday2 = Date(timeIntervalSinceNow: -48*60*60)
        //let calendar = NSCalendar.current
        //let hour = calendar.component(.hour, from: date as Date)
        //let minutes = calendar.component(.minute, from: date as Date)
        // sample excercises
        //let date = now()
        
        saveLerneinheit(richtig: 10, falsch: 1, dauer: 20, datum: date)
        saveLerneinheit(richtig: 12, falsch: 0, dauer: 24, datum: yesterday)
        saveLerneinheit(richtig: 8, falsch: 2, dauer: 18, datum: yesterday2)
        */
        
    }
    
    // Save a room
    func saveRoom(name: String)
    {
        os_log("saveRoom in AppDelegate", log: OSLog.default, type: .debug)
        
        let context = AppDelegate.viewContext
        let room = Room(context: context)
        
        room.roomName = name
        
        saveContext()
        
    }
    
    // Save a category
    func saveCategory(name: String)
    {
        os_log("saveCategory in AppDelegate", log: OSLog.default, type: .debug)
        
        let context = AppDelegate.viewContext
        let category = Category(context: context)
        
        category.categoryName = name
        
        saveContext()
        
    }
    
    // Save an owner
    func saveOwner(name: String)
    {
        os_log("saveOwner in AppDelegate", log: OSLog.default, type: .debug)
        
        let context = AppDelegate.viewContext
        let owner = Owner(context: context)
        
        owner.ownerName = name
        
        saveContext()
        
    }
    
    // Save a Brand
    func saveBrand(name: String)
    {
        os_log("saveBrand in AppDelegate", log: OSLog.default, type: .debug)
        
        let context = AppDelegate.viewContext
        let brand = Brand(context: context)
        
        brand.brandName = name
        
        saveContext()
        
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
    func fetchInventories() -> [Inventory]
    {
        os_log("fetchInventories in AppDelegate", log: OSLog.default, type: .debug)
        
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
            print("Error with fetch request in Vokabel \(error)")
        }
        
        //print(vokabeln?.count)
        
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

