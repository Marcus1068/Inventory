//
//  ReportViewController.swift
//  Inventory
//
//  contains all reports that will be generated via HMTL and then PDF for further use
//  Created by Marcus Deuß on 05.04.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit
import CoreData
import os

class ReportViewController: UIViewController {

    @IBOutlet weak var textfield: UITextField!
    
    // handle different paper sizes
    enum PaperSize {
        case dinA4
        case usLetter
    }
    
    // should be user changable
    
    
    // general paper size
    var paper_width = 0.0
    var paper_height = 0.0
    
    // position on page to print page numbers
    var pageNumber_pos_x = 0.0
    var pageNumber_pos_y = 0.0
    
    // pdf title on page
    var title_pos_x = 0.0
    var title_pos_y = 0.0
    var title_height = 0.0
    var title_width = 0.0
    
    // constants for DIN A4 PDF page
    let dinA4_width = 595.2
    let dinA4_height = 841.8
    
    // constants for US letter PDF page
    let usLetter_width = 612.0
    let usLetter_height = 792.0
    
    // margin from left
    let left_margin = 30.0
    let right_margin = 30.0
    
    // pdf footer position
    var footer_pos_x = 0.0
    var footer_pos_y = 0.0
    
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
        
        // paper size to DinA4
        // initialize paper size and stuff
        pdfInit(paperSize: PaperSize.dinA4)
    }
    
    // fetch all inventory sorted by item name
    private func inventoryFetchRequest() -> NSFetchRequest<Inventory> {
        let fetchRequest:NSFetchRequest<Inventory> = Inventory.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]
        
        return fetchRequest
    }
    
    // MARK: - Actions
    @IBAction func generatePDF(_ sender: Any) {
        
        pdfCreate()
    }
    
    // MARK: - PDF functions
    // setup paper dimensions
    // correct position for page numbers etc
    // constants for DIN A4 PDF page
    // dinA4_width = 595.2
    // dinA4_height = 841.8
    //
    // constants for US letter PDF page
    // usLetter_width = 612.0
    // usLetter_height = 792.0
    //
    func pdfInit(paperSize: PaperSize){
        switch (paperSize){
        case .dinA4:
            paper_width = dinA4_width
            paper_height = dinA4_height
            
            pageNumber_pos_x = dinA4_width - 140.0
            pageNumber_pos_y = dinA4_height - 20
            
            title_pos_x = left_margin
            title_pos_y = 20.0
            title_width = 300.0
            title_height = 30.0
            
            footer_pos_x = left_margin
            footer_pos_y = dinA4_height - 20.0
            break
            
        case .usLetter:
            paper_width = usLetter_width
            paper_height = usLetter_height
            
            pageNumber_pos_x = usLetter_width - 140.0
            pageNumber_pos_y = usLetter_height - 20
            
            title_pos_x = left_margin
            title_pos_y = 20.0
            title_width = 300.0
            title_height = 30.0
            
            footer_pos_x = left_margin
            footer_pos_y = usLetter_height - 20.0
            break
        }
    }
    
    // generate title for pdf page
    func pdfPageTitleHeading(title: String, fontSize: CGFloat, context: UIGraphicsRendererContext){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let font = UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let text = title as NSString
        text.draw(in: CGRect(x: title_pos_x, y: title_pos_y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        
        // draw a line
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(2)
        context.cgContext.move(to: CGPoint(x: left_margin, y: 20))
        context.cgContext.addLine(to: CGPoint(x: paper_width - right_margin, y: 20))
        context.cgContext.drawPath(using: .fillStroke)
    }
    
    // generate pdf page number
    func pdfPageNumber(pageNumber: Int){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        
        let font = UIFont(name: "HelveticaNeue", size: 8.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let page = NSLocalizedString("Page", comment: "Page")
        let text = page + " " + String(pageNumber) as NSString
        text.draw(in: CGRect(x: pageNumber_pos_x, y: pageNumber_pos_y, width: 110, height: 20), withAttributes: attributes as [NSAttributedString.Key : Any])
    }
    
    // generate pdf page footer
    func pdfPageFooter(footerText: String, context: UIGraphicsRendererContext){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let font = UIFont(name: "HelveticaNeue", size: 8.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let text = footerText as NSString
        text.draw(in: CGRect(x: footer_pos_x, y: footer_pos_y, width: 300, height: 10), withAttributes: attributes as [NSAttributedString.Key : Any])
        
        // draw a line
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(2)
        context.cgContext.move(to: CGPoint(x: footer_pos_x, y: paper_height - 30))
        context.cgContext.addLine(to: CGPoint(x: paper_width - right_margin, y: footer_pos_y - 10))
        context.cgContext.drawPath(using: .fillStroke)
    }
    
    // generate the PDF document containing all pages, header, footer, page number etc.
    func pdfCreate(){
        
        var y = 0.0 // Points from above
        var x = 0.0 // Points form left
        var width = 0.0 // length of rect
        var height = 0.0 // height of rect
        var stringRect = CGRect(x: x, y: y, width: width, height: height) // make rect for text
        let paragraphStyle = NSMutableParagraphStyle() // text alignment
        let font = UIFont(name: "HelveticaNeue", size: 10.0) // Important: the font name must be written correct
        var text = ""
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [ kCGPDFContextAuthor as String : Global.appNameString ]      // doc author
        format.documentInfo = [ kCGPDFContextCreator as String : Global.appNameString ]
        format.documentInfo = [ kCGPDFContextTitle as String: Global.appNameString ]         // document title
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: paper_width, height: paper_height), format: format)
        
        // create elements of pdf
        let pdf = renderer.pdfData { (context) in
            context.beginPage()
            
            // Title
            pdfPageTitleHeading(title: "Inventory Report", fontSize: 25.0, context: context)
            
            y = 50
            // contents
            for i in 1...49{
                y = y + 15 // distance to above because is title
                x = 30; width = 120; height = 20
                stringRect = CGRect(x: x, y: y, width: width, height: height)
                text = "Zeile: " + String(i) + " Spalte 1: " + String(y)
                text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                
                x = 150; width = 120; height = 20
                stringRect = CGRect(x: x, y: y, width: width, height: height)
                text = "Zeile: " + String(i) + " Spalte 2: " + String(y)
                text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            }
 /*
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
            } */
            
            pdfPageFooter(footerText: "generated by Inventory app (c) 2019 Marcus Deuß", context: context)
            pdfPageNumber(pageNumber: 1)
         
            for page in 2...4 {
                context.beginPage()
                // Title
                pdfPageTitleHeading(title: "Inventory Report", fontSize: 25.0, context: context)
                
                pdfPageFooter(footerText: "generated by Inventory app (c) 2019 Marcus Deuß", context: context)
                
                pdfPageNumber(pageNumber: page)
            }
        }
        
        // save PDF to documents directory
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last as NSURL?
        
        docURL = docURL?.appendingPathComponent( "myFileName.pdf") as NSURL?
        //let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        do {
            try pdf.write(to: docURL! as URL, options: .atomic)
            print("pdf successfully saved!")
        } catch {
            print("Pdf could not be saved")
        }
    }
    
    // old stuff for HTML
    
    
    // create a DIN A based PDF file requires CoreGraphics because pdfkit only allows for displaying PDF files
    private func createPDFHTML(filename: String, text: String) {
        os_log("ReportViewController createPDF", log: Log.viewcontroller, type: .info)
        
        let formatter = UIMarkupTextPrintFormatter(markupText: text)
        
        // Add formatter with pageRender
        
        let renderer = UIPrintPageRenderer()
        
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        
        // Assign paperRect and printableRect
        
        let page = CGRect(x: 0, y: 0, width: dinA4_width, height: dinA4_height) // A4, 72 dpi
        
        // Use this to get US Letter size instead
        // let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let printable = page.insetBy(dx: 0, dy: 0)
        
        renderer.setValue(NSValue(cgRect: page), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        // Create PDF context and draw
        let pageRect = CGRect.zero
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        
        for i in 1...renderer.numberOfPages {
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            
            renderer.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        pdfData.write(toFile: "\(documentsPath)/\(filename).pdf", atomically: true)
        
        //pdftest()
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
}
