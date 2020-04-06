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
    
    static let touchOK = NSTouchBarItem.Identifier("de.marcus-deuss.ok")
    static let touchCancel = NSTouchBarItem.Identifier("de.marcus-deuss.cancel")
    static let touchPDF = NSTouchBarItem.Identifier("de.marcus-deuss.pdf")
    static let touchPicture = NSTouchBarItem.Identifier("de.marcus-deuss.picture")
    static let touchRoom = NSTouchBarItem.Identifier("de.marcus-deuss.room")
    static let touchCategory = NSTouchBarItem.Identifier("de.marcus-deuss.category")
    static let touchBrand = NSTouchBarItem.Identifier("de.marcus-deuss.brand")
    static let touchOwner = NSTouchBarItem.Identifier("de.marcus-deuss.owner")
}
#endif

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    #if targetEnvironment(macCatalyst)
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

    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        
        touchBar.defaultItemIdentifiers = [.touchInventory, .touchAdd, .touchManage, .fixedSpaceSmall, .touchReport, .fixedSpaceSmall, .touchShare, .fixedSpaceSmall, .touchAbout]
        let manage = NSButtonTouchBarItem(identifier: .touchManage, image: UIImage(systemName: "list.number")!, target: self, action: #selector(manageItemsEntry))
        let report = NSButtonTouchBarItem(identifier: .touchReport, image: UIImage(systemName: "doc.text")!, target: self, action: #selector(reportEntry))
        let inventory = NSButtonTouchBarItem(identifier: .touchInventory, image: UIImage(systemName: "square.and.pencil")!, target: self, action: #selector(inventoryEntry))
        let share = NSButtonTouchBarItem(identifier: .touchShare, image: UIImage(systemName: "square.and.arrow.up")!, target: self, action: #selector(shareEntry))
        let about = NSButtonTouchBarItem(identifier: .touchAbout, image: UIImage(systemName: "info.circle")!, target: self, action: #selector(aboutEntry))
        let add = NSButtonTouchBarItem(identifier: .touchAdd, image: UIImage(systemName: "plus")!, target: self, action: #selector(addInvEntry))
        
        touchBar.templateItems = [manage, add, report, inventory, share, about]
        
        return touchBar
    }
    
    #endif
    
}
