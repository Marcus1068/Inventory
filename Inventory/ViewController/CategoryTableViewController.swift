//
//  CategoryTableViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 01.05.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os.log

class CategoryTableViewController: UITableViewController {

    var categories : [Category] = []
    
    @IBOutlet weak var doneButtonLabel: UIBarButtonItem!
    @IBOutlet weak var addButtonLabel: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // this will avoid displaying empty rows in the table
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // necessary for accessing table cells
        //tableView.dataSource = self
        //tableView.delegate = self
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        self.title = "My Categories"
        
        self.tableView.scrollToNearestSelectedRow(at: UITableViewScrollPosition.bottom, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        // get the data from Core Data
        categories = CoreDataHandler.fetchAllCategories()
        
        // reload the table
        tableView.reloadData()
        
        //select first row of table
        if(categories.count > 0)
        {
            let idx = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: idx, animated: true, scrollPosition: .top)
        }
        
        self.tableView.scrollToNearestSelectedRow(at: UITableViewScrollPosition.bottom, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        // Configure the cell...
        
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.categoryName
        // cell.detailTextLabel?.text =
        
        return cell
    }
    

    // little blue info button as "detail" view (must be set in xcode at cell level
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        os_log("accessoryButtonTappedForRowWith", log: OSLog.default, type: .debug)
        //print(indexPath.row)
        let idx = IndexPath(row: indexPath.row, section: 0)
        tableView.selectRow(at: idx, animated: true, scrollPosition: .middle)
        performSegue(withIdentifier: "editSegueCategory", sender: self)
    }
    
    // prepare to transfer data to another view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        os_log("prepare for segue", log: OSLog.default, type: .debug)
        
        let destination =  segue.destination as! CategoryEditViewController
        
        if segue.identifier == "editSegueCategory"  {
            // Pass the selected object to the new view controller.
            if let indexPath = self.tableView.indexPathForSelectedRow { // FIXME
                let selectedCategory = categories[indexPath.row]
                destination.currentCategory = selectedCategory
            }
        }
        
        if segue.identifier == "addSegueCategory"  {
            destination.currentCategory = nil
        }
        
    }

    // delete rows via UI with swipe gesture
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
        if editingStyle == .delete{
            let category = categories[indexPath.row]
            confirmDelete(category: category)
        }
    }

    // return true if ok is clicked, false otherwise
    func showAlertDialog() -> Bool{
        
        var result : Bool = false
        // Declare Alert
        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete? All inventory objects depending will be deleted as well...", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .destructive, handler: { (action) -> Void in
            print("Ok button click...")
            result = true
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            result = false
            print("Cancel button click...")
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
        
        return result
    }
    
    // UIAlert for asking user if delete is really ok
    // UIAlert view is not modal so we need to do it this way
    func confirmDelete(category: Category) {
        let alert = UIAlertController(title: "Delete category", message: "Are you sure you want to permanently delete \(category.categoryName!)? Any related inventory with this category will be deleted as well!", preferredStyle: .actionSheet)
        
        // use closure to delete database entry
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive){ (action:UIAlertAction) in
            // delete must be used with persistentContainer.viewContext not context
            _ = CoreDataHandler.deleteCategory(category: category)
            //self.context.saveContext()
            
            self.categories = CoreDataHandler.fetchAllCategories()
            
            self.tableView.reloadData()
        }
        
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // will do nothing
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func doneButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButton(_ sender: Any) {
    }
    
    
}
