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

//  initial view controller
//
//  TabBarViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 20.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit

// implement touch bar support
#if targetEnvironment(macCatalyst)
extension NSTouchBarItem.Identifier{
    static let touchManage = NSTouchBarItem.Identifier("de.marcus-deuss.manage")
    static let touchAdd = NSTouchBarItem.Identifier("de.marcus-deuss.add")
    static let touchReport = NSTouchBarItem.Identifier("de.marcus-deuss.report")
    static let touchInventory = NSTouchBarItem.Identifier("de.marcus-deuss.inventory")
    static let touchShare = NSTouchBarItem.Identifier("de.marcus-deuss.share")
    static let touchAbout = NSTouchBarItem.Identifier("de.marcus-deuss.about")
    static let touchImportExport = NSTouchBarItem.Identifier("de.marcus-deuss.importexport")
    
    static let touchEmail = NSTouchBarItem.Identifier("de.marcus-deuss.email")
    static let touchPrint = NSTouchBarItem.Identifier("de.marcus-deuss.print")
    static let touchPaper = NSTouchBarItem.Identifier("de.marcus-deuss.paper")
    static let touchImage = NSTouchBarItem.Identifier("de.marcus-deuss.image")
    static let touchSort = NSTouchBarItem.Identifier("de.marcus-deuss.sort")
    static let touchOwnerFilter = NSTouchBarItem.Identifier("de.marcus-deuss.ownerfilter")
    static let touchRoomFilter = NSTouchBarItem.Identifier("de.marcus-deuss.roomfilter")
    
    static let touchImport = NSTouchBarItem.Identifier("de.marcus-deuss.import")
    static let touchExport = NSTouchBarItem.Identifier("de.marcus-deuss.export")
    
    static let touchOK = NSTouchBarItem.Identifier("de.marcus-deuss.ok")
    static let touchCancel = NSTouchBarItem.Identifier("de.marcus-deuss.cancel")
    static let touchDone = NSTouchBarItem.Identifier("de.marcus-deuss.done")
    static let touchSave = NSTouchBarItem.Identifier("de.marcus-deuss.save")
    static let touchBack = NSTouchBarItem.Identifier("de.marcus-deuss.back")
    
    static let touchPDF = NSTouchBarItem.Identifier("de.marcus-deuss.pdf")
    static let touchPicture = NSTouchBarItem.Identifier("de.marcus-deuss.picture")
    static let touchRoom = NSTouchBarItem.Identifier("de.marcus-deuss.room")
    static let touchRoomEdit = NSTouchBarItem.Identifier("de.marcus-deuss.roomedit")
    static let touchCategory = NSTouchBarItem.Identifier("de.marcus-deuss.category")
    static let touchCategoryEdit = NSTouchBarItem.Identifier("de.marcus-deuss.categoryedit")
    static let touchBrand = NSTouchBarItem.Identifier("de.marcus-deuss.brand")
    static let touchBrandEdit = NSTouchBarItem.Identifier("de.marcus-deuss.brandedit")
    static let touchOwner = NSTouchBarItem.Identifier("de.marcus-deuss.owner")
    static let touchOwnerEdit = NSTouchBarItem.Identifier("de.marcus-deuss.owneredit")
    
    static let touchAppSettings = NSTouchBarItem.Identifier("de.marcus-deuss.appsettings")
    static let touchAppInformation = NSTouchBarItem.Identifier("de.marcus-deuss.information")
    static let touchAppFeedback = NSTouchBarItem.Identifier("de.marcus-deuss.feedback")
    static let touchAppManual = NSTouchBarItem.Identifier("de.marcus-deuss.manual")
    static let touchPrivacy = NSTouchBarItem.Identifier("de.marcus-deuss.privacy")
    
    static let touchFirstPage = NSTouchBarItem.Identifier("de.marcus-deuss.firstpage")
    static let touchLastPage = NSTouchBarItem.Identifier("de.marcus-deuss.lastpage")
}
#endif

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // add keyboard shortcuts to iPadOS screen when user long presses CMD key
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "1", modifierFlags: .command, action: #selector(inventoryEntry), discoverabilityTitle: NSLocalizedString("Inventory", comment: "Inventory")),
            UIKeyCommand(input: "2", modifierFlags: .command, action: #selector(manageItemsEntry), discoverabilityTitle: NSLocalizedString("Manage Items", comment: "Manage Items")),
            UIKeyCommand(input: "3", modifierFlags: .command, action: #selector(importExportEntry), discoverabilityTitle: NSLocalizedString("Import/Export", comment: "Import/Export")),
            UIKeyCommand(input: "4", modifierFlags: .command, action: #selector(reportEntry), discoverabilityTitle: NSLocalizedString("Report", comment: "Report")),
            UIKeyCommand(input: "5", modifierFlags: .command, action: #selector(aboutEntry), discoverabilityTitle: NSLocalizedString("About Inventory", comment: "About Inventory")),
            UIKeyCommand(input: "6", modifierFlags: .command, action: #selector(addInvEntry), discoverabilityTitle: NSLocalizedString("Add Inventory", comment: "Add Inventory"))
        ]
    }
    
    // touch bar functions
    @objc func manageItemsEntry() {
        self.selectedIndex = 1
    }
    
    @objc func inventoryEntry() {
        self.selectedIndex = 0
    }
    
    @objc func reportEntry() {
        self.selectedIndex = 3
    }
    
    @objc func importExportEntry() {
        self.selectedIndex = 2
    }
      
    @objc private func addInvEntry() {
        self.selectedIndex = 0
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        let nav = self.viewControllers![0] as! UINavigationController
        let editView = storyboard.instantiateViewController(withIdentifier: "EditViewController") as! InventoryEditViewController
        editView.currentInventory = nil
        
        nav.pushViewController(editView, animated: true)
    }

    @objc private func shareEntry(_ sender: UIBarButtonItem) {
        self.selectedIndex = 3
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let pdfView = storyboard.instantiateViewController(withIdentifier: "PDFViewerID") as! PDFViewController
        var docURL = (FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)).last as NSURL?
        
        docURL = docURL?.appendingPathComponent(Global.pdfFile) as NSURL?
        pdfView.shareAction(currentPath: docURL! as URL)
    }
    
    @objc private func aboutEntry(_ sender: UIBarButtonItem) {
        self.selectedIndex = 4
    }

    // touch bar only in catalyst app
    #if targetEnvironment(macCatalyst)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        
        touchBar.defaultItemIdentifiers = [.touchInventory, .touchAdd, .touchManage, .fixedSpaceSmall, .touchImportExport, .touchReport, .fixedSpaceSmall, .touchShare, .fixedSpaceSmall, .touchAbout]
        
        let manage = NSButtonTouchBarItem(identifier: .touchManage, image: UIImage(systemName: "list.number")!, target: self, action: #selector(manageItemsEntry))
        manage.bezelColor = Global.colorGreen
        
        let report = NSButtonTouchBarItem(identifier: .touchReport, image: UIImage(systemName: "doc.text")!, target: self, action: #selector(reportEntry))
        report.bezelColor = Global.colorGreen
        
        let inventory = NSButtonTouchBarItem(identifier: .touchInventory, image: UIImage(systemName: "square.and.pencil")!, target: self, action: #selector(inventoryEntry))
        inventory.bezelColor = Global.colorBlue
        
        let share = NSButtonTouchBarItem(identifier: .touchShare, image: UIImage(systemName: "square.and.arrow.up")!, target: self, action: #selector(shareEntry))
        share.bezelColor = Global.colorGreen
        
        let about = NSButtonTouchBarItem(identifier: .touchAbout, image: UIImage(systemName: "info.circle")!, target: self, action: #selector(aboutEntry))
        about.bezelColor = Global.colorGreen
        
        let add = NSButtonTouchBarItem(identifier: .touchAdd, image: UIImage(systemName: "plus")!, target: self, action: #selector(addInvEntry))
        add.bezelColor = Global.colorGreen
        
        let impExp = NSButtonTouchBarItem(identifier: .touchImportExport, image: UIImage(systemName: "square.and.arrow.down.on.square")!, target: self, action: #selector(importExportEntry))
        impExp.bezelColor = Global.colorGreen
        
        touchBar.templateItems = [manage, add, impExp, report, inventory, share, about]
        
        return touchBar
    }
    
    #endif
    
}
