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


class ExportViewController: UIViewController {

    @IBOutlet weak var exportCVSBarButton: UIBarButtonItem!
    
    @IBOutlet weak var exportPDFBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            
            let exportFilePath = NSTemporaryDirectory() + "inventoryexport.csv"
            let exportFileURL = URL(fileURLWithPath: exportFilePath)
            FileManager.default.createFile(atPath: exportFilePath, contents: Data(), attributes: nil)
            
            let fileHandle: FileHandle?
            do {
                fileHandle = try FileHandle(forWritingTo: exportFileURL)
            } catch let error as NSError {
                print("ERROR: \(error.localizedDescription)")
                fileHandle = nil
            }
            
            // write to disk
            
            if let fileHandle = fileHandle {
                var csvHeader = "inventoryName,dateofPurchase,price,serialNumber,remark,timeStamp,roomName,ownerName,categoryName,brandName,warranty\n"
                
                for item in results {
                    fileHandle.seekToEndOfFile()
                    guard let csvData = item
                        .csv()
                        .data(using: .utf8, allowLossyConversion: false) else {
                            continue
                    }
                    fileHandle.write(csvData)
                }
                
                fileHandle.closeFile()
                
                // print("Export Path: \(exportFilePath)")
                DispatchQueue.main.async {
                    self.navigationItem.leftBarButtonItem = self.exportBarButtonItem()
                    self.showExportFinishedAlertView(exportFilePath)
                }
            } else {
                DispatchQueue.main.async {
                    self.navigationItem.leftBarButtonItem = self.exportBarButtonItem()
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
    
    // export to cvs via backgroud task
    // fetch async array, if no array, return nil
    func exportPDFFile()
    {
        // not implemented yet
    }
    
    // MARK - button actions
    
    @IBAction func exportCVSButton(_ sender: Any) {
        exportCSVFile()
    }
    
    @IBAction func exportPDFButton(_ sender: Any) {
        exportPDFFile()
    }
    
}
