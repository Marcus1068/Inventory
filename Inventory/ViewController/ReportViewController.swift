//
//  ReportViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 05.04.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit
import CoreData
import os

class ReportViewController: UIViewController {

    @IBOutlet weak var textfield: UITextField!
    
    // store complete inventory as array
    var results: [Inventory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("ReportViewController viewDidLoad", log: Log.viewcontroller, type: .info)

        // Do any additional setup after loading the view.
        // new in ios11: large navbar titles
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        self.title = NSLocalizedString("Reports", comment: "Reports")
        
        // core data contents
        let context = CoreDataHandler.getContext()
        
        do {
            results = try context.fetch(self.inventoryFetchRequest())
        } catch let error as NSError {
            print("ERROR: \(error.localizedDescription)")
        }
        
        
    }
    
    // fetch all inventory sorted by item name
    private func inventoryFetchRequest() -> NSFetchRequest<Inventory> {
        let fetchRequest:NSFetchRequest<Inventory> = Inventory.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]
        
        return fetchRequest
    }
    
    // generate HTML header for page start
    private func headerPDF() -> String{
        os_log("ReportViewController headerPDF", log: Log.viewcontroller, type: .info)
    
        var header : String = ""
        
        // html table with alternating light/dark rows, small 1 px frame around table elements
        header.append("""
            <!DOCTYPE html>
            <html>
            <head>
            <style>
            table {
              font-family: arial, sans-serif;
              border-collapse: collapse;
              width: 100%;
            }

            td, th {
              border: 1px solid #dddddd;
              text-align: left;
              padding: 8px;
            }

            tr:nth-child(even) {
              background-color: #dddddd;
            }
            </style>
            </head>
            <body>
            """)
        
        return header
    }
    
    // generate HTML footer for page end
    private func footerPDF() -> String{
        os_log("ReportViewController footerPDF", log: Log.viewcontroller, type: .info)
        
        var footer : String = ""
        
        footer.append("</body> </html>")
        
        return footer
    }
    
    // all inventory items in single report, sorted alphabetically
    // FIXME implement variable sort order
    private func reportByInventoryAll() -> String{
        os_log("ReportViewController reportByInventoryAll", log: Log.viewcontroller, type: .info)
        
        var pdftext : String = ""
        
        // HTML header first
        pdftext.append(headerPDF())
        
        // heading text
        pdftext.append("<h1>" + NSLocalizedString("Report for all Inventory objects", comment: "Report for all Inventory objects") + "</h1>")
        
        // table header with column names
        pdftext.append("""
            <h2>Inventory</h2>
            <table>
            <tr>
            <th>Item</th>
            <th>Owner</th>
            <th>Room</th>
            <th>Category</th>
            <th>Price</th>
            </tr>
            """)
        
        for inv in results{
            // loop through all inventory items
            if inv.inventoryName != "" {
                pdftext.append("<tr>")
                pdftext.append("<td>" + inv.inventoryName! + "</td>")
                pdftext.append("<td>" + inv.inventoryOwner!.ownerName! + "</td>")
                pdftext.append("<td>" + inv.inventoryRoom!.roomName! + "</td>")
                pdftext.append("<td>" + inv.inventoryCategory!.categoryName! + "</td>")
                pdftext.append("<td>" + String(inv.price) + "</td>")
                //pdftext.append("<br/>")
                pdftext.append("</tr>")
            }
        }
        
        // close HTML table
        pdftext.append("</table")
        
        // close HTML tags
        pdftext.append(footerPDF())

        return pdftext
    }
    
    
    // MARK: - Actions
    @IBAction func generatePDF(_ sender: Any) {
        
        
        createPDF(filename: "Test", text: reportByInventoryAll() )
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
        os_log("ReportViewController createPDF", log: Log.viewcontroller, type: .info)
        
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
    }
}
