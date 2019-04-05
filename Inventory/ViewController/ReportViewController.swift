//
//  ReportViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 05.04.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit
import os.log

class ReportViewController: UIViewController {

    @IBOutlet weak var textfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // new in ios11: large navbar titles
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        self.title = NSLocalizedString("Reports", comment: "Reports")
    }
    
    // MARK: - Actions
    @IBAction func generatePDF(_ sender: Any) {
        createPDF(filename: "Test", text: textfield.text ?? "<#default value#>")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // create a DIN A based PDF file requires CoreGraphics because pdfkit only allows for displaying PDF files
    private func createPDF(filename: String, text: String) {
        
        let formatter = UIMarkupTextPrintFormatter(markupText: text)
        
        // Add formatter with pageRender
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)
        
        
        // Assign paperRect and printableRect
        
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        // Use this to get US Letter size instead
        // let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let printable = page.insetBy(dx: 0, dy: 0)
        
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        // Create PDF context and draw
        let rect = CGRect.zero
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, rect, nil)
        
        for i in 1...render.numberOfPages {
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        pdfData.write(toFile: "\(documentsPath)/\(filename).pdf", atomically: true)
        
        os_log("createPDF", log: OSLog.default, type: .info)
    }
}
