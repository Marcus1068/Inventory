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

private let store = CoreDataStorage.shared

class ReportViewController: UIViewController, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate, UIPointerInteractionDelegate {

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
    @IBOutlet weak var imageSwitch: UISwitch!
    @IBOutlet weak var printBarButton: UIBarButtonItem!
    
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
    
    // general paper size
    var paperWidth = 0.0
    var paperHeight = 0.0
    
    // position on page to print page numbers
    var pageNumber_pos_x = 0.0
    var pageNumber_pos_y = 0.0
    
    // pdf title on page
    var title_pos_x = 0.0
    var title_pos_y = 0.0
    var title_height = 0.0
    var title_width = 0.0
    
    // constants for DIN A4 PDF page
    let dinA4Width = 595.2
    let dinA4Height = 841.8
    
    // constants for US letter PDF page
    let usLetterWidth = 612.0
    let usLetterHeight = 792.0
    
    // text column size
    // sum of all 5 columns must be 5 * 110 = 550
    let columnWidth = 110.0
    let columnHeight = 20.0
    let columnWidthItem = 130.0
    let columnWidthCategory = 90.0
    let columnWidthPrice = 60.0
    let columnWidthRoom = 90.0
    let columnWidthOwner = 90.0
    let columnWidthBrand = 90.0
    
    // text contents begin
    let contentsBegin = 50.0
    
    // margin from left
    let leftMargin = 30.0
    let rightMargin = 30.0
    
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
    //var imageSizePosX = 0.0
    
    
    // store complete inventory as array
    var results: [Inventory] = []

    
    // add keyboard shortcuts to iPadOS screen when user long presses CMD key
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "", image: nil, action: #selector(togglePaperFormatSegment), input: "A", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.paper, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(toggleImageSwitch), input: "I", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.images, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(toggleSortOrder), input: "S", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.sort, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(toggleOwnerSegment), input: "O", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.filterOwner, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(toggleRoomsSegment), input: "R", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.filterRoom, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(emailActionButton(_:)), input: "E", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.email, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(touchPrintAction), input: "P", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.printInvoice, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(shareAction(_:)), input: "9", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: Global.share, state: .on)
        ]
    }
    
    // MARK: view load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // compute image start position
        //imageSizePosX = column_width_item - imageSizeWidth + 20
        
        //os_log("ReportViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        // https://medium.com/@luisfmachado/uiscrollview-autolayout-on-a-storyboard-a-step-by-step-guide-15bd67ee79e9
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 500)
        
        all = Global.all
        
        // set colors for UI elements
        roomsSegment.tintColor = themeColorUIControls
        ownersSegment.tintColor = themeColorUIControls
        sortOrderSegment.tintColor = themeColorUIControls
        paperFormatSegment.tintColor = themeColorUIControls
        shareActionBarButton.tintColor =  themeColorUIControls
        emailActionButton.tintColor = themeColorUIControls
        imageSwitch.tintColor = themeColorUIControls
        imageSwitch.onTintColor = themeColorUIControls
        printBarButton.tintColor = themeColorUIControls
        
        // segments font size
        let font = UIFont.systemFont(ofSize: 10)
        roomsSegment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        ownersSegment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        paperFormatSegment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        sortOrderSegment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.largeTitleDisplayMode = .always
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.title = NSLocalizedString("Reports", comment: "Reports")
        
        let segmentDinA4 = NSLocalizedString("DIN A4", comment: "DIN A4")
        let segmentUsLetter = NSLocalizedString("US Letter", comment: "US Letter")
        replaceSegmentContents(segments: [segmentDinA4, segmentUsLetter], control: paperFormatSegment)
        paperFormatSegment.selectedSegmentIndex = 0 // default din A4
        
        replaceSegmentContents(segments: [Local.item, Local.category, Local.owner, Local.room], control: sortOrderSegment)
        sortOrderSegment.selectedSegmentIndex = 0 // default sort by item
        
        // initialize paper size and stuff
        pdfInit()
        
        // pointer interaction
        customPointerInteraction(on: imageSwitch, pointerInteractionDelegate: self)
        customPointerInteraction(on: helpButton, pointerInteractionDelegate: self)
        
        // context menu interaction
        let pdfInteraction = UIContextMenuInteraction(delegate: self)
        pdfView.addInteraction(pdfInteraction)
    }
    
    // refresh user info every time we come back here
    // This is called every time the view is about to appear, whether or not the view is already in memory.
    // Put your dynamic code here, such as model logic
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // get the data from Core Data
        rooms = store.fetchAllRooms()
        brands = store.fetchAllBrands()
        owners = store.fetchAllOwners()
        categories = store.fetchAllCategories()
        
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
        fetchData(ownerFilter: ownerFilterLabel.text!, roomFilter: roomFilterLabel.text!)
        
        // create the pdf report based on selected sort order and filter choice
        let pdf = pdfCreateInventoryReport()
        
        url = pdfSave(pdf)
        pdfDisplay(file: url!)
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
    func fetchData(ownerFilter: String, roomFilter: String){
        // core data contents
        
        let context = store.getContext()
        
        if ownerFilter != all && roomFilter != all{
            // use both room and owner as filter criteria
            let filterWhere = "inventoryOwner.ownerName == %@ && inventoryRoom.roomName == %@"
            let filterCompare1 = ownerFilter
            let filterCompare2 = roomFilter
            
            do {
                results = try context.fetch(self.inventoryFetchRequest(sortOrder: currentSortOrder.rawValue, filterWhere: filterWhere, filterCompare1: filterCompare1, filterCompare2: filterCompare2))
            } catch{
                os_log("ReportViewController context.fetch", log: Log.viewcontroller, type: .error)
            }
        }
        else{
            if ownerFilter == all && roomFilter != all{
                // use filter for room only
                let filterWhere = "inventoryRoom.roomName == %@"
                let filterCompare = roomFilter
                
                do {
                    results = try context.fetch(self.inventoryFetchRequest(sortOrder: currentSortOrder.rawValue, filterWhere: filterWhere, filterCompare: filterCompare))
                } catch{
                    os_log("ReportViewController context.fetch", log: Log.viewcontroller, type: .error)
                }
            }
            else{
                if ownerFilter == all && roomFilter == all{
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
                    let filterCompare = String(ownerFilter)
                    
                    do {
                        results = try context.fetch(self.inventoryFetchRequest(sortOrder: currentSortOrder.rawValue, filterWhere: filterWhere, filterCompare: filterCompare))
                    } catch{
                        os_log("ReportViewController context.fetch", log: Log.viewcontroller, type: .error)
                    }
                }
            }
        }
    }
    
    // will be called several times
    private func refreshReport(){
        // refresh data from core data
        fetchData(ownerFilter: ownerFilterLabel.text!, roomFilter: roomFilterLabel.text!)
        
        // create the pdf report based on selected sort order and filter choice
        
        let pdf = pdfCreateInventoryReport()
        
        url = pdfSave(pdf)
        pdfDisplay(file: url!)
    }
    
    @IBAction func printBarButtonAction(_ sender: Any) {
        printPDFAction(url: url)
    }
    
    @objc func touchPrintAction(){
        printPDFAction(url: url)
    }
    
    @objc func toggleImageSwitch(){
        imageSwitch.isOn = !imageSwitch.isOn
        
        refreshReport()
    }
    
    @objc func togglePaperFormatSegment(){
        if paperFormatSegment.selectedSegmentIndex == 0{
            paperFormatSegment.selectedSegmentIndex = 1
        }
        else{
            paperFormatSegment.selectedSegmentIndex = 0
        }
        
        switch paperFormatSegment.selectedSegmentIndex
        {
        case 0:
            currentPaperSize = .dinA4
            
            refreshReport()
        case 1:
            currentPaperSize = .usLetter
            
            refreshReport()
        default:
            break
        }
    }
    
    @objc func toggleSortOrder(){
        
        switch(sortOrderSegment.selectedSegmentIndex){
        case 0:
            sortOrderSegment.selectedSegmentIndex = 1
            currentSortOrder = .category
        case 1:
            sortOrderSegment.selectedSegmentIndex = 2
            currentSortOrder = .owner
        case 2:
            sortOrderSegment.selectedSegmentIndex = 3
            currentSortOrder = .room
        case 3:
            sortOrderSegment.selectedSegmentIndex = 0
            currentSortOrder = .item
        default:
            break
        }
        
        refreshReport()
    }
    
    @objc func toggleOwnerSegment(){
        
        let count = ownersSegment.numberOfSegments
        
        if ownersSegment.selectedSegmentIndex < count - 1{
            ownersSegment.selectedSegmentIndex += 1
        }
        else{
            ownersSegment.selectedSegmentIndex = 0
        }
        ownerFilterLabel.text = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
        
        refreshReport()
    }
    
    @objc func toggleRoomsSegment(){
        
        let count = roomsSegment.numberOfSegments
        
        if roomsSegment.selectedSegmentIndex < count - 1{
            roomsSegment.selectedSegmentIndex += 1
        }
        else{
            roomsSegment.selectedSegmentIndex = 0
        }
        roomFilterLabel.text = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
        
        refreshReport()
    }
    
    
    // share a PDF file to iOS: print, save to file
    @objc func sharePdf(path: URL) {
        
        shareAction(currentPath: path, sourceView: self.pdfView)
    }
    
    // MARK: - Actions
    
    @IBAction func imageSwitch(_ sender: UISwitch) {
        refreshReport()
    }
    
    @IBAction func emailActionButton(_ sender: UIBarButtonItem) {
        sendPDFEmail()
    }
    
    // sharing PDF for print or email
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        //os_log("ReportViewController shareActionBarButton", log: Log.viewcontroller, type: .info)
        
        sharePdf(path: url!)
    }
    
    @IBAction func roomsSegmentAction(_ sender: UISegmentedControl) {
        //os_log("ReportViewController roomsSegmentAction", log: Log.viewcontroller, type: .info)
        
        roomFilterLabel.text = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
        
        refreshReport()
    }
    
    @IBAction func ownersSegmentAction(_ sender: UISegmentedControl) {
        //os_log("ReportViewController ownersSegmentAction", log: Log.viewcontroller, type: .info)
        
        ownerFilterLabel.text = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
        
        refreshReport()
    }
    
    @IBAction func paperFormatSegmentAction(_ sender: UISegmentedControl) {
        //os_log("ReportViewController paperFormatSegmentAction", log: Log.viewcontroller, type: .info)
        
        switch paperFormatSegment.selectedSegmentIndex
        {
        case 0:
            currentPaperSize = .dinA4
            
            refreshReport()
        case 1:
            currentPaperSize = .usLetter
            
            refreshReport()
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
        
        refreshReport()
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
                
                switch Local.currentLocaleForDate(){
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
            paperWidth = dinA4Width
            paperHeight = dinA4Height
            
            pageNumber_pos_x = dinA4Width - 140.0
            pageNumber_pos_y = dinA4Height - 20
            
            title_pos_x = leftMargin
            title_pos_y = 20.0
            title_width = 500.0
            title_height = 30.0
            
            footer_pos_x = leftMargin
            footer_pos_y = dinA4Height - 20.0
            break
            
        case .usLetter:
            paperWidth = usLetterWidth
            paperHeight = usLetterHeight
            
            pageNumber_pos_x = usLetterWidth - 140.0
            pageNumber_pos_y = usLetterHeight - 20
            
            title_pos_x = leftMargin
            title_pos_y = 20.0
            title_width = 500.0
            title_height = 30.0
            
            footer_pos_x = leftMargin
            footer_pos_y = usLetterHeight - 20.0
            break
        }
    }
    
    // print the app logo on every page
    func pdfImageLogo(){
        let image = UIImage(named: "InventorySplash.jpg")
        image!.draw(in: CGRect(x: logoPosX, y: logoPosY, width: logoSizeHeight, height: logoSizeWidth))
    }
    
    // print the inventory image next to inventory name if available
    func pdfImageForIntenvory(xPos: Double, yPos: Double, imageData: NSData?){
        
        guard (imageData != nil) else{
            return
        }
        
        //let imageData = currentInventory!.image! as Data
        if let image = UIImage(data: imageData! as Data, scale: 0.1){
        
            //let image = UIImage(named: imageName)
            image.draw(in: CGRect(x: xPos, y: yPos, width: imageSizeWidth, height: imageSizeHeight))
        }
        // otherwise do nothing since to image available
    }
    
    
    // add a page with valid warranty information
    // e.g. Thermomix (bougth 10/11/2019 - warranty until 10/11/2021
    // and second section with of of warranty products
    func pdfWarrantyValidPage( context: UIGraphicsRendererContext){
        
        var stringRect = CGRect(x: 0, y: 0, width: 0, height: 0) // make rect for text
        var y = 0.0 // Points from above
        var x = 0.0 // Points form left
        let offset = 60.0
        
        let summary = NSLocalizedString("Still valid warranty", comment: "Still valid warranty")
        pdfPageTitleHeading(title: summary, fontSize: 25.0, context: context)
        
        // user Info
        pdfPageUserInfo()
        
        x = leftMargin
        y = contentsBegin
        y = y + 15
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let font = UIFont(name: "HelveticaNeue", size: 10.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        // heading
        stringRect = CGRect(x: x, y: y, width: columnWidthItem + offset, height: columnHeight)
        let heading1: NSString = NSLocalizedString("Item", comment: "Item") as NSString
        heading1.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
        
        stringRect = CGRect(x: x + columnWidthItem + offset, y: y, width: columnWidthItem + offset, height: columnHeight)
        let heading2: NSString = NSLocalizedString("Days remaining", comment: "Days remaining") as NSString
        heading2.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
        
        // draw a line
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(1)
        context.cgContext.move(to: CGPoint(x: leftMargin, y: 52 + title_height))
        context.cgContext.addLine(to: CGPoint(x: (5.0 * columnWidth), y: 52 + title_height))
        context.cgContext.drawPath(using: .fillStroke)
        
        y = y + 25
        
        let numberOfDevicesInWarranty = Statistics.shared.warrantyValidDevices()
        if numberOfDevicesInWarranty.count > 0{
            var counter = 1
            for i in numberOfDevicesInWarranty{
                
                // show only as many entries, otherwise we need more than one page
                if counter > 50 {
                    break
                }
                counter += 1
                
                let item: NSString = i.key as NSString
                
                stringRect = CGRect(x: x, y: y, width: columnWidthItem + offset, height: columnHeight)
                item.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])

                let warranty: NSString = String(i.value) as NSString
                
                stringRect = CGRect(x: x + columnWidthItem + offset, y: y, width: columnWidthItem, height: columnHeight)
                warranty.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                
                 y = y + 15
            }
        }
    }
    
    // add a page with exceeded warranty information
    // e.g. Thermomix (bougth 10/11/2019 - warranty until 10/11/2021
    // and second section with of of warranty products
    func pdfWarrantyExceededPage(context: UIGraphicsRendererContext){
        var stringRect = CGRect(x: 0, y: 0, width: 0, height: 0) // make rect for text
        var y = 0.0 // Points from above
        var x = 0.0 // Points form left
        let offset = 60.0
        
        let summary = NSLocalizedString("Exceeded warranty", comment: "Exceeded warranty")
        pdfPageTitleHeading(title: summary, fontSize: 25.0, context: context)
        
        // user Info
        pdfPageUserInfo()
        
        x = leftMargin
        y = contentsBegin
        y = y + 15
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let font = UIFont(name: "HelveticaNeue", size: 10.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        // heading
        stringRect = CGRect(x: x, y: y, width: columnWidthItem + offset, height: columnHeight)
        let heading1: NSString = NSLocalizedString("Item", comment: "Item") as NSString
        heading1.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
        
        stringRect = CGRect(x: x + columnWidthItem + offset, y: y, width: columnWidthItem + offset, height: columnHeight)
        let heading2: NSString = NSLocalizedString("Days exceeded", comment: "Days exceeded") as NSString
        heading2.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
        
        // draw a line
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(1)
        context.cgContext.move(to: CGPoint(x: leftMargin, y: 52 + title_height))
        context.cgContext.addLine(to: CGPoint(x: (5.0 * columnWidth), y: 52 + title_height))
        context.cgContext.drawPath(using: .fillStroke)
        
        y = y + 25
        
        let numberOfDevicesWithoutWarranty = Statistics.shared.warrantyExceededDevices()
        if numberOfDevicesWithoutWarranty.count > 0{
            var counter = 1
            for i in numberOfDevicesWithoutWarranty{
                
                // show only as many entries, otherwise we need more than one page
                if counter > 50 {
                    break
                }
                counter += 1
                
                let item: NSString = i.key as NSString
                
                stringRect = CGRect(x: x, y: y, width: columnWidthItem + offset, height: columnHeight)
                item.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                
                let warranty: NSString = String(i.value) as NSString
                
                stringRect = CGRect(x: x + columnWidthItem + offset, y: y, width: columnWidthItem, height: columnHeight)
                warranty.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                
                 y = y + 15
            }
        }
    }
    
    // add a summary page at the end of the PDF report
    func pdfSummaryPage(numberOfRows: Int, context: UIGraphicsRendererContext){
        
        var y : Double
        
        let summary = NSLocalizedString("Summary", comment: "Summary")
        pdfPageTitleHeading(title: summary, fontSize: 25.0, context: context)
        
        pdfPageUserInfo()
        
        y = contentsBegin
        
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
        
        y = y + 30
        
        let tmp = NSLocalizedString("Room filter applied", comment: "Room filter applied")
        var compareRoom: String = ""
        if roomFilterLabel == nil{
            compareRoom = Global.all
        }
        else
        {
            compareRoom = roomFilterLabel.text!
        }
        if compareRoom /*roomFilterLabel.text*/ == Global.all{
            let printRoomFilter = tmp + ": " + Global.none as NSString
            printRoomFilter.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        else{
            let printRoomFilter = tmp + ": " + roomFilterLabel.text! as NSString
            printRoomFilter.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        
        y = y + 30
        
        let tmp2 = NSLocalizedString("Owner filter applied", comment: "Owner filter applied")
        var compareOwner: String = ""
        if ownerFilterLabel == nil{
            compareOwner = Global.all
        }
        else
        {
            compareOwner = ownerFilterLabel.text!
        }
        if compareOwner /*ownerFilterLabel.text*/ == Global.all{
            let printOwnerFilter = tmp2 + ": " + Global.none as NSString
            printOwnerFilter.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        else{
            let printOwnerFilter = tmp2 + ": " + ownerFilterLabel.text! as NSString
            printOwnerFilter.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        
        y = y + 30
        
        let tmp3 = NSLocalizedString("Number of inventory items", comment: "Number of inventory item")
        let numberOfRowsText = tmp3 + ": " + String(numberOfRows)
        numberOfRowsText.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        
        y = y + 30
        
        let stat = Statistics.shared
        let sum = stat.itemPricesSum()
        let tmp4 = NSLocalizedString("Amount of money spent on items", comment: "Amount of money spent on items")
        let priceSumText = tmp4 + ": " + String(sum) + Local.currencySymbol!
        priceSumText.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        
        y = y + 30
        
        let tmp5 = NSLocalizedString("Database size used for images, pdf files etc.", comment: "Database size")
        let storageText = tmp5 + ": " + String(format: "%.2f", Statistics.shared.getInventorySizeinMegaBytes()) + " MB"
        storageText.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        
        y = y + 30
        
        // take first room only
        let (key, value) = Statistics.shared.countItemsByRoomDict().first ?? ("", 0)
        let roomString = key + ", " + String(value) + " " + NSLocalizedString("Items", comment: "Items")
        let tmp6 = NSLocalizedString("Room with most items in", comment: "Room with most items in")
        let roomItemsText = tmp6 + ": " + roomString
        roomItemsText.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        
        y = y + 30
        let mostExpensiveItem = Statistics.shared.mostExpensiveItems(elementsCount: 1)
        if mostExpensiveItem.count > 0{
            let tmp7 = NSLocalizedString("Most expensive item", comment: "Most expensive item")
            let mostExp = tmp7 + ": " + mostExpensiveItem[0].inventoryName! + ", " + String(mostExpensiveItem[0].price) + Local.currencySymbol!
            mostExp.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        
        y = y + 30
        let warrantyCount = Statistics.shared.warrantyValidDevices().count
        let warr = NSLocalizedString("Devices with valid warranty", comment: "Devices with valid warranty")
        let warrStr = warr + ": " + String(warrantyCount)
        warrStr.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
  
        y = y + 30
        let warrantyCountExceeded = Statistics.shared.warrantyExceededDevices().count
        let warrE = NSLocalizedString("Devices with exceeded warranty", comment: "Devices with exceeded warranty")
        let warrEStr = warrE + ": " + String(warrantyCountExceeded)
        warrEStr.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        
        y = y + 30
        
        let appInfoText = NSLocalizedString("Provided by", comment: "Provided by") + ": " + UIApplication.appName! + " " + UIApplication.appVersion! + " (" + UIApplication.appBuild! + ")"
        appInfoText.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
    }
    
    // generate user info for pdf page (on top rigth position of page)
    func pdfPageUserInfo(){
        
        var userName: String? = ""
        var address: String? = ""
        
        userName = NSUbiquitousKeyValueStore.default.string(forKey: Global.keyUserName)
        if userName == nil{
            userName = ""
        }
        address = NSUbiquitousKeyValueStore.default.string(forKey: Global.keyUserAdress)
        if address == nil{
            address = ""
        }
        
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
        let text1 = userText + ": " + userName! + ", " + addressText + ": " + address!
        let text = text1 as NSString
        
        text.draw(in: CGRect(x: paperWidth - 250 - leftMargin, y: title_pos_y + 5, width: 250, height: 20), withAttributes: attributes as [NSAttributedString.Key : Any])
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
        context.cgContext.move(to: CGPoint(x: leftMargin, y: 20 + title_height))
        context.cgContext.addLine(to: CGPoint(x: paperWidth - rightMargin, y: 20 + title_height))
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
        text.draw(in: CGRect(x: pageNumber_pos_x, y: pageNumber_pos_y - 5, width: 110, height: 20), withAttributes: attributes as [NSAttributedString.Key : Any])
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
        text.draw(in: CGRect(x: footer_pos_x, y: footer_pos_y - 5, width: 300, height: 10), withAttributes: attributes as [NSAttributedString.Key : Any])
        
        // draw a line
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(2)
        context.cgContext.move(to: CGPoint(x: footer_pos_x, y: paperHeight - 30))
        context.cgContext.addLine(to: CGPoint(x: paperWidth - rightMargin, y: footer_pos_y - 10))
        context.cgContext.drawPath(using: .fillStroke)
    }

    func itemColumn(xPos: Double, yPos: Double, text: String) -> Double{
        let x = leftMargin
        var stringRect = CGRect(x: 0, y: 0, width: 0, height: 0) // make rect for text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let font = UIFont(name: "HelveticaNeue-Bold", size: 10.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        // item
        stringRect = CGRect(x: xPos, y: yPos, width: columnWidthItem, height: columnHeight)
        let textToDraw = text
        textToDraw.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
        
        return x + columnWidthItem
    }
    
    // generate pdf pdfTableHeader
    func pdfTableHeader(context: UIGraphicsRendererContext){
        //os_log("ReportViewController pdfTableHeader", log: Log.viewcontroller, type: .info)
        
        var y = 0.0 // Points from above
        var x = 0.0 // Points form left
        var stringRect = CGRect(x: 0, y: 0, width: 0, height: 0) // make rect for text
        var text = ""
        
        y = contentsBegin + 15
        x = leftMargin
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let font = UIFont(name: "HelveticaNeue-Bold", size: 10.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        // switch column order based on sort order
        switch (currentSortOrder){
        case .item:
            // item
            x = itemColumn(xPos: x, yPos: y, text: Local.item)
        /*    stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
            text = Global.item
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthItem
          */
            // owner
            stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
            text = Local.owner
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthOwner
            
            // room
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Local.room
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthRoom
            
            // category
            stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
            text = Local.category
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthCategory
            
            // brand
            stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
            text = Local.brand
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthBrand
            
            // price
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Local.price
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthPrice
            break
            
        case .owner:
            // owner
            stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
            text = Local.owner
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthOwner
            
            // item
            stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
            text = Local.item
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthItem
            
            // room
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Local.room
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthRoom
            
            // category
            stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
            text = Local.category
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthCategory
            
            // brand
            stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
            text = Local.brand
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthBrand
            
            // price
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Local.price
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthPrice
            break
            
        case .category:
            // category
            stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
            text = Local.category
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthCategory
            
            // item
            stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
            text = Local.item
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthItem
            
            // owner
            stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
            text = Local.owner
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthOwner
            
            // room
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Local.room
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthRoom
            
            // brand
            stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
            text = Local.brand
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthBrand
            
            // price
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Local.price
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthPrice
            break
            
        case .room:
            // room
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Local.room
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthRoom
            
            // item
            stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
            text = Local.item
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthItem
            
            // owner
            stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
            text = Local.owner
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthOwner
            
            // category
            stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
            text = Local.category
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthCategory
            
            // brand
            stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
            text = Local.brand
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthBrand
            
            // price
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Local.price
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthPrice
            break
            
        }
        
        x = leftMargin
        
        // draw a line
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(1)
        context.cgContext.move(to: CGPoint(x: leftMargin, y: 48 + title_height))
        context.cgContext.addLine(to: CGPoint(x: (5.0 * columnWidth), y: 48 + title_height))
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
    
    // generate the PDF document containing all pages, header, footer, page number, logo, images etc.
    func pdfCreateInventoryReport() -> Data{
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
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: paperWidth, height: paperHeight), format: format)
        
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: Local.currentLocaleForDate())
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
            
            pdfPageUserInfo()
            
            y = contentsBegin
            // contents
            
            // columns
            pdfTableHeader(context: context)
            y = y + 15
            
            var numberOfRows = 0
            
            for inv in results{
                    
                y = y + 35 // distance to above because is title
                numberOfRows += 1
                
                x = leftMargin
                
                // switch column order based on sort order
                switch (currentSortOrder){
                case .item:
                    // item
                    let splitString = makeTwoLines(text: inv.inventoryName!, length: 14)
                    stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
                    text = splitString.0
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    text = splitString.1
                    stringRect = CGRect(x: x, y: y + 12, width: columnWidthItem, height: columnHeight)
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthItem
                    
                    // owner
                    stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
                    text = inv.inventoryOwner!.ownerName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthOwner
                    
                    // room
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = inv.inventoryRoom!.roomName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthRoom
                    
                    // category
                    stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
                    text = inv.inventoryCategory!.categoryName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthCategory
                    
                    // brand
                    stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
                    text = inv.inventoryBrand!.brandName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthBrand
                    
                    // price
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = String(inv.price) + Local.currencySymbol!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthPrice

                    // print image only when image switch is on
                    if imageSwitch.isOn{
                        pdfImageForIntenvory(xPos: columnWidthItem - imageSizeWidth + 20, yPos: y, imageData: inv.image)
                    }
                    break
                    
                case .owner:
                    // owner
                    stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
                    text = inv.inventoryOwner!.ownerName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthOwner
                    
                    // item
                    let splitString = makeTwoLines(text: inv.inventoryName!, length: 14)
                    stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
                    text = splitString.0
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    text = splitString.1
                    stringRect = CGRect(x: x, y: y + 12, width: columnWidthItem, height: columnHeight)
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthItem
                    
                    // room
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = inv.inventoryRoom!.roomName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthRoom
                    
                    // category
                    stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
                    text = inv.inventoryCategory!.categoryName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthCategory
                    
                    // brand
                    stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
                    text = inv.inventoryBrand!.brandName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthBrand
                    
                    // price
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = String(inv.price) + Local.currencySymbol!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthPrice
                    
                    // print image only when image switch is on
                    if imageSwitch.isOn{
                        pdfImageForIntenvory(xPos: columnWidthOwner + columnWidthItem - imageSizeWidth + 20, yPos: y, imageData: inv.image)
                    }
                    break
                    
                case .category:
                    // category
                    stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
                    text = inv.inventoryCategory!.categoryName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthCategory
                    
                    // item
                    let splitString = makeTwoLines(text: inv.inventoryName!, length: 14)
                    stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
                    text = splitString.0
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    text = splitString.1
                    stringRect = CGRect(x: x, y: y + 12, width: columnWidthItem, height: columnHeight)
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthItem
                    
                    // owner
                    stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
                    text = inv.inventoryOwner!.ownerName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthOwner
                    
                    // room
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = inv.inventoryRoom!.roomName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthRoom
                    
                    // brand
                    stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
                    text = inv.inventoryBrand!.brandName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthBrand
                    
                    // price
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = String(inv.price) + Local.currencySymbol!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthPrice
                    
                    // print image only when image switch is on
                    if imageSwitch.isOn{
                        pdfImageForIntenvory(xPos: columnWidthCategory + columnWidthItem - imageSizeWidth + 20, yPos: y, imageData: inv.image)
                    }
                    break
                    
                case .room:
                    // room
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = inv.inventoryRoom!.roomName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthRoom
                    
                    // item
                    let splitString = makeTwoLines(text: inv.inventoryName!, length: 14)
                    stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
                    text = splitString.0
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    text = splitString.1
                    stringRect = CGRect(x: x, y: y + 12, width: columnWidthItem, height: columnHeight)
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthItem
                    
                    // owner
                    stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
                    text = inv.inventoryOwner!.ownerName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthOwner
                    
                    // category
                    stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
                    text = inv.inventoryCategory!.categoryName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthCategory
                    
                    // brand
                    stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
                    text = inv.inventoryBrand!.brandName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthBrand
                    
                    // price
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = String(inv.price) + Local.currencySymbol!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthPrice
                    
                    // print image only when image switch is on
                    if imageSwitch.isOn{
                        pdfImageForIntenvory(xPos: columnWidthRoom + columnWidthItem - imageSizeWidth + 20, yPos: y, imageData: inv.image)
                    }
                    break
                }
                
                x = leftMargin
                
                
                // current layout fits 49 rows in one page with dinA4, 47 rows in USLetter
                if numberOfRows > paperPrintableRows{
                    numberOfRows = 0
                    y = contentsBegin
                    
                    pdfPageFooter(footerText: footerText, context: context)
                    pdfPageNumber(pageNumber: numberOfPages)
                    numberOfPages += 1
                    
                    context.beginPage()
                    
                    // logo
                    pdfImageLogo()
                    // title
                    pdfPageTitleHeading(title: title, fontSize: 25.0, context: context)
                    // user Info
                    pdfPageUserInfo()
                    
                    pdfTableHeader(context: context)
                }
            }
            
            pdfPageFooter(footerText: footerText, context: context)
            pdfPageNumber(pageNumber: numberOfPages)
            
            // add a valid warranty page at the end of the report
            context.beginPage()
            pdfImageLogo()
            pdfWarrantyValidPage(context: context)
            pdfPageFooter(footerText: footerText, context: context)
            pdfPageNumber(pageNumber: numberOfPages + 1)
            
            // add an invalid warranty page at the end of the report
            context.beginPage()
            pdfImageLogo()
            pdfWarrantyExceededPage(context: context)
            pdfPageFooter(footerText: footerText, context: context)
            pdfPageNumber(pageNumber: numberOfPages + 2)
            
            // add a summary page at the end of the report
            context.beginPage()
            pdfImageLogo()
            pdfSummaryPage(numberOfRows: results.count, context: context)
            pdfPageFooter(footerText: footerText, context: context)
            pdfPageNumber(pageNumber: numberOfPages + 3)
            
        }
        
        // save report to temp dir
        //url = pdfSave(pdf)
        //pdfDisplay(file: url!)
        
        return pdf
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
    
    // print PDF file to printer, called from menu and toolbar
    @objc func printPDFAction(url: URL?) {
        
        // refresh report data, no filter
        fetchData(ownerFilter: "", roomFilter: "")
        
        if let guide_url = url{
            if UIPrintInteractionController.canPrint(guide_url) {
                let printInfo = UIPrintInfo(dictionary: nil)
                printInfo.jobName = guide_url.lastPathComponent
                printInfo.outputType = .general

                let printController = UIPrintInteractionController.shared
                printController.printInfo = printInfo
                printController.showsNumberOfCopies = true
                printController.printingItem = guide_url
                printController.present(animated: true, completionHandler: nil)
            }
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
        // show pdf view fullscreen
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
            displayAlert(title: Global.emailNotSent, message: Global.emailDevice, buttonText: Global.emailConfig)
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
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }

    // split a string longer than one line length into two strings
    func makeTwoLines(text: String, length: Int) -> (String, String){
        var firstLine: String = ""
        var secondLine: String = ""
        
        // truncate anyway if text is longer than two lines (we dont have more space on report)
        let shortText = text.truncate(length: length * 2)
        // in case of too long text use second string
        if shortText.count > length{
            let splitString = text.split(separator: " ")
            
            if splitString.count == 1{
                return (shortText, "")
            }
            
            var count: Int = 0
            
            for str in splitString{
                if firstLine.count + str.count >= length{
                    break
                }
                
                firstLine = firstLine + str + " "
                count += 1

            }
            
            for j in count...splitString.count - 1{
                secondLine = secondLine + splitString[j] + " "
            }
            
            return (firstLine, secondLine.truncate(length: length))

        }
        else{
            return (shortText, "")
        }
    }
    
    #if targetEnvironment(macCatalyst)
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        
        touchBar.defaultItemIdentifiers = [.touchPaper, .touchImage, .touchSort, .touchOwnerFilter, .touchRoomFilter, .flexibleSpace, .touchEmail, .touchShare]
        
        let paper = NSButtonTouchBarItem(identifier: .touchPaper, title: Global.paper, target: self, action: #selector(togglePaperFormatSegment))
        paper.bezelColor = Global.colorGreen
        
        let image = NSButtonTouchBarItem(identifier: .touchImage, title: Global.images, target: self, action: #selector(toggleImageSwitch))
        image.bezelColor = Global.colorGreen
        
        let sort = NSButtonTouchBarItem(identifier: .touchSort, title: Global.sort, target: self, action: #selector(toggleSortOrder))
        sort.bezelColor = Global.colorGreen
        
        let ownerFilter = NSButtonTouchBarItem(identifier: .touchOwnerFilter, title: Local.owner, target: self, action: #selector(toggleOwnerSegment))
        ownerFilter.bezelColor = Global.colorGreen
        
        let roomFilter = NSButtonTouchBarItem(identifier: .touchRoomFilter, title: Local.room, target: self, action: #selector(toggleRoomsSegment))
        roomFilter.bezelColor = Global.colorGreen
        
        /*let print = NSButtonTouchBarItem(identifier: .touchPrint, image: UIImage(systemName: "print")!, target: self, action: #selector(touchPrintAction))
        print.bezelColor = Global.colorGreen */
        
        let email = NSButtonTouchBarItem(identifier: .touchEmail, image: UIImage(systemName: "envelope")!, target: self, action: #selector(emailActionButton(_:)))
        email.bezelColor = Global.colorGreen
        
        let share = NSButtonTouchBarItem(identifier: .touchShare, image: UIImage(systemName: "square.and.arrow.up")!, target: self, action: #selector(shareAction(_:)))
        share.bezelColor = Global.colorGreen
        
        touchBar.templateItems = [paper, image, sort, ownerFilter, roomFilter, email, share]
        
        return touchBar
    }

    #endif
}

// context menu extension
// long press on image gets IOS system share sheet for sending the photo somewhere
extension ReportViewController: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {

        // switch interactions since we have more than one context menu in same view controller
        switch interaction.view{
            
        case pdfView:
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

                return self.makePDFContextMenu()
            })

        default:
            // error should never happen
            break
            
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

            return self.makePDFContextMenu()
        })
    }
    
    func makePDFContextMenu() -> UIMenu {
        // Create a UIAction for sharing
        let share = UIAction(title: Global.pdf, image: UIImage(systemName: "square.and.arrow.up")) { action in
            // Show system share sheet
            //self.shareAction(currentPath: self.currentPath!)
            self.sharePdf(path: self.url!)
        }
        
        let email = UIAction(title: Global.email, image: UIImage(systemName: "envelope")) { action in
            // Show system share sheet
            //self.shareAction(currentPath: self.currentPath!)
            self.sendPDFEmail()
        }
        
        let print = UIAction(title: Global.printReport, image: UIImage(systemName: "printer")) { action in
            // Show system share sheet
            //self.shareAction(currentPath: self.currentPath!)
            self.printPDFAction(url: self.url!)
        }

        // Create and return a UIMenu with the share action
        return UIMenu(title: Global.share, children: [share, email, print])
    }
}
