//
//  ReportViewController.swift
//  Inventory
//
//  contains all reports that will be generated via HMTL and then PDF for further use
//  Created by Marcus Deuß on 05.04.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit
import PDFKit
import CoreData
import MessageUI
import os

class ReportViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var paperFormatSegment: UISegmentedControl!
    @IBOutlet weak var sortOrderSegment: UISegmentedControl!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var roomsSegment: UISegmentedControl!
    @IBOutlet weak var ownersSegment: UISegmentedControl!
    @IBOutlet weak var roomFilterLabel: UILabel!
    @IBOutlet weak var ownerFilterLabel: UILabel!
    @IBOutlet weak var shareActionBarButton: UIBarButtonItem!
    @IBOutlet weak var emailActionButton: UIBarButtonItem!
    
    
    // get all detail infos
    var rooms : [Room] = []
    var brands : [Brand] = []
    var owners : [Owner] = []
    var categories : [Category] = []
    
    // handle different paper sizes
    enum PaperSize {
        case dinA4
        case usLetter
    }
    
    var url : URL?
    
    var currentPaperSize = PaperSize.dinA4
    
    // handle sort order
    enum SortOrder : String{
        case item = "inventoryName"
        case category = "inventoryCategory.categoryName"
        case owner = "inventoryOwner.ownerName"
        case room = "inventoryRoom.roomName"
    }
    
    var currentSortOrder = SortOrder.item
    
    // get user name and house name from iCloud
    let kvStore = NSUbiquitousKeyValueStore()
    
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
    
    // column
    let column_width = 110.0
    let column_height = 20.0
    
    // text contents begin
    let contents_begin = 50.0
    
    // margin from left
    let left_margin = 30.0
    let right_margin = 30.0
    
    // pdf footer position
    var footer_pos_x = 0.0
    var footer_pos_y = 0.0
    
    // store complete inventory as array
    var results: [Inventory] = []
    
    // MARK: view load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("ReportViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        // Do any additional setup after loading the view.
        // new in ios11: large navbar titles
        // new in ios11: large navbar titles
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationItem.largeTitleDisplayMode = .always
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.title = NSLocalizedString("Reports", comment: "Reports")
        
        let segmentDinA4 = NSLocalizedString("DIN A4", comment: "DIN A4")
        let segmentUsLetter = NSLocalizedString("US Letter", comment: "US Letter")
        replaceSegmentContents(segments: [segmentDinA4, segmentUsLetter], control: paperFormatSegment)
        paperFormatSegment.selectedSegmentIndex = 0 // default din A4
        
        let sortItem = NSLocalizedString("Item", comment: "Item")
        let sortCategory = NSLocalizedString("Category", comment: "Category")
        let sortOwner = NSLocalizedString("Owner", comment: "Owner")
        let sortRoom = NSLocalizedString("Room", comment: "Room")
        replaceSegmentContents(segments: [sortItem, sortCategory, sortOwner, sortRoom], control: sortOrderSegment)
        sortOrderSegment.selectedSegmentIndex = 0 // default sort by item
        
        // initialize paper size and stuff
        pdfInit()
    }
    
    // refresh user info every time we come back here
    // This is called every time the view is about to appear, whether or not the view is already in memory.
    // Put your dynamic code here, such as model logic
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        os_log("ReportViewController viewWillAppear", log: Log.viewcontroller, type: .info)
        
        // no pdf document still
        if pdfView.document == nil{
            shareActionBarButton.isEnabled = false
            emailActionButton.isEnabled = false
        }
        // get the data from Core Data
        rooms = CoreDataHandler.fetchAllRooms()
        brands = CoreDataHandler.fetchAllBrands()
        owners = CoreDataHandler.fetchAllOwners()
        categories = CoreDataHandler.fetchAllCategories()
        
        var listOwners :[String] = []
        var listRooms :[String] = []
        
        // FIXME tranlation needed
        let allOwners = NSLocalizedString("All", comment: "All")
        listOwners.append(allOwners)
        for owner in owners{
            listOwners.append((owner.ownerName)!)
        }
        
        replaceSegmentContents(segments: listOwners, control: ownersSegment)
        ownersSegment.selectedSegmentIndex = 0
        
        let allRooms = NSLocalizedString("All", comment: "All")
        listRooms.append(allRooms)
        for room in rooms{
            listRooms.append((room.roomName)!)
        }
        
        replaceSegmentContents(segments: listRooms, control: roomsSegment)
        roomsSegment.selectedSegmentIndex = 0
        // register tap gesture with pdf view
        
        // set to "All" default
        roomFilterLabel.text = listRooms.first
        ownerFilterLabel.text = listOwners.first
        
        pdfViewGestureWhenTapped()
    }
    
    // fill a segment controll with values
    func replaceSegmentContents(segments: Array<String>, control: UISegmentedControl) {
        control.removeAllSegments()
        for segment in segments {
            control.insertSegment(withTitle: segment, at: control.numberOfSegments, animated: false)
        }
    }
    
    // fetch all inventory sorted by sortOrder
    private func inventoryFetchRequest(sortOrder: String) -> NSFetchRequest<Inventory> {
        os_log("ReportViewController inventoryFetchRequest", log: Log.viewcontroller, type: .info)
        
        let fetchRequest:NSFetchRequest<Inventory> = Inventory.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortOrder, ascending: true)]
        
        return fetchRequest
    }
    
    // share a PDF file to iOS: print, save to file
    func sharePdf(path: URL) {
        os_log("ReportViewController sharePdf", log: Log.viewcontroller, type: .info)
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: path.path) {
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            os_log("ReportViewController sharePdf", log: Log.viewcontroller, type: .error)
            
            let error = NSLocalizedString("Error", comment: "Error")
            let message = NSLocalizedString("Document was not found!", comment: "Document was not found!")
            let alertController = UIAlertController(title: error, message: message, preferredStyle: .alert)
            let ok = NSLocalizedString("OK", comment: "OK")
            let defaultAction = UIAlertAction.init(title: ok, style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(defaultAction)
            navigationController!.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func emailActionButton(_ sender: UIBarButtonItem) {
        sendPDFEmail()
    }
    
    // sharing PDF for print or email
    @IBAction func shareActionBarButton(_ sender: UIBarButtonItem) {
        os_log("ReportViewController shareActionBarButton", log: Log.viewcontroller, type: .info)
        
        sharePdf(path: url!)
    }
    
    @IBAction func roomsSegmentAction(_ sender: UISegmentedControl) {
        os_log("ReportViewController roomsSegmentAction", log: Log.viewcontroller, type: .info)
        
        roomFilterLabel.text = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
    }
    
    @IBAction func ownersSegmentAction(_ sender: UISegmentedControl) {
        os_log("ReportViewController ownersSegmentAction", log: Log.viewcontroller, type: .info)
        
        ownerFilterLabel.text = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
    }
    
    
    // button will be used dynamically based on selected sort order
    @IBAction func filterButtonAction(_ sender: UIButton) {
        os_log("ReportViewController filterButtonAction", log: Log.viewcontroller, type: .info)
        
        let title = NSLocalizedString("Room", comment: "Room")
        let message = NSLocalizedString("Choose your room", comment: "Choose your room")
        
        let myActionSheet = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)
        
        for room in rooms{
            let action = UIAlertAction(title: room.roomName, style: UIAlertAction.Style.default) { (ACTION) in
                //self.currentInventory?.inventoryRoom? = room
                //self.roomButtonLabel.setTitle(self.currentInventory?.inventoryRoom?.roomName!, for: UIControl.State.normal)
            }
            myActionSheet.addAction(action)
        }
        
        let cancel = NSLocalizedString("Cancel", comment: "Cancel")
        let action = UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
            // do nothing when cancel
        }
        
        myActionSheet.addAction(action)
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    @IBAction func generatePDF(_ sender: Any) {
        
        // core data contents
        
        let context = CoreDataHandler.getContext()
        
        do {
            results = try context.fetch(self.inventoryFetchRequest(sortOrder: currentSortOrder.rawValue))
        } catch _ as NSError {
            os_log("ReportViewController context.fetch", log: Log.viewcontroller, type: .error)
            //print("ERROR: \(error.localizedDescription)")
        }
        
        pdfCreateInventoryReport()
        shareActionBarButton.isEnabled = true
        emailActionButton.isEnabled = true
    }
    
    @IBAction func paperFormatSegmentAction(_ sender: UISegmentedControl) {
        os_log("ReportViewController paperFormatSegmentAction", log: Log.viewcontroller, type: .info)
        
        switch paperFormatSegment.selectedSegmentIndex
        {
        case 0:
            currentPaperSize = .dinA4
        case 1:
            currentPaperSize = .usLetter
        default:
            break
        }
    }
    
    @IBAction func sortOrderSegmentAction(_ sender: UISegmentedControl) {
        os_log("ReportViewController sortOrderSegmentAction", log: Log.viewcontroller, type: .info)
        
        switch sortOrderSegment.selectedSegmentIndex
        {
        case 0:
            currentSortOrder = .item
        case 1:
            currentSortOrder = .category
        case 2:
            currentSortOrder = .owner
        case 3:
            currentSortOrder = .room
        default:
            break
        }
    }
    
    // prepare to transfer data to PDF view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if segue.identifier == "fullscreenPDF" {
            let destination =  segue.destination as! PDFViewController
            destination.currentPDF = pdfView
            destination.currentTitle = NSLocalizedString("PDF Report", comment: "PDF Report")
        }
        
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
    func pdfInit(){
        os_log("ReportViewController pdfInit", log: Log.viewcontroller, type: .info)
        
        switch (currentPaperSize){
        case .dinA4:
            paper_width = dinA4_width
            paper_height = dinA4_height
            
            pageNumber_pos_x = dinA4_width - 140.0
            pageNumber_pos_y = dinA4_height - 20
            
            title_pos_x = left_margin
            title_pos_y = 20.0
            title_width = 500.0
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
            title_width = 500.0
            title_height = 30.0
            
            footer_pos_x = left_margin
            footer_pos_y = usLetter_height - 20.0
            break
        }
    }
    
    // generate user info for pdf page (on top rigth position of page)
    func pdfPageUserInfo(userName: String, houseName: String){
        os_log("ReportViewController pdfPageUserInfo", log: Log.viewcontroller, type: .info)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        
        let font = UIFont(name: "HelveticaNeue", size: 8.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let user = NSLocalizedString("User", comment: "User")
        let house = NSLocalizedString("House", comment: "House")
        let text1 = user + ": " + userName + ", " + house + ": " + houseName
        let text = text1 as NSString
        
        text.draw(in: CGRect(x: paper_width - 250 - left_margin, y: title_pos_y + 15, width: 250, height: 20), withAttributes: attributes as [NSAttributedString.Key : Any])
    }
    
    // generate title for pdf page (on top of each page)
    func pdfPageTitleHeading(title: String, fontSize: CGFloat, context: UIGraphicsRendererContext){
        os_log("ReportViewController pdfPageTitleHeading", log: Log.viewcontroller, type: .info)
        
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
        context.cgContext.move(to: CGPoint(x: left_margin, y: 20 + title_height))
        context.cgContext.addLine(to: CGPoint(x: paper_width - right_margin, y: 20 + title_height))
        context.cgContext.drawPath(using: .fillStroke)
    }
    
    // generate pdf page number
    func pdfPageNumber(pageNumber: Int){
        os_log("ReportViewController pdfPageNumber", log: Log.viewcontroller, type: .info)
        
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
        os_log("ReportViewController pdfPageFooter", log: Log.viewcontroller, type: .info)
        
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
    
    
    // generate pdf pdfTableHeader
    func pdfTableHeader(context: UIGraphicsRendererContext){
        os_log("ReportViewController pdfTableHeader", log: Log.viewcontroller, type: .info)
        
        var y = 0.0 // Points from above
        var x = 0.0 // Points form left
        var stringRect = CGRect(x: 0, y: 0, width: 0, height: 0) // make rect for text
        var text = ""
        
        y = contents_begin + 15
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let font = UIFont(name: "HelveticaNeue-Bold", size: 10.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let columnText : [String] = [NSLocalizedString("Item", comment: "Item"), NSLocalizedString("Owner", comment: "Owner"), NSLocalizedString("Room", comment: "Room"), NSLocalizedString("Category", comment: "Category"), NSLocalizedString("Price", comment: "Price")]
        
        x = left_margin
        for column in columnText{
            stringRect = CGRect(x: x, y: y, width: column_width, height: column_height)
            text = column
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + column_width
        }
        
        // draw a line
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(1)
        context.cgContext.move(to: CGPoint(x: left_margin, y: 48 + title_height))
        context.cgContext.addLine(to: CGPoint(x: (Double(columnText.count) * column_width), y: 48 + title_height))
        context.cgContext.drawPath(using: .fillStroke)
    }
    
    // save the pdf to disk
    func pdfSave(_ pdf: Data) -> URL{
        // save PDF to documents directory
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last as NSURL?
        
        docURL = docURL?.appendingPathComponent(Global.pdfFile) as NSURL?
        //let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        do {
            try pdf.write(to: docURL! as URL, options: .atomic)
            os_log("ReportViewController pdfSave successfull", log: Log.viewcontroller, type: .info)
        } catch {
            os_log("ReportViewController pdfSave error", log: Log.viewcontroller, type: .error)
        }
        
        return docURL! as URL
    }
    
    // generate the PDF document containing all pages, header, footer, page number etc.
    func pdfCreateInventoryReport(){
        os_log("ReportViewController pdfCreateInventoryReport", log: Log.viewcontroller, type: .info)
        
        var y = 0.0 // Points from above
        var x = 0.0 // Points form left
        var stringRect = CGRect(x: 0, y: 0, width: 0, height: 0) // make rect for text
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
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateStyle = DateFormatter.Style.short
        
        dateformatter.timeStyle = DateFormatter.Style.short
        
        let now = dateformatter.string(from: Date())
        let tmp = NSLocalizedString("generated by Inventory (c) 2019 Marcus Deuß", comment: "generated by Inventory (c) 2019 Marcus Deuß")
        let footerText = tmp + ", " + now
        
        var paperPrintableRows : Int
        
        // decide paper size, because printable rows are different
        switch (currentPaperSize){
        case .dinA4:
            paperPrintableRows = 47
            break
        case .usLetter:
            paperPrintableRows = 46
            break
        }
        
        // create elements of pdf
        var numberOfPages = 0
        let pdf = renderer.pdfData { (context) in
            context.beginPage()
            
            numberOfPages += 1
            
            // Title
            let title = NSLocalizedString("Inventory Report", comment: "Inventory Report")
            pdfPageTitleHeading(title: title, fontSize: 25.0, context: context)
            
            // user Info
            pdfPageUserInfo(userName: UserInfo.userName, houseName: UserInfo.houseName)
            
            y = contents_begin
            // contents
            
            // columns
            pdfTableHeader(context: context)
            y = y + 15
            
            var numberOfRows = 0
            
            for inv in results{
                y = y + 15 // distance to above because is title
                numberOfRows += 1
                
                let columnText : [String] = [inv.inventoryName!, inv.inventoryOwner!.ownerName!, inv.inventoryRoom!.roomName!, inv.inventoryCategory!.categoryName!, String(inv.price)]
                
                x = left_margin
                for column in columnText{
                    stringRect = CGRect(x: x, y: y, width: column_width, height: column_height)
                    text = column
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + column_width
                }
                
                // current layout fits 49 rows in one page with dinA4, 47 rows in USLetter
                if numberOfRows > paperPrintableRows{
                    numberOfRows = 1
                    y = contents_begin
                    
                    pdfPageFooter(footerText: footerText, context: context)
                    pdfPageNumber(pageNumber: numberOfPages)
                    numberOfPages += 1
                    
                    context.beginPage()
                    // title
                    pdfPageTitleHeading(title: title, fontSize: 25.0, context: context)
                    // user Info
                    pdfPageUserInfo(userName: UserInfo.userName, houseName: UserInfo.houseName)
                }
            }
            
            pdfPageFooter(footerText: footerText, context: context)
            pdfPageNumber(pageNumber: numberOfPages)
        }
        
        // save report to temp dir
        url = pdfSave(pdf)
        pdfDisplay(file: url!)
    }
    
    // display pdf file from chosen URL
    func pdfDisplay(file: URL){
        if let pdfDocument = PDFDocument(url: file) {
            pdfView.autoScales = true
            pdfView.displayMode = .singlePageContinuous
            pdfView.displayDirection = .vertical
            pdfView.document = pdfDocument
            
            //currentInventory?.invoice = pdfView.document!.dataRepresentation()! as NSData?
            //currentInventory?.invoiceFileName = generateFilename(invname: currentInventory!.inventoryName!) + ".pdf" // FIXME crashes when new object, works with existing object to attach a pdf
            // show thumbnail as well
            //captureThumbnails(pdfDocument:pdfDocument)
        }
    }
    
    // use this method in viewDidLoad to enable tap gesture
    func pdfViewGestureWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReportViewController.gestureAction))
        tap.cancelsTouchesInView = false
        // register tap with pdfview only
        pdfView.addGestureRecognizer(tap)
    }
    
    @objc func gestureAction() {
        os_log("ReportViewController action", log: Log.viewcontroller, type: .info)
        
        // show image view fullscreen
        performSegue(withIdentifier: "fullscreenPDF", sender: nil)
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
    
    /*
     // MARK: - Email delegate
     */
    
    /// Prepares mail sending controller
    ///
    /// **Extremely** important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
    /// - Returns: mailComposerVC
    
    func sendPDFEmail(){
        // hide keyboard
        self.view.endEditing(true)
        
        let mailComposeViewController = configuredMailComposeViewController(url: url)
        
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else
        {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController(url: URL?) -> MFMailComposeViewController
    {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        //mailComposerVC.setToRecipients([Global.emailAdr])
        let support = NSLocalizedString("Support", comment: "Support")
        mailComposerVC.setSubject(Global.appNameString + " " + (Global.versionString) + " " + support)
        let msg = NSLocalizedString("My Inventory Report", comment: "My Inventory Report")
        mailComposerVC.setMessageBody(msg, isHTML: false)
        
        // attachment
        if url != nil{
            do{
            let attachmentData = try Data(contentsOf: url!)
            mailComposerVC.addAttachmentData(attachmentData, mimeType: "application/pdf", fileName: Global.pdfFile)
            }
            catch let error {
                os_log("ReportViewController email attachement error: %s", log: Log.viewcontroller, type: .error, error.localizedDescription)
            }
        }
        
        return mailComposerVC
    }
    
    /// show error if mail sending does not work
    func showSendMailErrorAlert()
    {
        let msg = NSLocalizedString("Email could not be sent", comment: "Email could not be sent")
        let msg2 = NSLocalizedString("Your device could not send email", comment: "Your device could not send email")
        
        let alert = UIAlertController(title: msg, message: msg2, preferredStyle: .alert)
        
        let msg3 = NSLocalizedString("Please check your email configuration", comment: "Please check your email configuration")
        
        alert.addAction(UIAlertAction(title: msg3, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
        //let sendMailErrorAlert = UIAlertView(title: "Email konnte nicht gesendet werden", message: "Ihr Gerät konnte keine Email senden.  Bitte Email Konfiguration prüfen.", delegate: self, cancelButtonTitle: "OK")
        
        //alert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }

}
