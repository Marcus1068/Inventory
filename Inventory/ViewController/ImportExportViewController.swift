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
import os.log


class ImportExportViewController: UIViewController {

    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var exportTextView: UITextView!
    @IBOutlet weak var exportLabel: UILabel!
    @IBOutlet weak var exportCVSBarButton: UIBarButtonItem!
    
    @IBOutlet weak var exportPDFBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        self.exportTextView.text = ""
        self.exportLabel.text = "Export file destination:"
        //self.title = "Export to CVS/PDF"

        //self.navigationController?.title = "Export to CVS/PDF"
        //self.navigationItem.title = "Export to CVS/PDF"
        //self.navbar.bar
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.exportTextView.text = ""
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
            var csvText = "inventoryName,dateofPurchase,price,serialNumber,remark,timeStamp,roomName,ownerName,categoryName,brandName,warranty,imageFileName,invoiceFileName\n"
            
            for inv in results{
                csvText.append(contentsOf: inv.csv())
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
                    if let data = UIImageJPEGRepresentation(image!, 1.0),
                        !FileManager.default.fileExists(atPath: pathURLjpg.path) {
                        do {
                            // writes the image data to disk
                            try data.write(to: pathURLjpg, options: .atomic)
                            //print("jpg file saved")
                        } catch {
                            print("error saving jpg file:", error)
                        }
                    }
                }
                // export PDF files
                if inv.invoiceFileName != "" {
                    let pathURLpdf = docPath.appendingPathComponent(inv.invoiceFileName!)
                    // get your UIImage jpeg data representation and check if the destination file url already exists
                    let invoiceData = inv.invoice! as Data
                    do {
                        // writes the image data to disk
                        try invoiceData.write(to: pathURLpdf, options: .atomic)
                        //print("pdf file saved")
                    } catch {
                        print("error saving pdf file:", error)
                    }
                }
            }
        }
    }
    
    func activityIndicatorBarButtonItem() -> UIBarButtonItem {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
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
    
    func importCVSFile(file: String){
        var data = readDataFromCSV(fileName: file)
        data = cleanRows(file: data!)
        let csvRows = csvImportParser(data: data!)
        
        //get data into string array
        print(csvRows[1][1])
        
        // get strings into core data
        
        // read jpg and pdf files into memory and update core data
    }
    
    func readDataFromCSV(fileName: String) -> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: "cvs")
            else {
                return nil
        }
        
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File import Read Error for cvs file \(filepath)")
            return nil
        }
    }

    func cleanRows(file: String) -> String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";;", with: "")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
        return cleanFile
    }
    
    // import cvs file parser
    func csvImportParser(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    // MARK - button actions
    
    @IBAction func exportCVSButton(_ sender: Any) {
        exportCSVFile()
    }
    
    @IBAction func exportPDFButton(_ sender: Any) {
        //exportPDFFile()
    }
    
    // import button
    @IBAction func importFromCVSFileButton(_ sender: Any) {
        importCVSFile(file: Helper.cvsFile)
    }
    
}
