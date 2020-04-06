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
class SceneDelegate: UIResponder, UIWindowSceneDelegate, NSTouchBarDelegate{
    
    var window: UIWindow?
    
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
    
}

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let inventoryOverviewEntry = NSToolbarItem.Identifier(rawValue: "inventoryOverviewEntry")
    static let addInvEntry = NSToolbarItem.Identifier(rawValue: "AddInvEntry")
    static let manageItemsEntry = NSToolbarItem.Identifier(rawValue: "ManageItemsEntry")
    static let reportEntry = NSToolbarItem.Identifier(rawValue: "ReportEntry")
    static let deleteEntry = NSToolbarItem.Identifier(rawValue: "DeleteEntry")
    static let shareEntry = NSToolbarItem.Identifier(rawValue: "ShareEntry")
    static let aboutEntry = NSToolbarItem.Identifier(rawValue: "AboutEntry")
}

// for toolbar
extension SceneDelegate: NSToolbarDelegate {
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.inventoryOverviewEntry, .addInvEntry, .manageItemsEntry, .reportEntry, .shareEntry, .flexibleSpace, .aboutEntry]
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar)
      -> [NSToolbarItem.Identifier] {
        return [.inventoryOverviewEntry, .addInvEntry, .manageItemsEntry, .reportEntry, .shareEntry, .flexibleSpace, .aboutEntry]
    }

    // inventory overview
    // manage all items like rooms, categories etc call
    @objc func inventoryEntry() {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 0
    }
    
    // Add inventory call
    @objc func addInvEntry() {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 0
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = tabBarController.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "EditViewController") as! InventoryEditViewController
        editView.currentInventory = nil
        
        nav.pushViewController(editView, animated: true)
    }
    
    // manage all items like rooms, categories etc call
    @objc func manageItemsEntry() {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 1
    }
    
    @objc func reportEntry() {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 3
    }
      
    @objc private func deleteEntry() {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 3
    }

    @objc private func shareEntry(_ sender: UIBarButtonItem) {
        // TODO:
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 4
    }
    
    @objc private func aboutEntry(_ sender: UIBarButtonItem) {
        // TODO:
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return
        }
        
        tabBarController.selectedIndex = 4
    }

    private func toolbarItem(itemIdentifier: NSToolbarItem.Identifier, barButtonItem: UIBarButtonItem,
      toolTip: String? = nil, label: String?) -> NSToolbarItem {
        
        // hide tab bar if Catalyst app
        let tabBarController = self.window?.rootViewController as? UITabBarController
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
            let barButtonItem =
                UIBarButtonItem(barButtonSystemItem: .compose,
                              target: self, action: #selector(inventoryEntry))
            item = toolbarItem(itemIdentifier: .inventoryOverviewEntry, barButtonItem: barButtonItem, toolTip: "Inventory", label: "Inventory")
            item?.target = self
            item?.action = #selector(inventoryEntry)
            break
            
        case .addInvEntry:
            let barButtonItem =
                UIBarButtonItem(barButtonSystemItem: .add,
                              target: self, action: #selector(addInvEntry))
            item = toolbarItem(itemIdentifier: .addInvEntry, barButtonItem: barButtonItem, toolTip: "Add Inv Entry", label: "Add Inventory")
            item?.target = self
            item?.action = #selector(addInvEntry)
            break
            
        case .manageItemsEntry:
            let barButtonItem =
                UIBarButtonItem(image: UIImage(named: "list"), style: .plain,
                              target: self, action: #selector(manageItemsEntry))
            item = toolbarItem(itemIdentifier: .manageItemsEntry, barButtonItem: barButtonItem, toolTip: "Manage Items", label: "Manage Items")
            item?.target = self
            item?.action = #selector(manageItemsEntry)
            break
        
            case .reportEntry:
            let barButtonItem =
                UIBarButtonItem(image: UIImage(named: "Report"), style: .plain,
                              target: self, action: #selector(reportEntry))
            item = toolbarItem(itemIdentifier: .reportEntry, barButtonItem: barButtonItem, toolTip: "Show Report", label: "Show Report")
            item?.target = self
            item?.action = #selector(reportEntry)
            break
            
        case .deleteEntry:
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteEntry))
            
            item = toolbarItem(itemIdentifier: .deleteEntry, barButtonItem: barButtonItem, toolTip: "Delete Entry", label: "Delete")
            
            item?.target = self
            item?.action = #selector(deleteEntry)
            break
            
        case .aboutEntry:
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "about"), style: .plain, target: self, action: #selector(aboutEntry(_:)))
            
            item = toolbarItem(itemIdentifier: .aboutEntry, barButtonItem: barButtonItem, toolTip: "About Inventory", label: "About Inventory")
            
            item?.target = self
            item?.action = #selector(aboutEntry)
            break
        
            case .shareEntry:
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareEntry(_:)))
            
            item = toolbarItem(itemIdentifier: .shareEntry, barButtonItem: barButtonItem, toolTip: "Share Entry", label: "Share Inventory")
            break
            
        default:
            break
        }
        
        return item
    }

}
#endif
