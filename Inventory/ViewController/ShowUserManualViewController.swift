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

//  ShowManualViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 27.04.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit
import PDFKit
import os


class ShowUserManualViewController: UIViewController {

    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var doneAction: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("ShowUserManualViewController viewDidLoad", log: Log.viewcontroller, type: .info)

        // setup colors for UI controls
        doneAction.tintColor = themeColorUIControls
        
        // Do any additional setup after loading the view.
        navigationBar.topItem?.title = NSLocalizedString("Inventory User Manual", comment: "Inventory User Manual")
        
        doneAction.setTitle(Global.done, for: .normal)
        
        // new in ios11: large navbar titles
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationItem.largeTitleDisplayMode = .always
        }

        navigationController?.navigationBar.prefersLargeTitles = true
        
        var fileURL : URL?
        
        switch Local.currentLocaleForDate(){
        case "de_DE", "de_AT", "de_CH", "de":
            fileURL = Bundle.main.url(forResource: "Inventory App Handbuch", withExtension: "pdf")
            break
            
        default: // all other languages get english manual
            fileURL = Bundle.main.url(forResource: "Inventory App Manual", withExtension: "pdf")
            break
        }
        
        
        // scroll PDF to top
        DispatchQueue.main.async{
                self.pdfView.autoScales = true
                self.pdfView.displayMode = .singlePageContinuous
                self.pdfView.displayDirection = .vertical
                guard let firstPage = self.pdfView.document?.page(at: 0) else { return }
                self.pdfView.go(to: CGRect(x: 0, y: Int.max, width: 0, height: 0), on: firstPage)
                
        }
        self.pdfView.document = PDFDocument(url: fileURL!)
        
    }
    
    // MARK: - UI actions

    @IBAction func doneAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
