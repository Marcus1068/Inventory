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
            
            let fileName = "inventoryexport.csv"
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            let exportFilePath = NSTemporaryDirectory() + fileName
            
            var csvText = "inventoryName,dateofPurchase,price,serialNumber,remark,timeStamp,roomName,ownerName,categoryName,brandName,warranty\n"
            
            for inv in results{
                csvText.append(contentsOf: inv.csv())
            }
            
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                print("Export Path: \(exportFilePath)")
                DispatchQueue.main.async {
                    self.navigationItem.leftBarButtonItem = self.exportBarButtonItem()
                    self.exportTextView.text = exportFilePath
                    //self.showExportFinishedAlertView(exportFilePath)
                }
                
            } catch {
                
                print("Failed to create inventory csv file")
                print("\(error)")
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
