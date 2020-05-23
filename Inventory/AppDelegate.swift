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
let themeColor = UIColor.systemGreen // kind of dark green
let themeColorUIControls = UIColor.systemGreen // from Asset catalog
let themeColorText = UIColor.systemBlue
//let cellBorderColor = UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0)
let cellBorderColor = UIColor.systemGreen

// here starts everything
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // for handling watch app connectivity
    //var sessionHandler : WatchSessionManager?
    
    // iCloud key value store
    let kvStore = NSUbiquitousKeyValueStore()
    
    // will be called when Today extension is being used to open the app
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
            [NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
             NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 30) ??    // Arial
                UIFont.systemFont(ofSize: 30)]
        
        // register for user defaults
        registerDefaultsFromSettingsBundle()
        
        // influences text color
        //window?.tintColor = themeColor
        
        // get user name and address from iCloud
        getiCloudStorageInfo()
        
        // Do any additional setup after loading the view.
        let store = CoreDataStorage.shared
        
        // starts database migration to new app group location if app starts first time with app group capabilty
        let _ = store.getContext()
        
        //store.showSampleData()
        
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
        
        /** The registration domain is volatile.  It does not persist across launches.
            You must register your defaults at each launch; otherwise you will get (system) default values when accessing
            the values of preferences the user (via the Settings app) or your app (via set*:forKey:) has not modified.
            Registering a set of default values ensures that your app always has a known good set of values to operate on.
        */
        
        
        // create directory for export/import stuff
        let _ = URL.createFolderInDocumentsFolder(folderName: Global.imagesFolder)
        let _ = URL.createFolderInDocumentsFolder(folderName: Global.pdfFolder)
        
        return true
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
    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // get user name and address from icloud storage
    func getiCloudStorageInfo(){
        //os_log("AppDelegate getiCloudStorageInfo", log: Log.appdelegate, type: .info)
        
        if let user = kvStore.string(forKey: Local.keyUserName),
            let address = kvStore.string(forKey: Local.keyHouseName){
            UserInfo.userName = user
            UserInfo.addressName = address
        }
    }
    
    // macCatalyst: Create menu
    #if targetEnvironment(macCatalyst)
    
    
    var menuController: MenuController!
    
    /** Add the various menus to the menu bar.
        The system only asks UIApplication and UIApplicationDelegate for the main menus.
        Main menus appear regardless of who is in the responder chain.
    */
    
    // The font style check states used in the Style menu.
    var paperMenuStyleStates = Set<String>()
    
    override func buildMenu(with builder: UIMenuBuilder) {
        //Swift.debugPrint(#function)
        // Swift.debugPrint("City command = \(String(describing: value))")
        
        // Start off default paper menu checkmark value with dinA4
        paperMenuStyleStates.insert(MenuController.PaperStyle.dinA4.rawValue)
        
        /** First check if the builder object is using the main system menu, which is the main menu bar.
            If you want to check if the builder is for a contextual menu, check for: UIMenuSystem.context
         */
        if builder.system == .main {
            menuController = MenuController(with: builder)
        }
        
    }
    
    override func validate(_ command: UICommand) {
        // Obtain the plist of the incoming command.
        if let paperStyleDict = command.propertyList as? [String: String] {
            // Check if the command comes from the paper menu.
            if let paperStyle = paperStyleDict[MenuController.CommandPListKeys.PaperIdentifierKey] {
                // Update the "paper" menu command state (checked or unchecked).
                command.state = paperMenuStyleStates.contains(paperStyle) ? .on : .off
            }
            
            /* for i in paperStyleDict{
                print("Test \(i.key)")
                print("Test \(i.value)")
            } */
        }
    }
    
    // general alert extension with just one button to be pressed
    private func displayAlert(title: String, message: String, buttonText: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: buttonText, style: .default){ _ in
            // do nothing
        }
        let generateAction = UIAlertAction(title: Global.messageGenerateSampleData, style: .default){ _ in
            let store = CoreDataStorage.shared
            store.generateInitialAppData()
        }
        alertController.addAction(dismissAction)
        alertController.addAction(generateAction)
        globalWindow!.rootViewController?.present(alertController, animated: true)
    }
    
    // inventory overview
    @objc func inventoryMenu(){
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 0
    }
    
    // about/preferences menu
    @objc func preferencesMenu(){
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 4
    }
    
    // call new inventory
    @objc func addInventoryMenu() {
        let store = CoreDataStorage.shared
        guard store.checkForItems() else{
            displayAlert(title: Global.titleNoObjects, message: Global.messageNoObjects, buttonText: Global.done)
            return
        }
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 0
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "EditViewController") as! InventoryEditViewController
        editView.currentInventory = nil
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func editRoomMenu() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "RoomTableViewController") as! RoomTableViewController
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func editCategoryMenu() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "CategoryTableViewController") as! CategoryTableViewController
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func editBrandMenu() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "BrandTableViewController") as! BrandTableViewController
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func editOwnerMenu() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "OwnerTableViewController") as! OwnerTableViewController
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func addRoomMenu() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "RoomEditViewController") as! RoomEditViewController
        editView.currentRoom = nil  // new item
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func addCategoryMenu() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "CategoryEditViewController") as! CategoryEditViewController
        editView.currentCategory = nil  // new item
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func addBrandMenu() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "BrandEditViewController") as! BrandEditViewController
        editView.currentBrand = nil  // new item
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func addOwnerMenu() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "OwnerEditViewController") as! OwnerEditViewController
        editView.currentOwner = nil  // new item
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func importMenu() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "ImportExportViewController") as! ImportExportViewController
        
        nav.pushViewController(editView, animated: false)
        
        editView.importFilesApp()
        
    }
    
    @objc func exportMenu() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "ImportExportViewController") as! ImportExportViewController
        
        nav.pushViewController(editView, animated: false)
        
        editView.export()
    }
    
    @objc func backupMenu() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        //tabBarController.selectedIndex = 2
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "ImportExportViewController") as! ImportExportViewController
        
        nav.pushViewController(editView, animated: false)
        
        editView.backupDataToiCloud()
    }
    
    @objc func restoreMenu() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "ImportExportViewController") as! ImportExportViewController
        
        nav.pushViewController(editView, animated: false)
        
        editView.restoreFromiCloud()
    }
    
    @objc func printMenu() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
       
        tabBarController.selectedIndex = 3
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        //let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "ReportViewController") as! ReportViewController
        //nav.pushViewController(editView, animated: false)
        let pdf = editView.pdfCreateInventoryReport()
        let url = editView.pdfSave(pdf)
        
        editView.printPDFAction(url: url)
    }
    
    @objc
    // User choses an item from the "paper" menu.
    func paperStyleAction(_ sender: AnyObject) {
        if let keyCommand = sender as? UICommand {
            if let paperStyleDict = keyCommand.propertyList as? [String: String] {
                if let paperStyle = paperStyleDict[MenuController.CommandPListKeys.PaperIdentifierKey] {
                    if paperMenuStyleStates.contains(paperStyle) {
                        paperMenuStyleStates.remove(paperStyle)
                    } else {
                        paperMenuStyleStates.insert(paperStyle)
                    }
                }
            }
        }
    }
    
    #endif
    
    
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
    
    // MARK: - Preferences
    
    enum BackgroundColors: Int {
        case yellow = 1
        case gray = 2
        case green = 3
        case standard = 4
    }
    
    // Locates the file representing the root page of the settings for this app and registers the loaded values as the app's defaults.
    func registerDefaultsFromSettingsBundle() {
        let settingsUrl =
            Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
        let settingsPlist = NSDictionary(contentsOf: settingsUrl)!
        if let preferences = settingsPlist["PreferenceSpecifiers"] as? [NSDictionary] {
            var defaultsToRegister = [String: Any]()
    
            for prefItem in preferences {
                guard let key = prefItem["Key"] as? String else {
                    continue
                }
                defaultsToRegister[key] = prefItem["DefaultValue"]
            }
            UserDefaults.standard.register(defaults: defaultsToRegister)
        }
    }
}
