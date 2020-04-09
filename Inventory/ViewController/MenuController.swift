//
//  MenuController.swift
//  Inventory
//
//  Created by Marcus Deuß on 09.04.20.
//  Copyright © 2020 Marcus Deuß. All rights reserved.
//

import UIKit

// Property list keys to access UICommand/UIKeyCommand values.
struct CommandPListKeys {
    static let ArrowsKeyIdentifier = "id" // Arrow command-keys
    static let CitiesKeyIdentifier = "city" // City command-keys
    static let TownsIdentifierKey = "town" // Town commands
    static let StylesIdentifierKey = "font" // Font style commands
    static let ToolsIdentifierKey = "tool" // Tool commands
}

enum ToolType: Int {
    case lasso = 0
    case pencil = 1
    case scissors = 2
    case rotate = 3
}

class MenuController{
    
    // macCatalyst: Create menu
    #if targetEnvironment(macCatalyst)
    
    /* Create UIMenu objects and use them to construct the menus and submenus your app displays. You provide menus for your app when it runs on macOS, and key command elements in those menus also appear in the discoverability HUD on iPad when the user presses the command key. You also use menus to display contextual actions in response to specific interactions with one of your views. Every menu has a title, an optional image, and an optional set of child elements. When the user selects an element from the menu, the system executes the code that you provide.
     */
    
    init(with builder: UIMenuBuilder) {
        // First remove the menus in the menu bar you don't want, in our case the Format menu.
        // The format menu doesn't make sense
        builder.remove(menu: .format)
        builder.remove(menu: .edit)
        //builder.remove(menu: .about)
        
        // Create and add "Open" menu command at the beginning of the File menu.
        builder.insertChild(MenuController.itemsMenu(), atStartOfMenu: .file)
    
        // Create and add "New" menu command at the beginning of the File menu.
        builder.insertSibling(MenuController.reportMenu(), beforeMenu: .window)
        
        // Create and add "New" menu command at the beginning of the File menu.
        builder.insertSibling(MenuController.toolsMenu(), beforeMenu: .window)
        
        
    }
    
    class func toolsMenu() -> UIMenu {
        let lCommand = UICommand(title: "aaa",
                                     image: UIImage(systemName: "square.and.pencil")!,
                                     action: #selector(AppDelegate.inventoryMenu),
                                     propertyList: ["a"])
        
        let sCommand = UICommand(title: "bbb",
                                        image: nil,
                                        action: #selector(AppDelegate.inventoryMenu),
                                        propertyList: ["b"])
        
        let rCommand = UICommand(title: "ccc",
                                      image: nil,
                                      action: #selector(AppDelegate.inventoryMenu),
                                      propertyList: ["c"])
        
        let pCommand = UICommand(title: "ddd",
                                      image: nil,
                                      action: #selector(AppDelegate.inventoryMenu),
                                      propertyList: ["d"])
        

        return UIMenu(title: "Tools",
                      image: nil,
                      identifier: UIMenu.Identifier("de.marcus-deuss.menus.toolse"),
                      options: [],
                      children: [lCommand, sCommand, rCommand, pCommand])
    }
    
    class func itemsMenu() -> UIMenu {
        // Create the items menu
        
        let brand = UICommand(title: "New brand",
                            image: nil,
                            action: #selector(AppDelegate.inventoryMenu),
                            propertyList: [])
        
        let newInventory = UICommand(title: "New Room",
                                     image: nil,
                                     action: #selector(AppDelegate.newInventoryMenu),
                                     propertyList: [])

        let openDocument = UICommand(title: "New category.",
                                     image: nil,
                                     action: #selector(AppDelegate.openDocumentMenu),
                                     propertyList: [])
        
        return UIMenu(title: NSLocalizedString("Manage Items", comment: ""),
                      image: nil,
                      identifier: UIMenu.Identifier("de.marcus-deuss.menus.items"),
                      options: [],
                      children: [brand, newInventory, openDocument])
    }
    
    class func reportMenu() -> UIMenu {
        let lassoCommand = UICommand(title: "rep1",
                                     image: UIImage(systemName: "square.and.pencil")!,
                                     action: #selector(AppDelegate.inventoryMenu),
                                     propertyList: ["e"])
        
        let scissorsCommand = UICommand(title: "rep2",
                                        image: nil,
                                        action: #selector(AppDelegate.inventoryMenu),
                                        propertyList: ["f"])
        
        let rotateCommand = UICommand(title: "rep3",
                                      image: nil,
                                      action: #selector(AppDelegate.inventoryMenu),
                                      propertyList: ["g"])
        
        let pencilCommand = UICommand(title: "rep4",
                                      image: nil,
                                      action: #selector(AppDelegate.inventoryMenu),
                                      propertyList: ["h"])

        return UIMenu(title: "Reports",
                      image: nil,
                      identifier: UIMenu.Identifier("de.marcus-deuss.menus.reports"),
                      options: [],
                      children: [lassoCommand, scissorsCommand, rotateCommand, pencilCommand])
    }
    
    #endif
}
