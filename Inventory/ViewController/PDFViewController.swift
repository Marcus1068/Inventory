//
//  PDFViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 10.06.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {

    // get pdf file from calling view controller
    weak var currentPDF: PDFView?
    
    @IBOutlet weak var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationItem.largeTitleDisplayMode = .always
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.title = NSLocalizedString("PDF invoice", comment: "PDF invoice")
        
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = currentPDF?.document
    }
}
