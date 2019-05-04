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
    weak var currentPDF: PDFView?
    var currentTitle: String?
    var currentPath: URL?
    
    @IBOutlet weak var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("PDFViewController viewDidLoad", log: Log.viewcontroller, type: .info)

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
    }
    
    // Mark: - UI actions
    
    @IBAction func shareButtonAction(_ sender: Any) {
        os_log("PDFViewController shareButtonAction", log: Log.viewcontroller, type: .info)
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: currentPath!.path) {
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [currentPath!], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            os_log("PDFViewController shareButtonAction", log: Log.viewcontroller, type: .error)
            
            let alertController = UIAlertController(title: Global.error, message: Global.documentNotFound, preferredStyle: .alert)
            let defaultAction = UIAlertAction.init(title: Global.ok, style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(defaultAction)
            navigationController!.present(alertController, animated: true, completion: nil)
        }
    }
    
}
