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

class ReportViewController: UIViewController, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var paperFormatSegment: UISegmentedControl!
    @IBOutlet weak var sortOrderSegment: UISegmentedControl!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var roomsSegment: UISegmentedControl!
    @IBOutlet weak var ownersSegment: UISegmentedControl!
    @IBOutlet weak var roomFilterLabel: UILabel!
    @IBOutlet weak var ownerFilterLabel: UILabel!
    @IBOutlet weak var shareActionBarButton: UIBarButtonItem!
    @IBOutlet weak var emailActionButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var helpButton: UIButton!
    
    // get all detail infos
    var rooms : [Room] = []
    var brands : [Brand] = []
    var owners : [Owner] = []
    var categories : [Category] = []
    
    var all : String = ""
    
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
    
    // get user name and address from iCloud
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
    
    // text column size
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
    
    // inventory app logo appearing on oage
    let logoSizeHeight = 35.0
    let logoSizeWidth = 35.0
    let logoPosX = 30.0
    let logoPosY = 10.0
    
    // image size for inventory object
    let imageSizeWidth = 30.0
    let imageSizeHeight = 30.0
    var imageSizePosX = 0.0
    
    
    // store complete inventory as array
    var results: [Inventory] = []
    
    // MARK: view load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // compute image start position
        imageSizePosX = column_width - imageSizeWidth + 20
        
        //os_log("ReportViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        // https://medium.com/@luisfmachado/uiscrollview-autolayout-on-a-storyboard-a-step-by-step-guide-15bd67ee79e9
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+500)
        
        all = Global.all
        
        // set colors for UI elements
        roomsSegment.tintColor = themeColorUIControls
        ownersSegment.tintColor = themeColorUIControls
        sortOrderSegment.tintColor = themeColorUIControls
        paperFormatSegment.tintColor = themeColorUIControls
        shareActionBarButton.tintColor =  themeColorUIControls
        emailActionButton.tintColor = themeColorUIControls
        
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
        
        replaceSegmentContents(segments: [Global.item, Global.category, Global.owner, Global.room], control: sortOrderSegment)
        sortOrderSegment.selectedSegmentIndex = 0 // default sort by item
        
        // initialize paper size and stuff
        pdfInit()
    }
    
    // refresh user info every time we come back here
    // This is called every time the view is about to appear, whether or not the view is already in memory.
    // Put your dynamic code here, such as model logic
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //os_log("ReportViewController viewWillAppear", log: Log.viewcontroller, type: .info)
        
 /*       // no pdf document still
        if pdfView.document == nil{
            shareActionBarButton.isEnabled = false
            emailActionButton.isEnabled = false
        } */
        // get the data from Core Data
        rooms = CoreDataHandler.fetchAllRooms()
        brands = CoreDataHandler.fetchAllBrands()
        owners = CoreDataHandler.fetchAllOwners()
        categories = CoreDataHandler.fetchAllCategories()
        
        var listOwners :[String] = []
        var listRooms :[String] = []
        
        let allOwners = all
        listOwners.append(allOwners)
        for owner in owners{
            listOwners.append((owner.ownerName)!)
        }
        
        replaceSegmentContents(segments: listOwners, control: ownersSegment)
        ownersSegment.selectedSegmentIndex = 0
        
        let allRooms = all
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
        
        // refresh data from core data
        fetchData()
        
        // create the pdf report based on selected sort order and filter choice
        pdfCreateInventoryReport()
    }
    
    // fill a segment controll with values
    func replaceSegmentContents(segments: Array<String>, control: UISegmentedControl) {
        control.removeAllSegments()
        for segment in segments {
            control.insertSegment(withTitle: segment, at: control.numberOfSegments, animated: false)
        }
    }
    
    // fetch all inventory sorted by sortOrder
    private func inventoryFetchRequest(sortOrder: String, filterWhere: String, filterCompare1: String, filterCompare2: String) -> NSFetchRequest<Inventory> {
        //os_log("ReportViewController inventoryFetchRequest", log: Log.viewcontroller, type: .info)
        
        let request:NSFetchRequest<Inventory> = Inventory.fetchRequest()
        
        // search predicate only when filter is used, otherwise no predicate
        if(filterWhere.count > 0){
            request.predicate = NSPredicate(format: filterWhere, filterCompare1, filterCompare2)
        }
        
        //print(request.predicate.debugDescription)
        
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: sortOrder, ascending: true)]
        
        return request
    }
    
    // fetch all inventory sorted by sortOrder
    private func inventoryFetchRequest(sortOrder: String, filterWhere: String, filterCompare: String) -> NSFetchRequest<Inventory> {
        //os_log("ReportViewController inventoryFetchRequest", log: Log.viewcontroller, type: .info)
        
        let request:NSFetchRequest<Inventory> = Inventory.fetchRequest()
        
        // search predicate only when filter is used, otherwise no predicate
        if(filterWhere.count > 0){
            request.predicate = NSPredicate(format: filterWhere, filterCompare)
        }
        
        //print(request.predicate.debugDescription)
        
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: sortOrder, ascending: true)]
        
        return request
    }
    
    // get core data bases on selected filter and sort order
    func fetchData(){
        // core data contents
        
        //var filterWhere : String = ""
        //var filterCompare : [String] = []
        
        let context = CoreDataHandler.getContext()
        
        if ownerFilterLabel.text! != all && roomFilterLabel.text! != all{
            // use both room and owner as filter criteria
            let filterWhere = "inventoryOwner.ownerName == %@ && inventoryRoom.roomName == %@"
            let filterCompare1 = ownerFilterLabel.text!
            let filterCompare2 = roomFilterLabel.text!
            
            do {
                results = try context.fetch(self.inventoryFetchRequest(sortOrder: currentSortOrder.rawValue, filterWhere: filterWhere, filterCompare1: filterCompare1, filterCompare2: filterCompare2))
            } catch{
                os_log("ReportViewController context.fetch", log: Log.viewcontroller, type: .error)
            }
        }
        else{
            if ownerFilterLabel.text! == all && roomFilterLabel.text! != all{
                // use filter for room only
                let filterWhere = "inventoryRoom.roomName == %@"
                let filterCompare = roomFilterLabel.text!
                
                do {
                    results = try context.fetch(self.inventoryFetchRequest(sortOrder: currentSortOrder.rawValue, filterWhere: filterWhere, filterCompare: filterCompare))
                } catch{
                    os_log("ReportViewController context.fetch", log: Log.viewcontroller, type: .error)
                }
            }
            else{
                if ownerFilterLabel.text! == all && roomFilterLabel.text! == all{
                    // no filter used
                    let filterWhere = ""
                    let filterCompare = ""
                    do {
                        results = try context.fetch(self.inventoryFetchRequest(sortOrder: currentSortOrder.rawValue, filterWhere: filterWhere, filterCompare: filterCompare))
                    } catch{
                        os_log("ReportViewController context.fetch", log: Log.viewcontroller, type: .error)
                    }
                }
                else{
                    // use filter for owner only
                    let filterWhere = "inventoryOwner.ownerName == %@"
                    let filterCompare = String(ownerFilterLabel.text!)
                    
                    do {
                        results = try context.fetch(self.inventoryFetchRequest(sortOrder: currentSortOrder.rawValue, filterWhere: filterWhere, filterCompare: filterCompare))
                    } catch{
                        os_log("ReportViewController context.fetch", log: Log.viewcontroller, type: .error)
                    }
                }
            }
        }
    }
    
    // share a PDF file to iOS: print, save to file
    func sharePdf(path: URL) {
        //os_log("ReportViewController sharePdf", log: Log.viewcontroller, type: .info)
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: path.path) {
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            os_log("ReportViewController sharePdf", log: Log.viewcontroller, type: .error)
            
            let alertController = UIAlertController(title: Global.error, message: Global.documentNotFound, preferredStyle: .alert)
            let defaultAction = UIAlertAction.init(title: Global.ok, style: UIAlertAction.Style.default, handler: nil)
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
        //os_log("ReportViewController shareActionBarButton", log: Log.viewcontroller, type: .info)
        
        sharePdf(path: url!)
    }
    
    @IBAction func roomsSegmentAction(_ sender: UISegmentedControl) {
        //os_log("ReportViewController roomsSegmentAction", log: Log.viewcontroller, type: .info)
        
        roomFilterLabel.text = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
        
        // refresh data from core data
        fetchData()
        
        // create the pdf report based on selected sort order and filter choice
        pdfCreateInventoryReport()
    }
    
    @IBAction func ownersSegmentAction(_ sender: UISegmentedControl) {
        //os_log("ReportViewController ownersSegmentAction", log: Log.viewcontroller, type: .info)
        
        ownerFilterLabel.text = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
        
        // refresh data from core data
        fetchData()
        
        // create the pdf report based on selected sort order and filter choice
        pdfCreateInventoryReport()
    }
    
    @IBAction func paperFormatSegmentAction(_ sender: UISegmentedControl) {
        //os_log("ReportViewController paperFormatSegmentAction", log: Log.viewcontroller, type: .info)
        
        switch paperFormatSegment.selectedSegmentIndex
        {
        case 0:
            currentPaperSize = .dinA4
            // refresh data from core data
            fetchData()
            
            // create the pdf report based on selected sort order and filter choice
            pdfCreateInventoryReport()
        case 1:
            currentPaperSize = .usLetter
            // refresh data from core data
            fetchData()
            
            // create the pdf report based on selected sort order and filter choice
            pdfCreateInventoryReport()
        default:
            break
        }
    }
    
    @IBAction func sortOrderSegmentAction(_ sender: UISegmentedControl) {
        //os_log("ReportViewController sortOrderSegmentAction", log: Log.viewcontroller, type: .info)
        
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
        
        // refresh data from core data
        fetchData()
        
        // create the pdf report based on selected sort order and filter choice
        pdfCreateInventoryReport()
    }
    
    // prepare to transfer data to PDF view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "fullscreenPDF" {
            let destination =  segue.destination as! PDFViewController
            destination.currentPDF = pdfView
            destination.currentTitle = NSLocalizedString("Inventory Report (PDF)", comment: "Inventory Report (PDF)")
            destination.currentPath = url
        }
        
        // show popover window
        if segue.identifier == "reportPopover"{
            if let dest = segue.destination as? PopupViewController,
                let popPC = dest.popoverPresentationController,
                let btn = sender as? UIButton
            {
                // where should the arrow be allowed
                // popPC.permittedArrowDirections = [.up, .left]
                popPC.permittedArrowDirections = [.up]
                popPC.sourceRect = btn.bounds
                popPC.delegate = self
                
                // here goes the popup text
                var fileName : String
                
                switch Global.currentLocaleForDate(){
                case "de_DE", "de_AT", "de_CH", "de":
                    fileName = "Reportview Help German"
                    break
                    
                default: // all other languages get english text
                    fileName = "Reportview Help English"
                    break
                }
                
                dest.myText = Global.getRTFFileFromBundle(fileName: fileName)
            }

        }
        
    }
    
    // needed for popup controller, needed for iPhone compatability
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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
        //os_log("ReportViewController pdfInit", log: Log.viewcontroller, type: .info)
        
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
    
    // print the app logo on every page
    func pdfImageLogo(){
        let image = UIImage(named: "InventorySplash.jpg")
        image!.draw(in: CGRect(x: logoPosX, y: logoPosY, width: logoSizeHeight, height: logoSizeWidth))
    }
    
    // print the inventory image next to inventory name if available
    func pdfImageForIntenvory(yPos: Double, imageData: NSData?){
        
        guard (imageData != nil) else{
            return
        }
        
        //let imageData = currentInventory!.image! as Data
        if let image = UIImage(data: imageData! as Data, scale: 0.1){
        
            //let image = UIImage(named: imageName)
            image.draw(in: CGRect(x: imageSizePosX, y: yPos, width: imageSizeWidth, height: imageSizeHeight))
        }
        // otherwise do nothing since to image available
    }
    
    // add a summary page at the end of the PDF report
    func pdfSummaryPage(numberOfRows: Int, context: UIGraphicsRendererContext){
        //os_log("ReportViewController pdfPageUserInfo", log: Log.viewcontroller, type: .info)
        
        var y : Double
        
        let summary = NSLocalizedString("Summary", comment: "Summary")
        pdfPageTitleHeading(title: summary, fontSize: 25.0, context: context)
        
        // user Info
        pdfPageUserInfo(userName: UserInfo.userName, address: UserInfo.addressName)
        
        y = contents_begin
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let font = UIFont(name: "HelveticaNeue", size: 15.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        y = y + 15
        
        // switch column order based on sort order
        var sortOrderText : String
        switch (currentSortOrder){
        case .item:
            sortOrderText = NSLocalizedString("Sorted by item", comment: "Sorted by item")
            break
        case .owner:
            sortOrderText = NSLocalizedString("Sorted by owner", comment: "Sorted by owner")
            break
        case .category:
            sortOrderText = NSLocalizedString("Sorted by category", comment: "Sorted by category")
            break
        case .room:
            sortOrderText = NSLocalizedString("Sorted by room", comment: "Sorted by room")
            break
        }
        
        let printSortOrder = sortOrderText as NSString
        printSortOrder.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        
        y = y + 25
        
        let tmp = NSLocalizedString("Room filter used", comment: "Room filter used")
        if roomFilterLabel.text == Global.all{
            let printRoomFilter = tmp + ": " + Global.none as NSString
            printRoomFilter.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        else{
            let printRoomFilter = tmp + ": " + roomFilterLabel.text! as NSString
            printRoomFilter.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        
        y = y + 25
        
        let tmp2 = NSLocalizedString("Owner filter used", comment: "Owner filter used")
        if ownerFilterLabel.text == Global.all{
            let printOwnerFilter = tmp2 + ": " + Global.none as NSString
            printOwnerFilter.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        else{
            let printOwnerFilter = tmp2 + ": " + ownerFilterLabel.text! as NSString
            printOwnerFilter.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        
        y = y + 25
        
        let tmp3 = NSLocalizedString("Number of inventory items", comment: "Number of inventory item")
        let numberOfRowsText = tmp3 + ": " + String(numberOfRows)
        numberOfRowsText.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        
        y = y + 25
        
        let appInfoText = NSLocalizedString("Provided by", comment: "Provided by") + ": " + UIApplication.appName! + " " + UIApplication.appVersion!
        appInfoText.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
    }
    
    // generate user info for pdf page (on top rigth position of page)
    func pdfPageUserInfo(userName: String, address: String){
        //os_log("ReportViewController pdfPageUserInfo", log: Log.viewcontroller, type: .info)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        
        let font = UIFont(name: "HelveticaNeue", size: 8.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let userText = NSLocalizedString("User", comment: "User")
        let addressText = NSLocalizedString("Address", comment: "Address")
        let text1 = userText + ": " + userName + ", " + addressText + ": " + address
        let text = text1 as NSString
        
        text.draw(in: CGRect(x: paper_width - 250 - left_margin, y: title_pos_y + 15, width: 250, height: 20), withAttributes: attributes as [NSAttributedString.Key : Any])
    }
    
    // generate title for pdf page (on top of each page)
    func pdfPageTitleHeading(title: String, fontSize: CGFloat, context: UIGraphicsRendererContext){
        //os_log("ReportViewController pdfPageTitleHeading", log: Log.viewcontroller, type: .info)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let font = UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let text = title as NSString
        text.draw(in: CGRect(x: title_pos_x + logoSizeWidth + 10, y: title_pos_y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        
        // draw a line
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(2)
        context.cgContext.move(to: CGPoint(x: left_margin, y: 20 + title_height))
        context.cgContext.addLine(to: CGPoint(x: paper_width - right_margin, y: 20 + title_height))
        context.cgContext.drawPath(using: .fillStroke)
    }
    
    // generate pdf page number
    func pdfPageNumber(pageNumber: Int){
        //os_log("ReportViewController pdfPageNumber", log: Log.viewcontroller, type: .info)
        
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
        //os_log("ReportViewController pdfPageFooter", log: Log.viewcontroller, type: .info)
        
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
        //os_log("ReportViewController pdfTableHeader", log: Log.viewcontroller, type: .info)
        
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
        
        var columnText: [String]
        
        // switch column order based on sort order
        switch (currentSortOrder){
        case .item:
            columnText = [Global.item, Global.owner, Global.room, Global.category, Global.price]
            break
        case .owner:
            columnText = [Global.owner, Global.item, Global.room, Global.category, Global.price]
            break
        case .category:
            columnText = [Global.category, Global.item, Global.owner, Global.room,  Global.price]
            break
        case .room:
            columnText = [Global.room, Global.item, Global.owner, Global.category, Global.price]
            break
        }
        
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
        var docURL = (FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)).last as NSURL?
        
        docURL = docURL?.appendingPathComponent(Global.pdfFile) as NSURL?
        
        do {
            try pdf.write(to: docURL! as URL, options: .atomic)
            //os_log("ReportViewController pdfSave successfull", log: Log.viewcontroller, type: .info)
        } catch {
            os_log("ReportViewController pdfSave error", log: Log.viewcontroller, type: .error)
        }
        
        return docURL! as URL
    }
    
    // generate the PDF document containing all pages, header, footer, page number etc.
    func pdfCreateInventoryReport(){
        //os_log("ReportViewController pdfCreateInventoryReport", log: Log.viewcontroller, type: .info)
        
        var y = 0.0 // Points from above
        var x = 0.0 // Points form left
        var stringRect = CGRect(x: 0, y: 0, width: 0, height: 0) // make rect for text
        let paragraphStyle = NSMutableParagraphStyle() // text alignment
        paragraphStyle.alignment = .left
        let font = UIFont(name: "HelveticaNeue", size: 10.0) // Important: the font name must be written correct
        var text = ""
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [ kCGPDFContextAuthor as String : UIApplication.appName! ]      // doc author in PDF
        format.documentInfo = [ kCGPDFContextCreator as String : UIApplication.appName! ]
        format.documentInfo = [ kCGPDFContextTitle as String: UIApplication.appName! ]         // document title
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: paper_width, height: paper_height), format: format)
        
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: Global.currentLocaleForDate())
        dateformatter.dateStyle = DateFormatter.Style.short
        
        dateformatter.timeStyle = DateFormatter.Style.short
        
        let now = dateformatter.string(from: Date())
        let tmp = NSLocalizedString("generated by Inventory App (c) 2019 Marcus Deuß", comment: "generated by Inventory App (c) 2019 Marcus Deuß")
        let footerText = tmp + ", " + now
        
        var paperPrintableRows : Int
        
        // decide paper size, because printable rows are different
        switch (currentPaperSize){
        case .dinA4:
            paperPrintableRows = 19
            break
        case .usLetter:
            paperPrintableRows = 18
            break
        }
        
        // create elements of pdf
        var numberOfPages = 0
        let pdf = renderer.pdfData { (context) in
            context.beginPage()
            
            numberOfPages += 1
            
            // logo
            pdfImageLogo()
            
            // Title
            let title = NSLocalizedString("Inventory Report", comment: "Inventory Report")
            pdfPageTitleHeading(title: title, fontSize: 25.0, context: context)
            
            // user Info
            pdfPageUserInfo(userName: UserInfo.userName, address: UserInfo.addressName)
            
            y = contents_begin
            // contents
            
            // columns
            pdfTableHeader(context: context)
            y = y + 15
            
            var numberOfRows = 0
            
            for inv in results{
                y = y + 35 // distance to above because is title
                numberOfRows += 1
                
                var columnText: [String]
                
                // switch column order based on sort order
                switch (currentSortOrder){
                case .item:
                    columnText = [inv.inventoryName!, inv.inventoryOwner!.ownerName!, inv.inventoryRoom!.roomName!, inv.inventoryCategory!.categoryName!, String(inv.price) + Global.currencySymbol!]
                    break
                case .owner:
                    columnText = [inv.inventoryOwner!.ownerName!, inv.inventoryName!, inv.inventoryRoom!.roomName!, inv.inventoryCategory!.categoryName!, String(inv.price) + Global.currencySymbol!]
                    break
                case .category:
                    columnText = [inv.inventoryCategory!.categoryName!, inv.inventoryName!, inv.inventoryOwner!.ownerName!,  inv.inventoryRoom!.roomName!, String(inv.price) + Global.currencySymbol!]
                    break
                case .room:
                    columnText = [inv.inventoryRoom!.roomName!, inv.inventoryName!, inv.inventoryOwner!.ownerName!, inv.inventoryCategory!.categoryName!, String(inv.price) + Global.currencySymbol!]
                    break
                }
                
                //let columnText : [String] = [inv.inventoryName!, inv.inventoryOwner!.ownerName!, inv.inventoryRoom!.roomName!, inv.inventoryCategory!.categoryName!, String(inv.price)]
                
                x = left_margin
                for column in columnText{
                    stringRect = CGRect(x: x, y: y, width: column_width, height: column_height)
                    text = column
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + column_width
                }
                
                // print the inventory image
                pdfImageForIntenvory(yPos: y, imageData: inv.image)
                
                // current layout fits 49 rows in one page with dinA4, 47 rows in USLetter
                if numberOfRows > paperPrintableRows{
                    numberOfRows = 1
                    y = contents_begin
                    
                    pdfPageFooter(footerText: footerText, context: context)
                    pdfPageNumber(pageNumber: numberOfPages)
                    numberOfPages += 1
                    
                    context.beginPage()
                    
                    // logo
                    pdfImageLogo()
                    // title
                    pdfPageTitleHeading(title: title, fontSize: 25.0, context: context)
                    // user Info
                    pdfPageUserInfo(userName: UserInfo.userName, address: UserInfo.addressName)
                }
            }
            
            pdfPageFooter(footerText: footerText, context: context)
            pdfPageNumber(pageNumber: numberOfPages)
            
            // add a summary page at the end of the report
            context.beginPage()
            pdfImageLogo()
            pdfSummaryPage(numberOfRows: results.count, context: context)
            pdfPageFooter(footerText: footerText, context: context)
            pdfPageNumber(pageNumber: numberOfPages + 1)
            
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
            
            // scroll PDF to top
            DispatchQueue.main.async
                {
                    guard let firstPage = self.pdfView.document?.page(at: 0) else { return }
                    self.pdfView.go(to: CGRect(x: 0, y: Int.max, width: 0, height: 0), on: firstPage)
            }
            
            pdfView.document = pdfDocument
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
        //os_log("ReportViewController action", log: Log.viewcontroller, type: .info)
        
        // show image view fullscreen
        performSegue(withIdentifier: "fullscreenPDF", sender: nil)
    }
    
    
     // MARK: - Email delegate
    
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
        mailComposerVC.setSubject(UIApplication.appName! + " " + (UIApplication.appVersion!) + " " + Global.support)
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
        let alert = UIAlertController(title: Global.emailNotSent, message: Global.emailDevice, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Global.emailConfig, style: .default, handler: nil))
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
