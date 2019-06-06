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
import WatchConnectivity


// define global variables that are available throughout the app
let themeColor = UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0) // kind of dark green
let themeColorUIControls = UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0) // kind of dark green
let themeColorText = UIColor.blue


// here starts everything
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // for handling watch app connectivity
    //var sessionHandler : WatchSessionManager?
    
    // iCloud key value store
    let kvStore = NSUbiquitousKeyValueStore()

    // used for app icon shortcut info.plist entries
    enum ShortcutIdentifier: String {
        case OpenShare
        case OpenReport
        case OpenImportExport
        case OpenAddItem
        
        init?(fullIdentifier: String) {
            guard let shortIdentifier = fullIdentifier.components(separatedBy: ".").last else {
                return nil
            }
            self.init(rawValue: shortIdentifier)
        }
    }
    
    // will be called when Today extension is beeing used to open the app
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //print("opened by extension")
        
        return true
    }
    
    // app starts here
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // manage large title appearance for all view controllers centrally
        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.blue,
             NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 30) ??    // Arial
                UIFont.systemFont(ofSize: 30)]
        
        // influences text color
        //window?.tintColor = themeColor
        
        // get user name and address from iCloud
        getiCloudStorageInfo()
        
        // handle app icon short cut
        if let shortcutItem =
            launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem]
                as? UIApplicationShortcutItem {
            
            let _ = handleShortcut(shortcutItem: shortcutItem)
            return false
        }
        
        // Do any additional setup after loading the view.
        let store = CoreDataStorage.shared
        
        // starts database migration to new app group location if app starts first time with app group capabilty
        let _ = store.getContext()
        
        //store.showSampleData()
        
        let myInventory = store.fetchInventory()
        
        // generate initial data if none available
        if (myInventory.count == 0){
            let rooms = store.fetchAllRooms()
            let categories = store.fetchAllCategories()
            let owners = store.fetchAllOwners()
            let brands = store.fetchAllBrands()
            
            // only generate data if complete data is gone
            if rooms.count == 0 && categories.count == 0 && owners.count == 0 && brands.count == 0{
                store.generateInitialAppData()
            }
        }
        // Do any additional setup after loading the view.
        
        // enable statistics collection
        let _ = Statistics.shared
        
        // check for watch session
     /*   if WCSession.isSupported() {
            self.sessionHandler = WatchSessionManager()
        } else {
            os_log("WCSession not supported (f.e. on iPad).")
        } */
        WatchSessionManager.sharedManager.startSession()
        
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
            
        case .OpenAddItem:
            tabBarController.selectedIndex = 0
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            
            let nav = tabBarController.viewControllers![0] as! UINavigationController
            let editView = storyboard.instantiateViewController(withIdentifier: "EditViewController") as! InventoryEditViewController
            editView.currentInventory = nil
            
            nav.pushViewController(editView, animated: true)
            
            return true
        }
        
        //return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let store = CoreDataStorage.shared
        store.saveContext()
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
        
        let store = CoreDataStorage.shared
        store.saveContext()
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


extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    // share the apps link in 3D touch action
    func shareAppLink() {
        let url = URL(string: Global.AppLink)
        
        let shareItems:Array = [url]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems as [Any], applicationActivities: nil)

        window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}
