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
//  MenuController.swift
//  Inventory
//
//  Created by Marcus Deuß on 09.04.20.
//  Copyright © 2020 Marcus Deuß. All rights reserved.
//

import UIKit

class MenuController{
    
    // macCatalyst: Create menu
    #if targetEnvironment(macCatalyst)
    
    /* Create UIMenu objects and use them to construct the menus and submenus your app displays. You provide menus for your app when it runs on macOS, and key command elements in those menus also appear in the discoverability HUD on iPad when the user presses the command key. You also use menus to display contextual actions in response to specific interactions with one of your views. Every menu has a title, an optional image, and an optional set of child elements. When the user selects an element from the menu, the system executes the code that you provide.
     */
    
    struct CommandPListKeys {
        static let ArrowsKeyIdentifier = "id"   // Arrow command-keys
        static let PaperIdentifierKey = "paper" // paper style commands
        static let ToolsIdentifierKey = "tool"  // Tool commands
    }
    
    enum PaperStyle: String, CaseIterable {
        case dinA4
        case usletter
        func localizedString() -> String {
            return NSLocalizedString("\(self.rawValue)", comment: "")
        }
    }
    
    init(with builder: UIMenuBuilder) {
        // First remove the menus in the menu bar you don't want, in our case the Format menu.
        // The format menu doesn't make sense
        builder.remove(menu: .format)
        builder.remove(menu: .edit)
        //builder.remove(menu: .about)
        
        //builder.insertSibling(MenuController.preferencesMenu(), afterMenu: .about)
        
        // Create and add "Import" menu command at the beginning of the File menu.
        builder.insertChild(MenuController.importExportMenu(), atStartOfMenu: .file)
        
        // Create and add "New" menu command at the beginning of the File menu.
        builder.insertChild(MenuController.newMenu(), atStartOfMenu: .file)
        
        // print report menu at bottom of file menu
        builder.insertChild(MenuController.printMenu(), atEndOfMenu: .file)
    
        // Create and add "New" menu command at the beginning of the File menu.
        builder.insertSibling(MenuController.itemManageMenu(), beforeMenu: .window)
        
        // Create and add "New" menu command at the beginning of the File menu.
        builder.insertSibling(MenuController.reportMenu(), beforeMenu: .window)
        
        
    }
/*
    class func preferencesMenu() -> UIMenu {
        // Create the preferences/about menu entries with command-p
        
        let prefCommand = UIKeyCommand(title: NSLocalizedString("Preferences", comment: "Preferences"),
                                        image: nil,
                                        action: #selector(AppDelegate.preferencesMenu),
                                        input: "T",
                                        modifierFlags: .command,
                                        propertyList: nil)
        
        return UIMenu(title: "",
                      image: nil,
                      identifier: UIMenu.Identifier("de.marcus-deuss.menus.preferences"),
                      options: [.displayInline],
                      children: [prefCommand])
    }
  */
    class func printMenu() -> UIMenu {
        // Create the print menu entries with command-p
        
        let printCommand = UIKeyCommand(title: NSLocalizedString("Print report", comment: "Print report"),
                                        image: nil,
                                        action: #selector(AppDelegate.printMenu),
                                        input: "P",
                                        modifierFlags: .command,
                                        propertyList: nil)
        
        return UIMenu(title: "",
                      image: nil,
                      identifier: UIMenu.Identifier("de.marcus-deuss.menus.print"),
                      options: [.displayInline],
                      children: [printCommand])
    }
    
    class func newMenu() -> UIMenu {
        // Create the file new menu entries
        
        let inventory = UIKeyCommand(title: NSLocalizedString("Inventory", comment: "Inventory menu entry"),
                                    image: UIImage(systemName: "square.and.pencil")!,
                                    action: #selector(AppDelegate.addInventoryMenu),
                                    input: "0",
                                    modifierFlags: .command,
                                    propertyList: "0")
        
        let room = UIKeyCommand(title: NSLocalizedString("Room", comment: "Room"),
                                     image: UIImage(systemName: "bed.double.fill")!,
                                     action: #selector(AppDelegate.addRoomMenu),
                                     input: "1",
                                     modifierFlags: .command,
                                     propertyList: "1")

        let category = UIKeyCommand(title: NSLocalizedString("Category", comment: "Category"),
                                     image: UIImage(systemName: "book")!,
                                     action: #selector(AppDelegate.addCategoryMenu),
                                     input: "2",
                                     modifierFlags: .command,
                                     propertyList: "2")

        let brand = UIKeyCommand(title: NSLocalizedString("Brand", comment: "Brand"),
                                 image: UIImage(systemName: "cube.box")!,
                                 action: #selector(AppDelegate.addBrandMenu),
                                 input: "3",
                                 modifierFlags: .command,
                                 propertyList: "3")

        let owner = UIKeyCommand(title: NSLocalizedString("Owner", comment: "Owner"),
                                image: UIImage(systemName: "person.2.fill")!,
                                action: #selector(AppDelegate.addOwnerMenu),
                                input: "4",
                                modifierFlags: .command,
                                propertyList: "4")
        
        return UIMenu(title: NSLocalizedString("New", comment: "New"),
                      image: nil,
                      identifier: UIMenu.Identifier("de.marcus-deuss.menus.new"),
                      options: [],
                      children: [inventory, room, category, brand, owner])
    }
    
    class func importExportMenu() -> UIMenu {
        // Create the file new menu entries
        
        let imp = UIKeyCommand(title: NSLocalizedString("Import", comment: "Import"),
                                    image: UIImage(systemName: "square.and.arrow.down")!,
                                    action: #selector(AppDelegate.importMenu),
                                    input: "5",
                                    modifierFlags: .command,
                                    propertyList: "5")
        
        let exp = UIKeyCommand(title: NSLocalizedString("Export", comment: "Export"),
                                     image: UIImage(systemName: "square.and.arrow.up")!,
                                     action: #selector(AppDelegate.exportMenu),
                                     input: "6",
                                     modifierFlags: .command,
                                     propertyList: "6")

        
        
        return UIMenu(title: NSLocalizedString("Import/Export", comment: "Import/Export"),
                      image: nil,
                      identifier: UIMenu.Identifier("de.marcus-deuss.menus.import"),
                      options: [],
                      children: [imp, exp])
    }
    
    class func itemManageMenu() -> UIMenu {
        let room = UIKeyCommand(title: Global.editRoom,
                                     image: UIImage(systemName: "bed.double.fill")!,
                                     action: #selector(AppDelegate.editRoomMenu),
                                     input: "0",
                                     modifierFlags: .control,
                                     propertyList: ["v1"])
        
        let category = UIKeyCommand(title: Global.editCategory,
                                        image: UIImage(systemName: "book")!,
                                        action: #selector(AppDelegate.editCategoryMenu),
                                        input: "1",
                                        modifierFlags: .control,
                                        propertyList: ["v2"])
        
        let brand = UIKeyCommand(title: Global.editBrand,
                                      image: UIImage(systemName: "cube.box")!,
                                      action: #selector(AppDelegate.editBrandMenu),
                                      input: "2",
                                      modifierFlags: .control,
                                      propertyList: ["v3"])
        
        let owner = UIKeyCommand(title: Global.editOwner,
                                      image: UIImage(systemName: "person.2.fill")!,
                                      action: #selector(AppDelegate.editOwnerMenu),
                                      input: "3",
                                      modifierFlags: .control,
                                      propertyList: ["v4"])

        return UIMenu(title: NSLocalizedString("Items", comment: "Items"),
                      image: nil,
                      identifier: UIMenu.Identifier("de.marcus-deuss.menus.manageitems"),
                      options: [],
                      children: [room, category, brand, owner])
    }
    
    
    
    class func reportMenu() -> UIMenu {
        
        let paperChildrenCommands = PaperStyle.allCases.map { paper in
                            UICommand(title: paper.localizedString(),
                                    image: nil,
                                    action: #selector(AppDelegate.paperStyleAction(_:)),
                                    propertyList: [CommandPListKeys.PaperIdentifierKey: paper.rawValue],
                                    alternates: [])
        }

        return UIMenu(title: NSLocalizedString("Reports", comment: "Reports"),
                      image: nil,
                      identifier: UIMenu.Identifier("de.marcus-deuss.menus.reports"),
                      options: [],
                      children: paperChildrenCommands)
    }
    
    #endif
}
