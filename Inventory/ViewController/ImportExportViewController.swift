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
//  ExportViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 12.05.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//
// export core data to CVS or PDF file

import UIKit
import CoreData
import PDFKit
import os
import MessageUI
import MobileCoreServices

private let store = CoreDataStorage.shared

class ImportExportViewController: UIViewController, MFMailComposeViewControllerDelegate, UIDocumentPickerDelegate, UIPointerInteractionDelegate, UIPopoverPresentationControllerDelegate {

    
    @IBOutlet weak var exportCVSButton: UIButton!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    @IBOutlet weak var importCVSButton: UIButton!
    @IBOutlet weak var backupButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    var url : URL?
    
    // add keyboard shortcuts to iPadOS screen when user long presses CMD key
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "", image: nil, action: #selector(importFromCVSFileButton), input: "I", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.importButton, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(exportCVSButtonAction), input: "E", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.exportButton, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(backupAction), input: "B", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.backup, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(restoreAction), input: "R", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.restore, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(shareButtonAction), input: "9", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.share, state: .on)
        ]
    }
    
    // MARK: view controller stuff
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup colors for UI controls
        exportCVSButton.tintColor = themeColorUIControls
        importCVSButton.tintColor = themeColorUIControls
        shareBarButton.tintColor = themeColorUIControls
        backupButton.tintColor = themeColorUIControls
        restoreButton.tintColor = themeColorUIControls
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.title = NSLocalizedString("Import/Export", comment: "Import/Export")
        
        //self.navigationItem.title = "Export to CVS/PDF"
        
        // if no export happended disable share button because otherwise app crashes
        //shareBarButton.isEnabled = false
        
        // pointer interaction
        customPointerInteraction(on: exportCVSButton, pointerInteractionDelegate: self)
        customPointerInteraction(on: importCVSButton, pointerInteractionDelegate: self)
        customPointerInteraction(on: backupButton, pointerInteractionDelegate: self)
        customPointerInteraction(on: restoreButton, pointerInteractionDelegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // needed for iPhone compatibilty when using popup controller
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func inventoryFetchRequest() -> NSFetchRequest<Inventory> {
        //os_log("ImportExportViewController inventoryFetchRequest", log: Log.viewcontroller, type: .info)
        
        let fetchRequest:NSFetchRequest<Inventory> = Inventory.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]

        return fetchRequest
    }

    
    // export to cvs via backgroud task
    // fetch async array, if no array, return nil
    // create jpeg and pdf files if included in data
    // link between cvs and external jpeg, pdf files by file name
    // returns number of exported rows
    func exportCSVFile() -> Int
    {
        //os_log("ImportExportViewController exportCSVFile", log: Log.viewcontroller, type: .info)
        var exportedRows : Int = 0
        
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.url = docPath.appendingPathComponent(Global.csvFile)
        
        let imagesFolderPath = URL.createFolder(folderName: Global.imagesFolder)
        
        let pdfFolderPath = URL.createFolder(folderName: Global.pdfFolder)
        
        //let barButtonItem = UIBarButtonItem(customView: activityIndicator)
        //navigationItem.leftBarButtonItem = barButtonItem
       
        //let container = store.persistentContainer
        
      //  container.performBackgroundTask { (context) in
            
            var results: [Inventory] = []
            
            do {
                results = try store.getContext().fetch(self.inventoryFetchRequest())
            } catch let error as NSError {
                print("ERROR: \(error.localizedDescription)")
                os_log("ImportExportViewController exportCSVFile", log: Log.viewcontroller, type: .error)
            }
            
            //let cvsFileName = Global.csvFile
            let docPathcsv = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let pathURLcvs = docPathcsv.appendingPathComponent(Global.csvFile)
            self.url = pathURLcvs
            
            //let exportDocPath = pathURLcvs.absoluteString
            var csvText = Global.csvMetadata
            
            var progress : Int = 0
            
            for inv in results{
                csvText.append(contentsOf: inv.csv())
                
                progress += 1
                
                exportedRows += 1
            }
            
            do {
                try csvText.write(to: pathURLcvs, atomically: true, encoding: String.Encoding.utf8)
                
            } catch {
                os_log("ImportExportViewController exportCSVFile", log: Log.viewcontroller, type: .error)
                print("Failed to create inventory csv file")
                print("\(error)")
            }
            
            // loop through all jpeg files and save them
            for inv in results{
                
                // export JPEG files
                if inv.imageFileName != "" {
                    let pathURLjpg = imagesFolderPath!.appendingPathComponent(inv.imageFileName!)
                    // get your UIImage jpeg data representation and check if the destination file url already exists
                    let imageData = inv.image! as Data
                    let image = UIImage(data: imageData, scale: 1.0)
                    if let data = image!.jpegData(compressionQuality: 0.0),
                        !FileManager.default.fileExists(atPath: pathURLjpg.path) {
                        do {
                            // writes the image data to disk
                            try data.write(to: pathURLjpg, options: .atomic)
                            
                        } catch {
                            print("error saving jpg file:", error)
                            os_log("ImportExportViewController exportCSVFile", log: Log.viewcontroller, type: .error)
                        }
                    }
                }
                
                // export PDF files
                if inv.invoiceFileName != nil && inv.invoiceFileName != "" {
                    let pathURLpdf = pdfFolderPath!.appendingPathComponent(inv.invoiceFileName!)
                    
                    let invoiceData = inv.invoice! as Data
                    do {
                        // writes the PDF data to disk
                        try invoiceData.write(to: pathURLpdf, options: .atomic)
                        //print("pdf file saved")
                    } catch {
                        print("error saving pdf file:", error)
                        os_log("ImportExportViewController exportCSVFile", log: Log.viewcontroller, type: .error)
                    }
                }
            }
            
       // }
        
        return exportedRows
    }
    
    
    // MARK: - import stuff
    
    // making import loop
    // returns number of imported rows
    func importCVSFile(fileURL: URL, localDir: Bool) -> Int{
        //os_log("ImportExportViewController importCVSFile", log: Log.viewcontroller, type: .info)
        
        var importedRows : Int = 0
        
        var imagesFolderPath: URL?
        var pdfFolderPath: URL?
        
        if localDir{
            imagesFolderPath = fileURL.appendingPathComponent(Global.imagesFolder)//URL.createFolder(folderName: Global.imagesFolder)
            pdfFolderPath = fileURL.appendingPathComponent(Global.pdfFolder)//URL.createFolder(folderName: Global.pdfFolder)
        }
        else{
            let url = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent(Global.backupFolder)
            imagesFolderPath = url!.appendingPathComponent(Global.imagesFolder)
            pdfFolderPath = url!.appendingPathComponent(Global.pdfFolder)
        }
        
        let csvURL = fileURL.appendingPathComponent(Global.csvFile)
        guard let data = readDataFromCSV(fileURL: csvURL) else{
            // no file to import
            let message = NSLocalizedString("Importing CSV file", comment: "Importing CSV file")
            let title = NSLocalizedString("No CSV file to import found", comment: "No CSV file to import found")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: Global.dismiss, style: .default)
            alertController.addAction(dismissAction)
            
            present(alertController, animated: true)
            
            os_log("ImportExportViewController importCVSFile: no file to import available", log: Log.viewcontroller, type: .info)
            return 0
        }
        
        let csvRows = csvImportParser(data: data)
        
        // check for correct metadata names
        guard let _ = csvCheckMetadata(csvRows: csvRows) else{
            let message = NSLocalizedString("CSV file format different than expected", comment: "CSV file format different than expected")
            let title = NSLocalizedString("CSV file cannot be imported", comment: "CSV file cannot be imported")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: Global.dismiss, style: .default)
            alertController.addAction(dismissAction)
            
            present(alertController, animated: true)
            
            os_log("ImportExportViewController importCVSFile: csv file format different", log: Log.viewcontroller, type: .info)
            return 0
        }
        
        
        // if there is data, ignore first line since this contains the column names
        // Do NOT change definition in core data since order is hard coded
        if csvRows.count > 1{
            for x in 1 ... csvRows.count - 1 {
                
                let inventory = Inventory(context: store.getContext())
                
                // check if row is complete or if inventory name not set
                if csvRows[x][0].count == 0{
                    continue
                }
                
                inventory.inventoryName = csvRows[x][0]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                
                let dateOfPurchase = dateFormatter.date(from: csvRows[x][1])
                
                inventory.dateOfPurchase = dateOfPurchase! as NSDate
                inventory.price = Int32(csvRows[x][2])!
                inventory.serialNumber = csvRows[x][3]
                inventory.remark = csvRows[x][4]
                
                let timeStamp = dateFormatter.date(from: csvRows[x][1])
                inventory.timeStamp = timeStamp! as NSDate
                
                // room handling
                var room: Room?
                room = store.fetchRoom(roomName: csvRows[x][6])
                if room != nil{
                    // room already there
                    inventory.inventoryRoom = room
                }
                else{
                    // new room has to be inserted in room table
                    let newRoom = Room(context: store.getContext())
                    newRoom.roomName = csvRows[x][6]
                    // default room icon image
                    let myImage = #imageLiteral(resourceName: "icons8-home-filled-50")
                    let imageData = myImage.jpegData(compressionQuality: 1.0)
                    newRoom.roomImage = imageData! as NSData
                    inventory.inventoryRoom = newRoom
                    //newRoom = CoreDataHandler.saveRoom(room: newRoom)
                }
                
                // owner handling
                var owner: Owner?
                owner = store.fetchOwner(ownerName: csvRows[x][7])
                if owner != nil{
                    // owner already there
                    inventory.inventoryOwner = owner
                }
                else{
                    // new owner has to be inserted in owner table
                    let newOwner = Owner(context: store.getContext())
                    newOwner.ownerName = csvRows[x][7]
                    inventory.inventoryOwner = newOwner
                    //newOwner = CoreDataHandler.saveOwner(owner: newOwner)
                }
                
                // category handling
                var category: Category?
                category = store.fetchCategory(categoryName: csvRows[x][8])
                if category != nil{
                    // category already there
                    inventory.inventoryCategory = category
                }
                else{
                    // new category has to be inserted in category table
                    let newCategory = Category(context: store.getContext())
                    newCategory.categoryName = csvRows[x][8]
                    inventory.inventoryCategory = newCategory
                    //newCategory = CoreDataHandler.saveCategory(category: newCategory)
                }
                
                // brand handling
                var brand: Brand?
                brand = store.fetchBrand(brandName: csvRows[x][9])
                if brand != nil{
                    // brand already there
                    inventory.inventoryBrand = brand
                }
                else{
                    // new brand has to be inserted in brand table
                    let newBrand = Brand(context: store.getContext())
                    newBrand.brandName = csvRows[x][9]
                    inventory.inventoryBrand = newBrand
                    //newBrand = CoreDataHandler.saveBrand(brand: newBrand)
                }
                
                inventory.warranty = Int32(csvRows[x][10])!
                inventory.imageFileName = csvRows[x][11]
                inventory.invoiceFileName = csvRows[x][12]
                
                // assign image from directory
                if inventory.imageFileName! != ""{
                    //let _ = imagesFolderPath!.startAccessingSecurityScopedResource()
                    let pathURL = imagesFolderPath!.appendingPathComponent(inventory.imageFileName!)
                    //let image = try? UIImage(contentsOfFile: URL(resolvingAliasFileAt: pathURL).path)
                    
                    
                    //let imageURL = URL(fileURLWithPath: pathURL.path)
                    
                    let image    = UIImage(contentsOfFile: pathURL.path)
                    //let _ = imagesFolderPath!.stopAccessingSecurityScopedResource()
                
                    /*
                     iCloud:
                     (lldb) po pathURL
                     ▿ file:///Users/marcus/Library/Mobile%20Documents/com~apple~CloudDocs/Inventory%20App%20Backup/Images/AVM%201750E%20Repeater_2020_8_2_14_39_9.jpg
                     */
                    
                    /*
                     lldb) po pathURL
                     ▿ file:///Users/marcus/Downloads/Inventory%20App%20Backup/Images/AVM%201750E%20Repeater_2020_8_2_14_39_9.jpg

                     */
                    
                    if image != nil{
                        let imageData: NSData = image!.jpegData(compressionQuality: 1.0)! as NSData
                        inventory.image = imageData
                    }
                    else{
                        inventory.image = nil
                    }
                }
                else{
                    // default image if no image was chosen before
                    let myImage = #imageLiteral(resourceName: "Room Icon")
                    let imageData = myImage.jpegData(compressionQuality: 1.0)
                    inventory.image = imageData! as NSData
                }
                
                // assign PDF file from documents directory
                if inventory.invoiceFileName! != ""{
                    //let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let pathURL = pdfFolderPath!.appendingPathComponent(inventory.invoiceFileName!)
                    if let pdfDocument = PDFDocument(url: pathURL) {
                        inventory.invoice = pdfDocument.dataRepresentation()! as NSData?
                    }
                    else{
                        // no PDF file chosen
                        inventory.invoice = nil
                    }
                }
                else{
                    // no PDF file chosen
                    inventory.invoice = nil
                }
                
                // check for UUID, if data is already imported then avoid duplicates
                let uuid = store.getInventoryUUID(uuid: UUID(uuidString: csvRows[x][13])!)
                
                if !uuid{
                    // save imported csv line into database
                    // assign inventory id afterwards because otherwise getInventoryUUID() will always be true
                    inventory.id = UUID(uuidString: csvRows[x][13])
                    _ = store.saveInventory(inventory: inventory)
                    
                    importedRows += 1
                }
                else{
                    // delete new object from context to avoid duplicates during runtime
                    let context = store.getContext()
                    context.delete(inventory)
                }
            }
        }
        
        // at the end of import report number of imported rows to user
        
        return importedRows
    }
    
    // check for correct file format
    func csvCheckMetadata(csvRows: [[String]]) -> String?{
        
        if csvRows[0][0] != Global.inventoryName_csv{
            return nil
        }
        
        if csvRows[0][1] != Global.dateofPurchase_csv{
            return nil
        }
        
        if csvRows[0][2] != Global.price_csv{
            return nil
        }
        
        if csvRows[0][3] != Global.serialNumber_csv{
            return nil
        }
        
        if csvRows[0][4] != Global.remark_csv{
            return nil
        }
        
        if csvRows[0][5] != Global.timeStamp_csv{
            return nil
        }
        
        if csvRows[0][6] != Global.roomName_csv{
            return nil
        }
        
        if csvRows[0][7] != Global.ownerName_csv{
            return nil
        }
        
        if csvRows[0][8] != Global.categoryName_csv{
            return nil
        }
        
        if csvRows[0][9] != Global.brandName_csv{
            return nil
        }
        
        if csvRows[0][10] != Global.warranty_csv{
            return nil
        }
        
        if csvRows[0][11] != Global.imageFileName_csv{
            return nil
        }
        
        if csvRows[0][12] != Global.invoiceFileName_csv{
            return nil
        }
        
        if csvRows[0][13] != Global.id_csv{
            return nil
        }
        
        return "ok"
    }
    
    // read file as string from any given URL
    func readDataFromCSV(fileURL: URL) -> String?{
        // open file from any directory including iCloud folder
        
        do {
            var contents = try String(contentsOf: fileURL, encoding: .utf8)
            contents = cleanRows(file: contents)
            
            fileURL.stopAccessingSecurityScopedResource()
            
            return contents
            
        } catch {
            print("File import Read Error for cvs file \(fileURL.absoluteString)", error)
            os_log("ImportExportViewController readDataFromCSV", log: Log.viewcontroller, type: .error)
            
            fileURL.stopAccessingSecurityScopedResource()
            
            return nil
        }
    }

    // remove special characters from csv file
    func cleanRows(file: String) -> String{
        
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: ";", with: ",")
        
        return cleanFile
    }
    
    // import cvs file parser
    func csvImportParser(data: String) -> [[String]] {
        //os_log("ImportExportViewController csvImportParser", log: Log.viewcontroller, type: .info)
        
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            if row.count > 0{
                let columns = row.components(separatedBy: ",")
                result.append(columns)
            }
        }
        
        return result
    }
    
    // MARK: - button actions
    
    @IBAction func helpAction(_ sender: UIButton) {
        // create popover via storyboard instead of segue
           let myVC = storyboard?
               .instantiateViewController(withIdentifier: "PopupViewController")   // defined in Storyboard identifier
               as! PopupViewController
           
           // here goes the popup text
           var fileName : String
           
           switch Local.currentLocaleForDate(){
           case "de_DE", "de_AT", "de_CH", "de":
               fileName = "ImportExportview Help German"
               break
               
           default: // all other languages get english text
               fileName = "ImportExportview Help English"
               break
           }
           
           myVC.myText = Global.getRTFFileFromBundle(fileName: fileName)
           // this needs to define calling view controller type
           myVC.importexportVC = self
           
           // show the popover
           myVC.modalPresentationStyle = .popover
           let popPC = myVC.popoverPresentationController!
           popPC.sourceView = sender
           popPC.sourceRect = sender.bounds
           popPC.permittedArrowDirections = .up
           popPC.delegate = self
           present(myVC, animated:false, completion: nil)
    }
    
    @IBAction func restoreAction(_ sender: UIButton) {
        
        // add the spinner view controller
        let child = SpinnerViewController()
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        DispatchQueue.main.async() {
            // here comes long running function
            self.restoreFromiCloud()
            
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
    }
    
    // make an icloud backup
    @IBAction func backupAction(_ sender: UIButton) {
        
        // add the spinner view controller
        let child = SpinnerViewController()
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        DispatchQueue.main.async() {
            // here comes long running function
            self.backupDataToiCloud()
            
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
    }
    
    // called from main menu in case of catalyst
    @objc func export(){
        
        // add the spinner view controller
        let child = SpinnerViewController()
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        var numberOfRowsExported = 0
        
        DispatchQueue.main.async() {
            // here comes long running function
            numberOfRowsExported = self.exportCSVFile()
            
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
            
            // show alert box with path name
            let text = Global.messageExportFinished + ". " + String(numberOfRowsExported) + " " + Global.numberOfExportedRows
            self.displayAlert(title: Global.titleExportFinished, message: text, buttonText: Global.dismiss)
        }
        
    }
    
    @IBAction func exportCVSButtonAction(_ sender: UIButton) {
        
        // add the spinner view controller
        let child = SpinnerViewController()
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        var numberOfRowsExported = 0
        
        DispatchQueue.main.async() {
            // here comes long running function
            numberOfRowsExported = self.exportCSVFile()
            
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
            
            // show alert box with path name
            let text = Global.messageExportFinished + ". " + String(numberOfRowsExported) + " " + Global.numberOfExportedRows
            self.displayAlert(title: Global.titleExportFinished, message: text, buttonText: Global.dismiss)
        }
    
    }
    
    // share system button to share csv file
    @IBAction func shareButtonAction(_ sender: Any) {
        
        let _ = exportCSVFile()
        
        shareAction(currentPath: self.url!)
    }
    
    // import button
    @IBAction func importFromCVSFileButton(_ sender: Any) {
        //os_log("ImportExportViewController importFromCVSFileButton", log: Log.viewcontroller, type: .info)
        
        openFilesApp()
        
    }
    
    // MARK: - email
    /// Prepares mail sending controller
    ///
    /// **Extremely** important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
    
    func sendCSVEmail(path: URL?){
        //os_log("ImportExportViewController sendCSVEmail", log: Log.viewcontroller, type: .info)
        
        // hide keyboard
        self.view.endEditing(true)
        
        let mailComposeViewController = configuredMailComposeViewController(url: path)
        
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
        mailComposerVC.setSubject(NSLocalizedString("My CSV file", comment: "My CSV file"))
        let msg = NSLocalizedString("My CSV file", comment: "My CSV file")
        mailComposerVC.setMessageBody(msg, isHTML: false)
        
        // attachment
        if url != nil{
            do{
                let attachmentData = try Data(contentsOf: url!)
                mailComposerVC.addAttachmentData(attachmentData, mimeType: "text/csv", fileName: Global.csvFile)
            }
            catch let error {
                os_log("ImportExportViewController email attachement error: %s", log: Log.viewcontroller, type: .error, error.localizedDescription)
            }
        }
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - document picker of files app
    
    func openFilesApp(){
        //os_log("ImportExportViewController openFilesApp", log: Log.viewcontroller, type: .info)
        
        let picker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeCommaSeparatedText)], in: .open)
        
        picker.delegate = self
        picker.allowsMultipleSelection = false
        picker.modalPresentationStyle = .fullScreen
        
        // e.g. present UIDocumentPickerViewController via your current UIViewController
        self.present(picker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
        var dir: URL
        
        guard
            controller.documentPickerMode == .open,
            let url = urls.first,
            url.startAccessingSecurityScopedResource()
        else {
            return
        }
        /*defer {
            url.stopAccessingSecurityScopedResource()
        }*/
        // do something with the selected document
        dir = url
        dir.deleteLastPathComponent()
        
        
        // add the spinner view controller
        let child = SpinnerViewController()
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        var importedRows = 0
        
        DispatchQueue.main.async() {
            // here comes long running function
            
            let fileDir = self.copyDocumentsFromDirectory(sourceURL: dir)
            importedRows = self.importCVSFile(fileURL: fileDir!, localDir: true)
            
            let title = NSLocalizedString("Import", comment: "Import")
            let message = NSLocalizedString("Import succeeded with", comment: "Import succeeded with") +
                            " " + "\(importedRows) " + NSLocalizedString("inventory objects", comment: "inventory objects")
            self.displayAlert(title: title, message: message, buttonText: Global.done)
            
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        url.stopAccessingSecurityScopedResource()
    }

    // cancel opening/choosing files
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // do nothing
    }
    
    func createSpinnerView() {
        let child = SpinnerViewController()

        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        // wait two seconds to simulate some work happening
        DispatchQueue.main.async() {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    #if targetEnvironment(macCatalyst)
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        
        touchBar.defaultItemIdentifiers = [.touchExport, .touchImport, .fixedSpaceSmall, .touchBackup, .touchRestore, .fixedSpaceSmall, .touchShare]
        
        let importButton = NSButtonTouchBarItem(identifier: .touchImport, title: Global.importButton, target: self, action: #selector(importFromCVSFileButton(_:)))
        importButton.bezelColor = Global.colorGreen
        
        let exportButton = NSButtonTouchBarItem(identifier: .touchExport, title: Global.exportButton, target: self, action: #selector(exportCVSButtonAction(_:)))
        exportButton.bezelColor = Global.colorGreen
        
        let shareButton = NSButtonTouchBarItem(identifier: .touchShare, image: UIImage(systemName: "square.and.arrow.up")!, target: self, action: #selector(shareButtonAction(_:)))
        
        let backupBtn = NSButtonTouchBarItem(identifier: .touchBackup, image: UIImage(systemName: "icloud.and.arrow.up.fill")!, target: self, action: #selector(backupAction))
        backupBtn.bezelColor = Global.colorGreen
        
        let restoreBtn = NSButtonTouchBarItem(identifier: .touchRestore, image: UIImage(systemName: "icloud.and.arrow.down.fill")!, target: self, action: #selector(restoreAction))
        restoreBtn.bezelColor = Global.colorGreen
        
        touchBar.templateItems = [importButton, exportButton, backupBtn, restoreBtn, shareButton]
        
        return touchBar
    }

    #endif
    
    // check if iCloud account available
    func isICloudContainerAvailable() -> Bool {
        if let _ = FileManager.default.ubiquityIdentityToken {
            return true
        }
        else {
            return false
        }
    }
    
    // create a folder in iCloud container
    func createiCloudDirectory(folder: String) -> URL?{
        if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent(folder) {
            if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                do {
                    try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                    
                    return iCloudDocumentsURL
                }
                catch {
                    print("Error in creating icloud folder")
                }
            }
            
        }
        return nil
    }
    
    // before running import function copy all necessary files to temp folder
    // returns destination URL to find all files later on
    func copyDocumentsFromDirectory(sourceURL: URL) -> URL?{
        guard let destURL = URL.createFolder(folderName: "temp") else { return nil}
        
        let destImages = destURL.appendingPathComponent(Global.imagesFolder)
        let destPDF = destURL.appendingPathComponent(Global.pdfFolder)
         
        let sourceImages = sourceURL.appendingPathComponent(Global.imagesFolder)
        let sourcePDF = sourceURL.appendingPathComponent(Global.pdfFolder)
         
        let destCSVFile = destURL.appendingPathComponent(Global.csvFile)
        let sourceCSVFile = sourceURL.appendingPathComponent(Global.csvFile)
        
        let _ = FileManager.default.secureCopyItem(at: sourceCSVFile, to: destCSVFile)
        let _ = FileManager.default.secureCopyItem(at: sourceImages, to: destImages)
        let _ = FileManager.default.secureCopyItem(at: sourcePDF, to: destPDF)
        
        return destURL
    }
    
    // copy/replace images folder and pdf folder and csv file to iCloud app container directory
    func copyDocumentsToiCloudDirectory() {
        guard let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last else { return }
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent(Global.backupFolder) else { return }
        
        let localImages = localDocumentsURL.appendingPathComponent(Global.imagesFolder)
        let localPDF = localDocumentsURL.appendingPathComponent(Global.pdfFolder)
        
        let iCloudImages = iCloudDocumentsURL.appendingPathComponent(Global.imagesFolder)
        let iCloudPDF = iCloudDocumentsURL.appendingPathComponent(Global.pdfFolder)
        
        let localCSVFile = localDocumentsURL.appendingPathComponent(Global.csvFile)
        let iCloudCSVFile = iCloudDocumentsURL.appendingPathComponent(Global.csvFile)
        
        let _ = iCloudCSVFile.startAccessingSecurityScopedResource()
        
        // first remove old csv file
        do{
            try FileManager.default.removeItem(at: iCloudCSVFile)
        }
        catch{
            print("no old csv file")
        }
        
        // now copy new csv file to backup destination
        do {
            try FileManager.default.copyItem(at: localCSVFile, to: iCloudCSVFile)
        }
        catch {
            //Error handling
            print("Error in copy csv file")
        }
        let _ = iCloudCSVFile.stopAccessingSecurityScopedResource()
        
       // remove image files
       do{
            try FileManager.default.removeItem(at: iCloudImages)
        }
        catch{
            print("no old image files")
        }
        
        // now copy new image files to backup destination
        do {
            try FileManager.default.copyItem(at: localImages, to: iCloudImages)
        }
        catch {
            //Error handling
            print("Error in copy images")
        }
        
        // remove pdf files
        do{
             try FileManager.default.removeItem(at: iCloudPDF)
         }
         catch{
             print("no old pdf files")
         }
         
         // now copy new pdf files to backup destination
         do {
             try FileManager.default.copyItem(at: localPDF, to: iCloudPDF)
         }
         catch {
             //Error handling
             print("Error in copy pdfs")
         }
        
    }
    
    // make a copy of inventory csv file and images and pdf folder available in icloud drive in case user has icloud
    func backupDataToiCloud(){
        let title = NSLocalizedString("Backup to iCloud", comment: "Backup to iCloud")
        
        if isICloudContainerAvailable(){
            //print("icloud vorhanden")
        }
        else{
            let message = NSLocalizedString("iCloud not configured. Backup/Restore only works with using iCloud account", comment: "iCloud not configured. Backup/Restore only works with using iCloud account")
            displayAlert(title: title, message: message, buttonText: Global.done)
            
            return
        }
        
        // first generate files to be copied
        let numberOfRowsExported = exportCSVFile()
        
        let _ = createiCloudDirectory(folder: Global.backupFolder)
        let _ = createiCloudDirectory(folder: Global.backupFolder + "/" + Global.imagesFolder)
        let _ = createiCloudDirectory(folder: Global.backupFolder + "/" + Global.pdfFolder)
        
        // copy all data from documents dir to iCloud
        copyDocumentsToiCloudDirectory()
        
        // show alert box with path name
        var message = NSLocalizedString("Backup finished successfully with", comment: "Backup finished successfully with")
        message += " \(numberOfRowsExported) " + NSLocalizedString("inventory objects", comment: "inventory objects")
        displayAlert(title: title, message: message, buttonText: Global.done)
    }
    
    // restore from iCloud backup
    func restoreFromiCloud(){
        let title = NSLocalizedString("Restore from iCloud", comment: "Restore from iCloud")
        
        guard isICloudContainerAvailable() else {
            let message = NSLocalizedString("iCloud not configured. Backup/Restore only works with using iCloud account", comment: "iCloud not configured. Backup/Restore only works with using iCloud account")
            displayAlert(title: title, message: message, buttonText: Global.done)
            return
        }
        
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent(Global.backupFolder)
            else {
                let message = NSLocalizedString("Please make a backup to iCloud first", comment: "Please make a backup to iCloud first")
                displayAlert(title: title, message: message, buttonText: Global.done)
            return
        }
        
        // add the spinner view controller
        let child = SpinnerViewController()
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        var importedRows = 0
        
        DispatchQueue.main.async() {
            // here comes long running function
            importedRows = self.importCVSFile(fileURL: iCloudDocumentsURL, localDir: false)
            
            let title = NSLocalizedString("Import", comment: "Import")
            let message = NSLocalizedString("Import from iCloud succeeded with", comment: "Restore from iCloud succeeded") +
                            " " + "\(importedRows) " + NSLocalizedString("inventory objects", comment: "inventory objects")
            self.displayAlert(title: title, message: message, buttonText: Global.done)
            
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    // export to cvs via backgroud task
    // fetch async array, if no array, return nil
    // create jpeg and pdf files if included in data
    // link between cvs and external jpeg, pdf files by file name
    func backupInventoryData2()
    {
        _ = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        //var url = docPath.appendingPathComponent(Global.csvFile)
        
        let imagesFolderPath = URL.createFolder(folderName: Global.imagesFolder)
        let pdfFolderPath = URL.createFolder(folderName: Global.pdfFolder)
       
        let container = store.persistentContainer
        
        container.performBackgroundTask { (context) in
            var results: [Inventory] = []
            
            do {
                results = try context.fetch(self.inventoryFetchRequest())
            } catch let error as NSError {
                print("ERROR: \(error.localizedDescription)")
            }
            
            let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let pathURLcvs = docPath.appendingPathComponent(Global.csvFile)
            
            var csvText = Global.csvMetadata
            
            for inv in results{
                csvText.append(contentsOf: inv.csv())
            }
            
            do {
                try csvText.write(to: pathURLcvs, atomically: true, encoding: String.Encoding.utf8)
                //print("Export Path: \(exportDocPath)")
            } catch {
                print("Failed to create inventory csv file")
                print("\(error)")
            }
            
            // loop through all jpeg files and save them
            for inv in results{
                // export JPEG files
                if inv.imageFileName != "" {
                    let pathURLjpg = imagesFolderPath!.appendingPathComponent(inv.imageFileName!)
                    // get your UIImage jpeg data representation and check if the destination file url already exists
                    let imageData = inv.image! as Data
                    let image = UIImage(data: imageData, scale: 1.0)
                    if let data = image!.jpegData(compressionQuality: 0.0),
                        !FileManager.default.fileExists(atPath: pathURLjpg.path) {
                        do {
                            // writes the image data to disk
                            try data.write(to: pathURLjpg, options: .atomic)
                            
                        } catch {
                            print("error saving jpg file:", error)
                            os_log("ImportExportViewController exportCSVFile", log: Log.viewcontroller, type: .error)
                        }
                    }
                }
                
                // export PDF files
                if inv.invoiceFileName != nil && inv.invoiceFileName != "" {
                    let pathURLpdf = pdfFolderPath!.appendingPathComponent(inv.invoiceFileName!)
                    
                    let invoiceData = inv.invoice! as Data
                    do {
                        // writes the PDF data to disk
                        try invoiceData.write(to: pathURLpdf, options: .atomic)
                        //print("pdf file saved")
                    } catch {
                        print("error saving pdf file:", error)
                    }
                }
            }
            
        }
        
    }
        
}

