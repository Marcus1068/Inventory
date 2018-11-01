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

class ImportExportViewController: UIViewController {

    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var exportTextView: UITextView!
    @IBOutlet weak var exportLabel: UILabel!
    @IBOutlet weak var exportCVSBarButton: UIBarButtonItem!
    
    @IBOutlet weak var exportPDFBarButton: UIBarButtonItem!
    
    @IBOutlet weak var importedRowsLabel: UILabel!
    
    // MARK: view controller stuff
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        self.exportTextView.text = ""
        self.exportLabel.text = "Export file destination:"
        self.importedRowsLabel.isHidden = true

        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = true
        
        //self.navigationController?.title = "Export to CVS/PDF"
        //self.navigationItem.title = "Export to CVS/PDF"
        //self.navbar.bar
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.exportTextView.text = ""
        self.importedRowsLabel.isHidden = true
        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        navigationItem.leftBarButtonItem = activityIndicatorBarButtonItem()
       
        let container = CoreDataHandler.persistentContainer()
        
        container.performBackgroundTask { (context) in
            var exportedRows : Int = 0
            
            var results: [Inventory] = []
            
            do {
                results = try context.fetch(self.inventoryFetchRequest())
            } catch let error as NSError {
                print("ERROR: \(error.localizedDescription)")
            }
            
            let cvsFileName = Helper.cvsFile
            let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let pathURLcvs = docPath.appendingPathComponent(cvsFileName)
            let exportDocPath = pathURLcvs.absoluteString
            var csvText = "inventoryName,dateofPurchase,price,serialNumber,remark,timeStamp,roomName,ownerName,categoryName,brandName,warranty,imageFileName,invoiceFileName,id\n"
            
            var x : Int = 0
            
            for inv in results{
                csvText.append(contentsOf: inv.csv())
                
                x += 1
                DispatchQueue.main.async {
                    // update progress bar UI
                    let progress = Float(x) / Float(results.count)
                    self.progressView.setProgress(progress, animated: true)
                    self.progressLabel.text = String(progress * 100) + " %"
                }
                
                exportedRows += 1
            }
            
            do {
                try csvText.write(to: pathURLcvs, atomically: true, encoding: String.Encoding.utf8)
                //print("Export Path: \(exportDocPath)")
                DispatchQueue.main.async {
                    self.navigationItem.leftBarButtonItem = self.exportBarButtonItem()
                    self.exportTextView.text = exportDocPath
                    
                    // show alert box with path name
                    //self.showExportFinishedAlertView(exportFilePath)
                }
            } catch {
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
                    }
                }
            }
            
            DispatchQueue.main.async {
                // at the end of export report the number of exported rows to user
                self.importedRowsLabel.isHidden = false
                self.importedRowsLabel.text = "Exported rows: " + String(exportedRows)
                
                // set progress bar to 100% at the end of export
                self.progressView.setProgress(1.0, animated: true)
                self.progressLabel.text = "100 %"
            }
            
        }
        
        
    }
    
    func activityIndicatorBarButtonItem() -> UIBarButtonItem {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        let barButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        
        return barButtonItem
    }
    
    func exportBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(exportCVSButton(_:)))
    }
    
    // show message where file can be found
    func showExportFinishedAlertView(_ exportPath: String) {
        let message = "The exported CSV file can be found at \(exportPath)"
        let alertController = UIAlertController(title: "Export Finished", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
    }
    
    // MARK - import stuff
    
    // makin import loop
    func importCVSFile(file: String){
        
        var importedRows : Int = 0
       // var context: NSManagedObjectContext
       // context = CoreDataHandler.getContext()
        
        let data = readDataFromCSV(fileName: file)
        let csvRows = csvImportParser(data: data!)
        
        
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
                var inventory = Inventory(context: context)
                
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
                    // new category has to be inserted in owner table
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
                    // new brand has to be inserted in owner table
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
                    let imageData: NSData = image!.jpegData(compressionQuality: 1.0)! as NSData
                    inventory.image = imageData
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
        self.importedRowsLabel.text = "Imported rows: " + String(importedRows)
        
        progressView.setProgress(1.0, animated: true)
        progressLabel.text = "100 %"
    }
    
    // get jpeg image from file directory
    // FIXME must change to other directory
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    // read file as string
    // FIXME change directory
    func readDataFromCSV(fileName: String) -> String!{
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathURLcvs = docPath.appendingPathComponent(fileName)
        
        do {
            var contents = try String(contentsOfFile: pathURLcvs.path, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
            
        } catch {
            print("File import Read Error for cvs file \(pathURLcvs.absoluteString)", error)
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
    
    
    // share via ios system icon/method
    func exportToFileURL() -> URL? {
    
        // var contents: [String : Any] = [Keys.Name.rawValue: uname, Keys.Rating.rawValue: editing]
        
        var contents: [String: Any] = ["Test": String.self]
        /*
        
        if let image = beerImage() {
            if let data = UIImageJPEGRepresentation(image, 1) {
                contents[Keys.ImagePath.rawValue] = data.base64EncodedString()
            }
        }
        
        // 3
        if let note = note {
            contents[Keys.Note.rawValue] = note
        }
        */
        
        guard let path = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
        }
        
        let saveFileURL = path.appendingPathComponent("/\(uname).inv")
        (contents as NSDictionary).write(to: saveFileURL, atomically: true)
        
        return saveFileURL
    }
    
    // MARK - button actions
    
    @IBAction func exportCVSButton(_ sender: Any) {
        
        importedRowsLabel.isHidden = true
        importedRowsLabel.text = ""
        
        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = false
        progressLabel.text = "0 %"
        
        exportCSVFile()
    }
    
    // share system button
    @IBAction func exportShareButton(_ sender: Any) {
        
        let url = exportToFileURL()
        
        let activityViewController = UIActivityViewController(
            activityItems: ["Share Inventory data", url!],
            applicationActivities: nil)
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.barButtonItem = (sender as! UIBarButtonItem)
        }
        present(activityViewController, animated: true, completion: nil)
        
    }
    
    
    // import button
    @IBAction func importFromCVSFileButton(_ sender: Any) {

        importedRowsLabel.isHidden = true
        importedRowsLabel.text = ""
        
        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = false
        progressLabel.text = "0 %"
        
        importCVSFile(file: Helper.cvsFile)
        
    }
    
}
