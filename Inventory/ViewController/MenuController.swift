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
    
    init(with builder: UIMenuBuilder) {
        // First remove the menus in the menu bar you don't want, in our case the Format menu.
        // The format menu doesn't make sense
        builder.remove(menu: .format)
        //builder.remove(menu: .edit)
        //builder.remove(menu: .about)
        
        // Create and add "New" menu command at the beginning of the File menu.
        builder.insertChild(MenuController.newMenu(), atStartOfMenu: .file)
        
        // print report menu at bottom of file menu
        builder.insertChild(MenuController.printMenu(), atEndOfMenu: .file)
        
    
        // Create and add "New" menu command at the beginning of the File menu.
        builder.insertSibling(MenuController.reportMenu(), beforeMenu: .window)
        
        
    }

    
    class func printMenu() -> UIMenu {
        // Create the print menu entries with command-p
        
        let printCommand = UIKeyCommand(title: "Print report",
                                        image: nil,
                                        action: #selector(AppDelegate.inventoryMenu),
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
                                    action: #selector(AppDelegate.inventoryMenu),
                                    input: "0",
                                    modifierFlags: .command,
                                    propertyList: ["e1"])
        
        let room = UIKeyCommand(title: NSLocalizedString("Room", comment: "Room"),
                                     image: UIImage(systemName: "bed.double.fill")!,
                                     action: #selector(AppDelegate.newInventoryMenu),
                                     input: "1",
                                     modifierFlags: .command,
                                     propertyList: ["e2"])

        let category = UIKeyCommand(title: NSLocalizedString("Category", comment: "Category"),
                                     image: UIImage(systemName: "book")!,
                                     action: #selector(AppDelegate.openDocumentMenu),
                                     input: "2",
                                     modifierFlags: .command,
                                     propertyList: ["e3"])

        let brand = UIKeyCommand(title: NSLocalizedString("Brand", comment: "Brand"),
                                 image: UIImage(systemName: "cube.box")!,
                                 action: #selector(AppDelegate.openDocumentMenu),
                                 input: "3",
                                 modifierFlags: .command,
                                 propertyList: nil)

        let owner = UIKeyCommand(title: NSLocalizedString("Owner", comment: "Owner"),
                                image: UIImage(systemName: "person.2.fill")!,
                                action: #selector(AppDelegate.openDocumentMenu),
                                input: "4",
                                modifierFlags: .command,
                                propertyList: ["e5"])
        
        return UIMenu(title: NSLocalizedString("New", comment: "New"),
                      image: nil,
                      identifier: UIMenu.Identifier("de.marcus-deuss.menus.new"),
                      options: [],
                      children: [inventory, room, category, brand, owner])
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
