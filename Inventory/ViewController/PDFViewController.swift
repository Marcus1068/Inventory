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
//  PDFViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 10.06.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import PDFKit
import os

class PDFViewController: UIViewController {

    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    // get pdf file from calling view controller
    var currentPDF: PDFView!
    var currentTitle: String?
    var currentPath: URL?
    
    @IBOutlet weak var pdfView: PDFView!
    
    // add keyboard shortcuts to iPadOS screen when user long presses CMD key
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "", image: nil, action: #selector(backButton), input: "D", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.back, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(firstPage), input: "F", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.firstPage, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(lastPage), input: "L", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.lastPage, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(shareButtonAction), input: "9", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.share, state: .on)
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //os_log("PDFViewController viewDidLoad", log: Log.viewcontroller, type: .info)

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationItem.largeTitleDisplayMode = .always
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // set color theme
        shareButton.tintColor =  themeColorUIControls
        
        // get title from calling view controller since it will be used in two different use cases
        self.title = currentTitle
        
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        // scroll PDF to top
        DispatchQueue.main.async
            {
                guard let firstPage = self.pdfView.document?.page(at: 0) else { return }
                self.pdfView.go(to: CGRect(x: 0, y: Int.max, width: 0, height: 0), on: firstPage)
        }
        
        pdfView.document = currentPDF?.document
        
        // add first page and last page bar buttons
        let lastPageStr = NSLocalizedString("Last Page", comment: "Last page")
        let firstPageStr = NSLocalizedString("First Page", comment: "First page")
        let lastPageBtn = UIBarButtonItem(title: lastPageStr, style: .plain, target: self, action: #selector(lastPage))
        let firstPageBtn = UIBarButtonItem(title: firstPageStr, style: .plain, target: self, action: #selector(firstPage))
        
        let arr = navigationItem.rightBarButtonItems
        navigationItem.rightBarButtonItems = arr! + [lastPageBtn, firstPageBtn]
        
        // setup colors for UI controls
        lastPageBtn.tintColor = themeColorUIControls
        firstPageBtn.tintColor = themeColorUIControls
        
        // context menu interaction
        let pdfInteraction = UIContextMenuInteraction(delegate: self)
        pdfView.addInteraction(pdfInteraction)
    }
    
    @objc func firstPage() {
        pdfView.goToFirstPage(nil)
    }
    
    @objc func lastPage() {
        pdfView.goToLastPage(nil)
    }
    
    // Mark: - UI actions
    
    @IBAction func shareButtonAction(_ sender: Any) {
        if (currentPath != nil){
            shareAction(currentPath: currentPath!)
        }
        else{
            // FIXME test ändern
            displayAlert(title: "kein PDF file", message: "kein PDF file", buttonText: Global.done)
        }
    }
    
    @objc func backButton(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    #if targetEnvironment(macCatalyst)
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        
        touchBar.defaultItemIdentifiers = [.touchBack, .fixedSpaceSmall, .touchFirstPage, .touchLastPage, .flexibleSpace, .touchShare]
        
        let back = NSButtonTouchBarItem(identifier: .touchBack, title: Global.back, target: self, action: #selector(backButton))
        back.bezelColor = Global.colorGreen
        
        let first = NSButtonTouchBarItem(identifier: .touchFirstPage, title: Global.firstPage, target: self, action: #selector(firstPage))
        first.bezelColor = Global.colorGreen
        
        let last = NSButtonTouchBarItem(identifier: .touchLastPage, title: Global.lastPage, target: self, action: #selector(lastPage))
        last.bezelColor = Global.colorGreen
        
        let share = NSButtonTouchBarItem(identifier: .touchShare, image: UIImage(systemName: "square.and.arrow.up")!, target: self, action: #selector(shareButtonAction(_:)))
        
        touchBar.templateItems = [back, first, last, share]
        
        return touchBar
    }

    #endif
    
}

// context menu extension
// long press on image gets IOS system share sheet for sending the photo somewhere
extension PDFViewController: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {

        // switch interactions since we have more than one context menu in same view controller
        switch interaction.view{
            
        case pdfView:
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

                return self.makePDFContextMenu()
            })

        default:
            // error should never happen
            break
            
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

            return self.makePDFContextMenu()
        })
    }
    
    func makePDFContextMenu() -> UIMenu {
        // Create a UIAction for sharing
        let share = UIAction(title: Global.pdf, image: UIImage(systemName: "square.and.arrow.up")) { action in
            // Show system share sheet
            self.shareAction(currentPath: self.currentPath!)
        }

        // Create and return a UIMenu with the share action
        return UIMenu(title: Global.share, children: [share])
    }
}
