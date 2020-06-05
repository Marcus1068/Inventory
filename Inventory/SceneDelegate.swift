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
//  SceneDelegate.swift
//  Inventory
//
//  Created by Marcus Deuß on 30.11.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit

// need to store window variable as global to use it in AppDelegate for menu handling
var globalWindow: UIWindow?

@available(iOS 13.0, macOS 15.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate{
    
    var window: UIWindow?
    
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
    
    // This method is the way that notifies us about the addition of a scene to the app, a scene could be seen as a window.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        //guard let _ = (scene as? UIWindowScene) else { return }
        
        #if targetEnvironment(macCatalyst)

        if let scene = scene as? UIWindowScene,
            let titlebar = scene.titlebar {
            
            let toolbar = NSToolbar(identifier: "Toolbar")
          
            titlebar.toolbar = toolbar
            toolbar.delegate = self
        
            toolbar.allowsUserCustomization = true
            toolbar.autosavesConfiguration = true

        }
        
        // store this for AppDelegate use to get menus up and running
        globalWindow = self.window
        
        #endif
        
        // show whats new only on iOS, catalyst shows wrong window
        #if targetEnvironment(macCatalyst)
        // do nothing
        #else
        // show onbaording window with latest app update information
        // use user defaults to store state so that we show only once after app update
        // increase build number and/or version number will show up onboarding screen again
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc: UIViewController
        
        if (UserDefaults.standard.value(forKey: Global.appVersion) as? String) == nil{
            // show onbording screen
            // identifier must be set in onboarding view controller
            vc = storyboard.instantiateViewController(identifier: "startupID")
            
        }
        else{
            // show main screen
            vc = storyboard.instantiateInitialViewController()!
        }
        
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        
        #endif
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        // get latest icloud user data when app starts
        NSUbiquitousKeyValueStore().synchronize()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        //(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        
        let store = CoreDataStorage.shared
        store.saveContext()
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem: shortcutItem))
    }
    
    private func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        let shortcutType = shortcutItem.type
        guard let shortcutIdentifier = ShortcutIdentifier(fullIdentifier: shortcutType) else {
            return false
        }
        
        return selectTabBarItemForIdentifier(shortcutIdentifier)
    }
    
    // share the apps link in 3D touch action
    func shareAppLink() {
        let url = URL(string: Global.AppLink)
        
        let shareItems:Array = [url]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems as [Any], applicationActivities: nil)

        window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
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
            let store = CoreDataStorage.shared
            if store.checkForItems(){
                tabBarController.selectedIndex = 0
                
                let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                
                let nav = tabBarController.viewControllers![0] as! UINavigationController
                let editView = storyboard.instantiateViewController(withIdentifier: "EditViewController") as! InventoryEditViewController
                editView.currentInventory = nil
                
                nav.pushViewController(editView, animated: true)
            }
            else{
                let alertController = UIAlertController(title: Global.titleNoObjects, message: Global.messageNoObjects, preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: Global.done, style: .default){ _ in
                    // do nothing
                }
                let generateAction = UIAlertAction(title: Global.messageGenerateSampleData, style: .default){ _ in
                    let store = CoreDataStorage.shared
                    store.generateInitialAppData()
                }
                alertController.addAction(dismissAction)
                alertController.addAction(generateAction)
                self.window!.rootViewController?.present(alertController, animated: true)
            }
            
            return true
        }
        
        //return true
    }
    
}

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let inventoryOverviewEntry = NSToolbarItem.Identifier(rawValue: "inventoryOverviewEntry")
    static let addInvEntry = NSToolbarItem.Identifier(rawValue: "AddInvEntry")
    static let manageItemsEntry = NSToolbarItem.Identifier(rawValue: "ManageItemsEntry")
    static let addRoomEntry = NSToolbarItem.Identifier(rawValue: "AddRoomEntry")
    static let addCategoryEntry = NSToolbarItem.Identifier(rawValue: "AddCategoryEntry")
    static let addBrandEntry = NSToolbarItem.Identifier(rawValue: "AddBrandEntry")
    static let addOwnerEntry = NSToolbarItem.Identifier(rawValue: "AddOwnerEntry")
    static let reportEntry = NSToolbarItem.Identifier(rawValue: "ReportEntry")
    static let importEntry = NSToolbarItem.Identifier(rawValue: "ImportEntry")
    static let shareEntry = NSToolbarItem.Identifier(rawValue: "ShareEntry")
    static let aboutEntry = NSToolbarItem.Identifier(rawValue: "AboutEntry")
    static let printEntry = NSToolbarItem.Identifier(rawValue: "PrintEntry")
}

// for toolbar
extension SceneDelegate: NSToolbarDelegate {
    
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
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.inventoryOverviewEntry, .addInvEntry, .manageItemsEntry, .addRoomEntry, .addCategoryEntry, .addBrandEntry, .addOwnerEntry, .importEntry, .reportEntry, /*.shareEntry,*/ .printEntry, .flexibleSpace, .aboutEntry]
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar)
      -> [NSToolbarItem.Identifier] {
        return [.inventoryOverviewEntry, .addInvEntry, .manageItemsEntry, .addRoomEntry, .addCategoryEntry, .addBrandEntry, .addOwnerEntry, .importEntry, .reportEntry, /*.shareEntry, */.printEntry, .flexibleSpace, .aboutEntry]
    }

    // inventory overview
    // manage all items like rooms, categories etc call
    @objc func inventoryEntry(_ sender: UIBarButtonItem) {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 0
    }
    
    // Add inventory call
    @objc func addInvEntry(_ sender: UIBarButtonItem) {
        let store = CoreDataStorage.shared
        guard store.checkForItems() else{
            displayAlert(title: Global.titleNoObjects, message: Global.messageNoObjects, buttonText: Global.done)
            return
        }
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 0
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "EditViewController") as! InventoryEditViewController
        editView.currentInventory = nil
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func printEntry() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
       
        tabBarController.selectedIndex = 3
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        //let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "ReportViewController") as! ReportViewController
        //nav.pushViewController(editView, animated: false)
        /*let pdf = editView.pdfCreateInventoryReport()
        let url = editView.pdfSave(pdf)
        
        editView.printPDFAction(url: url) */
        
        editView.printReport()
    }
    
    // manage all items like rooms, categories etc call
    @objc func manageItemsEntry(_ sender: UIBarButtonItem) {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 1
    }
    
    @objc func addRoomEntry() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "RoomEditViewController") as! RoomEditViewController
        editView.currentRoom = nil  // new item
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func addCategoryEntry() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "CategoryEditViewController") as! CategoryEditViewController
        editView.currentCategory = nil  // new item
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func addBrandEntry() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "BrandEditViewController") as! BrandEditViewController
        editView.currentBrand = nil  // new item
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func addOwnerEntry() {
        guard let tabBarController = globalWindow!.rootViewController as? UITabBarController else {
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "OwnerEditViewController") as! OwnerEditViewController
        editView.currentOwner = nil  // new item
        
        nav.pushViewController(editView, animated: false)
    }
    
    @objc func importEntry(_ sender: UIBarButtonItem) {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 2
    }
    
    @objc func reportEntry(_ sender: UIBarButtonItem) {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 3
    }

    @objc private func shareEntry(_ sender: UIBarButtonItem) {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 3
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let pdfView = storyboard.instantiateViewController(withIdentifier: "PDFViewerID") as! PDFViewController
        var docURL = (FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)).last as NSURL?
        
        docURL = docURL?.appendingPathComponent(Global.pdfFile) as NSURL?
        pdfView.shareAction(currentPath: docURL! as URL, sourceView: globalWindow!)
        
    }
    
    @objc private func aboutEntry(_ sender: UIBarButtonItem) {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 4
    }

    private func toolbarItem(itemIdentifier: NSToolbarItem.Identifier, barButtonItem: UIBarButtonItem,
      toolTip: String? = nil, label: String?) -> NSToolbarItem {
        
        // hide tab bar if Catalyst app
        let tabBarController = globalWindow!.rootViewController as? UITabBarController
        tabBarController?.tabBar.isHidden = true
        
        
        let item = NSToolbarItem(itemIdentifier: itemIdentifier,
          barButtonItem: barButtonItem)

        item.isBordered = true
        item.toolTip = toolTip
        
        if let label = label {
          item.label = label
        }
        
        return item
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
      
        var item: NSToolbarItem? = nil

        switch(itemIdentifier){
        case .inventoryOverviewEntry:
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.grid.3x2.fill"), style: .plain, target: self, action: #selector(inventoryEntry(_:)))
            item = toolbarItem(itemIdentifier: .inventoryOverviewEntry, barButtonItem: barButtonItem, toolTip: Global.inventory, label: Global.inventory)
            item?.target = self
            item?.action = #selector(inventoryEntry)
            break
            
        case .addInvEntry:
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addInvEntry(_:)))
            item = toolbarItem(itemIdentifier: .addInvEntry, barButtonItem: barButtonItem, toolTip: Global.addInv, label: Global.addInv)
            item?.target = self
            item?.action = #selector(addInvEntry)
            break
            
        case .manageItemsEntry:
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.number"), style: .plain, target: self, action: #selector(manageItemsEntry(_:)))
            item = toolbarItem(itemIdentifier: .manageItemsEntry, barButtonItem: barButtonItem, toolTip: Global.manageItems, label: Global.manageItems)
            item?.target = self
            item?.action = #selector(manageItemsEntry)
            break
        
        case .addRoomEntry:
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "bed.double.fill"), style: .plain, target: self, action: #selector(addRoomEntry))
            item = toolbarItem(itemIdentifier: .addRoomEntry, barButtonItem: barButtonItem, toolTip: Global.addRoom, label: Global.addRoom)
            item?.target = self
            item?.action = #selector(addRoomEntry)
            break
            
        case .addCategoryEntry:
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "book"), style: .plain, target: self, action: #selector(addCategoryEntry))
            item = toolbarItem(itemIdentifier: .addCategoryEntry, barButtonItem: barButtonItem, toolTip: Global.addcategory, label: Global.addcategory)
            item?.target = self
            item?.action = #selector(addCategoryEntry)
            break
        
        case .addBrandEntry:
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "cube.box"), style: .plain, target: self, action: #selector(addBrandEntry))
            item = toolbarItem(itemIdentifier: .addBrandEntry, barButtonItem: barButtonItem, toolTip: Global.addBrand, label: Global.addBrand)
            item?.target = self
            item?.action = #selector(addBrandEntry)
            break
            
        case .addOwnerEntry:
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.2.fill"), style: .plain, target: self, action: #selector(addOwnerEntry))
            item = toolbarItem(itemIdentifier: .addOwnerEntry, barButtonItem: barButtonItem, toolTip: Global.addOwner, label: Global.addOwner)
            item?.target = self
            item?.action = #selector(addOwnerEntry)
            break
            
        case .importEntry:
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: Global.importExportSymbol), style: .plain, target: self, action: #selector(importEntry(_:)))
            item = toolbarItem(itemIdentifier: .importEntry, barButtonItem: barButtonItem, toolTip: Global.importExport, label: Global.importExport)
            item?.target = self
            item?.action = #selector(importEntry)
            break
            
        case .reportEntry:
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "doc.text"), style: .plain, target: self, action: #selector(reportEntry(_:)))
            item = toolbarItem(itemIdentifier: .reportEntry, barButtonItem: barButtonItem, toolTip: Global.report, label: Global.report)
            item?.target = self
            item?.action = #selector(reportEntry)
            break
            
        case .aboutEntry:
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(aboutEntry(_:)))
            item = toolbarItem(itemIdentifier: .aboutEntry, barButtonItem: barButtonItem, toolTip: Global.about, label: Global.about)
            item?.target = self
            item?.action = #selector(aboutEntry)
            break
        
        case .shareEntry:
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareEntry(_:)))
            item = toolbarItem(itemIdentifier: .shareEntry, barButtonItem: barButtonItem, toolTip: Global.share, label: Global.share)
            break
            
        case .printEntry:
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "printer"), style: .plain, target: self, action: #selector(printEntry))
            item = toolbarItem(itemIdentifier: .printEntry, barButtonItem: barButtonItem, toolTip: Global.printReport, label: Global.printReport)
            break
            
        default:
            break
        }
        
        return item
    }

}
#endif
