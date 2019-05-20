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
//  AppDelegate.swift
//  Inventory
//
//  Created by Marcus Deuß on 17.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import CoreData
import os
import AVFoundation

// define global variables that are available throughout the app
let themeColor = UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0) // kind of dark green
let themeColorUIControls = UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0) // kind of dark green
let themeColorText = UIColor.blue

// here starts everything
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let kvStore = NSUbiquitousKeyValueStore()

    enum ShortcutIdentifier: String {
        case OpenShare
        case OpenReport
        case OpenImportExport
        
        init?(fullIdentifier: String) {
            guard let shortIdentifier = fullIdentifier.components(separatedBy: ".").last else {
                return nil
            }
            self.init(rawValue: shortIdentifier)
        }
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Do any additional setup after loading the view.
        let myInventory = CoreDataHandler.fetchInventory()
        
        // generate initial data if none available
        if (myInventory.count == 0){
            let rooms = CoreDataHandler.fetchAllRooms()
            let categories = CoreDataHandler.fetchAllCategories()
            let owners = CoreDataHandler.fetchAllOwners()
            let brands = CoreDataHandler.fetchAllBrands()
            
            // only generate data if complete data is gone
            if rooms.count == 0 && categories.count == 0 && owners.count == 0 && brands.count == 0{
                CoreDataHandler.generateInitialAppData()
            }
        }
        
        // manage large title appearance for all view controllers centrally
        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.blue,
             NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 30) ??    // Arial
                UIFont.systemFont(ofSize: 30)]
        
        // influences text color
        //window?.tintColor = themeColor
        
        
        // get user directory mainly for debugging purposes
        //let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        //os_log("app directory is: %s", log: Log.appdelegate, type: .info, urls.description)
        
        // change UI Tab bar font
        //UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 10)!], for: .normal)
        //UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 10)!], for: .selected)
        
        // get user name and address from iCloud
        getiCloudStorageInfo()
        
        // handle short cut
        if let shortcutItem =
            launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem]
                as? UIApplicationShortcutItem {
            
            let _ = handleShortcut(shortcutItem: shortcutItem)
            return false
        }
        
        return true
    }

    // perform 3D touch icon short cuts
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem: shortcutItem))
    }
    
    private func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        let shortcutType = shortcutItem.type
        guard let shortcutIdentifier = ShortcutIdentifier(fullIdentifier: shortcutType) else {
            return false
        }
        return selectTabBarItemForIdentifier(shortcutIdentifier)
    }
    
    fileprivate func selectTabBarItemForIdentifier(_ identifier: ShortcutIdentifier) -> Bool {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return false
        }
        //print(identifier as Any)
        switch (identifier) {
        case .OpenShare:
            self.shareAppLink()
            //tabBarController.selectedIndex = 1
            // https://itunes.apple.com/us/app/inventory-app/id1386694734?l=de&ls=1&mt=8
            // URL(string: "itms-apps://itunes.apple.com/app/" + "id1386694734")
            
            return true
            
        case .OpenReport:
            tabBarController.selectedIndex = 3
            return true
            
        case .OpenImportExport:
            tabBarController.selectedIndex = 2
            return true
            
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        CoreDataHandler.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        // get latest icloud user data when app starts
        NSUbiquitousKeyValueStore().synchronize()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        CoreDataHandler.saveContext()
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
                    os_log("persistentContainer: %s", log: Log.appdelegate, type: .error, error.userInfo)
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
    
    static var viewContext: NSManagedObjectContext
    {
        return persistentContainer.viewContext
    }
    
    // get user name and address from icloud storage
    func getiCloudStorageInfo(){
        //os_log("AppDelegate getiCloudStorageInfo", log: Log.appdelegate, type: .info)
        
        if let user = kvStore.string(forKey: Global.keyUserName),
            let address = kvStore.string(forKey: Global.keyHouseName){
            UserInfo.userName = user
            UserInfo.addressName = address
        }
    }
}

// find out what device size we have
extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone5: Bool {
        return UIScreen.main.nativeBounds.height == 1136
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR = "iPhone XR"
        case iPhone_XSMax = "iPhone XS Max"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhones_4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax
        default:
            return .unknown
        }
    }
}

extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var rootViewController: UITabBarController {
        return window!.rootViewController as! UITabBarController
    }
    
    func shareAppLink() {
        
        // https://itunes.apple.com/us/app/inventory-app/id1386694734?l=de&ls=1&mt=8
        // URL(string: "itms-apps://itunes.apple.com/app/" + "id1386694734")
        let url = URL(string: "https://itunes.apple.com/de/app/inventory-app/id1386694734?l=de&ls=1&mt=8")
        
        let shareItems:Array = [url]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems as [Any], applicationActivities: nil)
        
        rootViewController.present(activityViewController, animated: true, completion: nil)
    }
}
