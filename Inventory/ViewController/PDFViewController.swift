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

    // get pdf file from calling view controller
    weak var currentPDF: PDFView?
    var currentTitle: String?
    
    @IBOutlet weak var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("PDFViewController viewDidLoad", log: Log.viewcontroller, type: .info)

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationItem.largeTitleDisplayMode = .always
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // get title from calling view controller since it will be used in two different use cases
        self.title = currentTitle
        
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = currentPDF?.document
    }
}
