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

class ImportExportViewController: UIViewController, MFMailComposeViewControllerDelegate, UIDocumentPickerDelegate {

    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var exportCVSButton: UIButton!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    @IBOutlet weak var importedRowsLabel: UILabel!
    @IBOutlet weak var importCVSButton: UIButton!
    
    var url : URL?
    
    // MARK: view controller stuff
    override func viewDidLoad() {
        super.viewDidLoad()
        
        os_log("ImportExportViewController viewDidLoad", log: Log.viewcontroller, type: .info)

        // setup colors for UI controls
        exportCVSButton.tintColor = themeColorUIControls
        importCVSButton.tintColor = themeColorUIControls
        
        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        self.importedRowsLabel.isHidden = true

        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = true
        
        self.title = NSLocalizedString("Import/Export CSV", comment: "Import/Export CSV")
        
        //self.navigationItem.title = "Export to CVS/PDF"
        
        // if no export happended disable share button because otherwise app crashes
        //shareBarButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        os_log("ImportExportViewController viewWillAppear", log: Log.viewcontroller, type: .info)
        
        self.importedRowsLabel.isHidden = true
        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = true
        
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
        os_log("ImportExportViewController inventoryFetchRequest", log: Log.viewcontroller, type: .info)
        
        let fetchRequest:NSFetchRequest<Inventory> = Inventory.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]

        return fetchRequest
    }

    // export to cvs via backgroud task
    // fetch async array, if no array, return nil
    // create jpeg and pdf files if included in data
    // link between cvs and external jpeg, pdf files by file name
    func exportCSVFile()
    {
        os_log("ImportExportViewController exportCSVFile", log: Log.viewcontroller, type: .info)
        
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.url = docPath.appendingPathComponent(Global.csvFile)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        let barButtonItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.leftBarButtonItem = barButtonItem
        activityIndicator.startAnimating()
       
        let container = CoreDataHandler.persistentContainer()
        
        container.performBackgroundTask { (context) in
            var exportedRows : Int = 0
            
            var results: [Inventory] = []
            
            do {
                results = try context.fetch(self.inventoryFetchRequest())
            } catch let error as NSError {
                print("ERROR: \(error.localizedDescription)")
                os_log("ImportExportViewController exportCSVFile", log: Log.viewcontroller, type: .error)
            }
            
            //let cvsFileName = Global.csvFile
            let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let pathURLcvs = docPath.appendingPathComponent(Global.csvFile)
            self.url = pathURLcvs
            
            let exportDocPath = pathURLcvs.absoluteString
            var csvText = "inventoryName,dateofPurchase,price,serialNumber,remark,timeStamp,roomName,ownerName,categoryName,brandName,warranty,imageFileName,invoiceFileName,id\n"
            
            var progress : Int = 0
            
            for inv in results{
                csvText.append(contentsOf: inv.csv())
                
                progress += 1
                DispatchQueue.main.async {
                    // update progress bar UI
                    let progress = Float(progress) / Float(results.count)
                    self.progressView.setProgress(progress, animated: true)
                    self.progressLabel.text = String(progress * 100) + " %"
                }
                
                exportedRows += 1
            }
            
            do {
                try csvText.write(to: pathURLcvs, atomically: true, encoding: String.Encoding.utf8)
                //print("Export Path: \(exportDocPath)")
                DispatchQueue.main.async {
                    
                    // show alert box with path name
                    self.showExportFinishedAlertView(exportDocPath)
                }
            } catch {
                os_log("ImportExportViewController exportCSVFile", log: Log.viewcontroller, type: .error)
                print("Failed to create inventory csv file")
                print("\(error)")
            }
            
            // loop through all jpeg files and save them
            for inv in results{
                
                // export JPEG files
                if inv.imageFileName != "" {
                    let pathURLjpg = docPath.appendingPathComponent(inv.imageFileName!)
                    // get your UIImage jpeg data representation and check if the destination file url already exists
                    let imageData = inv.image! as Data
                    let image = UIImage(data: imageData, scale: 1.0)
                    if let data = image!.jpegData(compressionQuality: 1.0),
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
                    let pathURLpdf = docPath.appendingPathComponent(inv.invoiceFileName!)
                    
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
            
            DispatchQueue.main.async {
                // at the end of export report the number of exported rows to user
                self.importedRowsLabel.isHidden = false
                let message = NSLocalizedString("Exported rows:", comment: "Exported rows:")
                self.importedRowsLabel.text = message + " " + String(exportedRows)
                
                // set progress bar to 100% at the end of export
                self.progressView.setProgress(1.0, animated: true)
                self.progressLabel.text = "100 %"
                
                activityIndicator.stopAnimating()
                self.navigationItem.leftBarButtonItem = nil
            }
        }
        
    }
    
  /*
    func activityIndicatorBarButtonItem() -> UIBarButtonItem {
        os_log("ImportExportViewController activityIndicatorBarButtonItem", log: Log.viewcontroller, type: .info)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        let barButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        
        return barButtonItem
    } */
    /*
    func exportBarButtonItem() -> UIBarButtonItem {
        os_log("ImportExportViewController exportBarButtonItem", log: Log.viewcontroller, type: .info)
        
        let title = NSLocalizedString("Export", comment: "Export")
        return UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(shareButton(_:)))
    } */
    
    // show message where file can be located in file system
    func showExportFinishedAlertView(_ exportPath: String) {
        os_log("ImportExportViewController showExportFinishedAlertView", log: Log.viewcontroller, type: .info)
        
        let message = NSLocalizedString("The exported CSV file can be found here: ", comment: "The exported CSV file can be found here: ") + "\(exportPath)"
        
        let title = NSLocalizedString("Export Finished", comment: "Export Finished")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: Global.dismiss, style: .default)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
    }
    
    // MARK - import stuff
    
    // makin import loop
    func importCVSFile(file: String){
        os_log("ImportExportViewController importCVSFile", log: Log.viewcontroller, type: .info)
        
        var importedRows : Int = 0
       // var context: NSManagedObjectContext
       // context = CoreDataHandler.getContext()
        
        guard let data = readDataFromCSV(fileName: file) else{
            // no file to import
            let message = NSLocalizedString("Importing CSV file", comment: "Importing CSV file")
            let title = NSLocalizedString("No CSV file to import found", comment: "No CSV file to import found")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: Global.dismiss, style: .default)
            alertController.addAction(dismissAction)
            
            present(alertController, animated: true)
            
            os_log("ImportExportViewController importCVSFile: no file to import available", log: Log.viewcontroller, type: .info)
            return
        }
        
        let csvRows = csvImportParser(data: data)
        
        
        // if there is data, ignore first line since this contains the column names
        // Do NOT change definition in core data since order is hard coded
        if csvRows.count > 1{
            for x in 1 ... csvRows.count - 1 {
                // update progress bar UI
                let progress = Float(x) / Float(csvRows.count)
                progressView.setProgress(progress, animated: true)
                progressLabel.text = String(progress) + " %"
                
                var context: NSManagedObjectContext
                context = CoreDataHandler.getContext()
                let inventory = Inventory(context: context)
                
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
                room = CoreDataHandler.fetchRoom(roomName: csvRows[x][6])
                if room != nil{
                    // room already there
                    inventory.inventoryRoom = room
                }
                else{
                    // new room has to be inserted in room table
                    var newRoom = Room(context: context)
                    newRoom.roomName = csvRows[x][6]
                    // default room icon image
                    let myImage = #imageLiteral(resourceName: "icons8-home-filled-50")
                    let imageData = myImage.jpegData(compressionQuality: 1.0)
                    newRoom.roomImage = imageData! as NSData
                    newRoom = CoreDataHandler.saveRoom(room: newRoom)
                    inventory.inventoryRoom = newRoom
                }
                
                // owner handling
                var owner: Owner?
                owner = CoreDataHandler.fetchOwner(ownerName: csvRows[x][7])
                if owner != nil{
                    // owner already there
                    inventory.inventoryOwner = owner
                }
                else{
                    // new owner has to be inserted in owner table
                    var newOwner = Owner(context: context)
                    newOwner.ownerName = csvRows[x][7]
                    newOwner = CoreDataHandler.saveOwner(owner: newOwner)
                    inventory.inventoryOwner = newOwner
                }
                
                // category handling
                var category: Category?
                category = CoreDataHandler.fetchCategory(categoryName: csvRows[x][8])
                if category != nil{
                    // category already there
                    inventory.inventoryCategory = category
                }
                else{
                    // new category has to be inserted in category table
                    var newCategory = Category(context: context)
                    newCategory.categoryName = csvRows[x][8]
                    newCategory = CoreDataHandler.saveCategory(category: newCategory)
                    inventory.inventoryCategory = newCategory
                }
                
                // brand handling
                var brand: Brand?
                brand = CoreDataHandler.fetchBrand(brandName: csvRows[x][9])
                if brand != nil{
                    // brand already there
                    inventory.inventoryBrand = brand
                }
                else{
                    // new brand has to be inserted in brand table
                    var newBrand = Brand(context: context)
                    newBrand.brandName = csvRows[x][9]
                    newBrand = CoreDataHandler.saveBrand(brand: newBrand)
                    inventory.inventoryBrand = newBrand
                }
                
                inventory.warranty = Int32(csvRows[x][10])!
                inventory.imageFileName = csvRows[x][11]
                inventory.invoiceFileName = csvRows[x][12]
                
                inventory.id = UUID(uuidString: csvRows[x][13])
                
                // assign image from directory
                if inventory.imageFileName! != ""{
                    let image = getSavedImage(named: inventory.imageFileName!)
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
                    let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let pathURL = docPath.appendingPathComponent(inventory.invoiceFileName!)
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
                let uuid = CoreDataHandler.getInventoryUUID(uuid: UUID(uuidString: csvRows[x][13])!)
                
                if !uuid{
                    // save imported csv line into database
                    //_ = CoreDataHandler.saveInventory(inventory: inventory)
                    
                    importedRows += 1
                }
                else{
                    // delete new object from context to avoid duplicates during runtime
                    let context = CoreDataHandler.getContext()
                    context.delete(inventory)
                }
            }
        }
        
        // at the end of import report number of imported rows to user
        self.importedRowsLabel.isHidden = false
        let rows = NSLocalizedString("Imported rows:", comment: "Imported rows:")
        self.importedRowsLabel.text = rows + " " + String(importedRows)
        
        progressView.setProgress(1.0, animated: true)
        progressLabel.text = "100 %"
    }
    
    // get jpeg image from file directory
    // FIXME: must change to other directory
    // return NIL if no file exists
    func getSavedImage(named: String) -> UIImage? {
        os_log("ImportExportViewController getSavedImage", log: Log.viewcontroller, type: .info)
        
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        
        return nil
    }
    
    // read file as string
    // FIXME: change directory
    func readDataFromCSV(fileName: String) -> String?{
        os_log("ImportExportViewController readDataFromCSV", log: Log.viewcontroller, type: .info)
        
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathURLcvs = docPath.appendingPathComponent(fileName)
        
        do {
            var contents = try String(contentsOfFile: pathURLcvs.path, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
            
        } catch {
            print("File import Read Error for cvs file \(pathURLcvs.absoluteString)", error)
            os_log("ImportExportViewController readDataFromCSV", log: Log.viewcontroller, type: .error)
            
            return nil
        }
    }

    // remove special characters from csv file
    func cleanRows(file: String) -> String{
        os_log("ImportExportViewController cleanRows", log: Log.viewcontroller, type: .info)
        
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: ";", with: ",")
        
        return cleanFile
    }
    
    // import cvs file parser
    func csvImportParser(data: String) -> [[String]] {
        os_log("ImportExportViewController csvImportParser", log: Log.viewcontroller, type: .info)
        
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
    
    @IBAction func exportCVSButtonAction(_ sender: UIButton) {
        os_log("ImportExportViewController exportCVSButtonAction", log: Log.viewcontroller, type: .info)
        
        importedRowsLabel.isHidden = true
        importedRowsLabel.text = ""
        
        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = false
        progressLabel.text = "0 %"
        
        exportCSVFile()
        
        //shareBarButton.isEnabled = true
    }
    
    /*
    // share system button
    @IBAction func shareButtonAction(_ sender: Any) {
        os_log("ImportExportViewController shareButtonAction", log: Log.viewcontroller, type: .info)
        
        importedRowsLabel.isHidden = true
        importedRowsLabel.text = ""
        
        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = false
        progressLabel.text = "0 %"
        
        exportCSVFile()
        
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: self.url!.path) {
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: ["Check out this book! I like using Book Tracker.",self.url!], applicationActivities: nil)  //FIXME hardcoded string
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            os_log("ImportExportViewController shareButtonAction", log: Log.viewcontroller, type: .error)
            
            let alertController = UIAlertController(title: Global.error, message: Global.documentNotFound, preferredStyle: .alert)
            let defaultAction = UIAlertAction.init(title: Global.ok, style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(defaultAction)
            navigationController!.present(alertController, animated: true, completion: nil)
        }
    } */
    
    
    // import button
    @IBAction func importFromCVSFileButton(_ sender: Any) {
        os_log("ImportExportViewController importFromCVSFileButton", log: Log.viewcontroller, type: .info)
        
        openFilesApp()
        
    }
    
    // MARK: - email
    /// Prepares mail sending controller
    ///
    /// **Extremely** important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
    /// - Returns: mailComposerVC
    
    func sendCSVEmail(path: URL?){
        
        os_log("ImportExportViewController sendCSVEmail", log: Log.viewcontroller, type: .info)
        
        // hide keyboard
        self.view.endEditing(true)
        
        let mailComposeViewController = configuredMailComposeViewController(url: path)
        
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

    
    // MARK: - document picker of files app
    
    func openFilesApp(){
        os_log("ImportExportViewController openFilesApp", log: Log.viewcontroller, type: .info)
        
        let controller = UIDocumentPickerViewController(
            documentTypes: [String(kUTTypeCommaSeparatedText)], // choose your desired documents the user is allowed to select
            in: .import // choose your desired UIDocumentPickerMode
        )
        controller.delegate = self
        if #available(iOS 11.0, *) {
            controller.allowsMultipleSelection = false
        }
        // e.g. present UIDocumentPickerViewController via your current UIViewController
        present(
            controller,
            animated: true,
            completion: nil
        )
    }
    /*
    @available(iOS 11.0, *)
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // do something with the selected documents
        os_log("ImportExportViewController multi documentPicker", log: Log.viewcontroller, type: .info)
    }*/
    
    // single document selection
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        // do something with the selected document
        os_log("ImportExportViewController single documentPicker", log: Log.viewcontroller, type: .info)
        
        importedRowsLabel.isHidden = true
        importedRowsLabel.text = ""
        
        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = false
        progressLabel.text = "0 %"
        importCVSFile(file: url.lastPathComponent)
        //print("BLA" + " " + url.lastPathComponent)
        //print(url.debugDescription)
    }
    
    // cancel opening/choosing files
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        os_log("ImportExportViewController documentPickerWasCancelled", log: Log.viewcontroller, type: .info)
        
        //FIXME put some info into label
    }
    
}
