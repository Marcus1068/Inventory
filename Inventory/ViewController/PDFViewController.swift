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
    }
    
    @objc func firstPage() {
        pdfView.goToFirstPage(nil)
    }
    
    @objc func lastPage() {
        pdfView.goToLastPage(nil)
    }
    
    // Mark: - UI actions
    
    @IBAction func shareButtonAction(_ sender: Any) {
        
        shareAction(currentPath: currentPath!)
    }
    
}
