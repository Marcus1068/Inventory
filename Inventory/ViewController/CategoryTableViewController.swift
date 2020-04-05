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
//  CategoryTableViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 01.05.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import CoreData
import os

private let store = CoreDataStorage.shared

class CategoryTableViewController: UITableViewController, UIPointerInteractionDelegate {

    // cell identifier
    fileprivate let cellIdentifier = "categoryCell"
    
    // define fetch results controller based on core data entity (Room)
    // define sort descriptors
    // define cache
    // define sections (optional)
    lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        //let zoneSort = NSSortDescriptor(key: #keyPath(Team.qualifyingZone), ascending: true)
        //let scoreSort = NSSortDescriptor(key: #keyPath(Team.wins), ascending: false)
        let nameSort = NSSortDescriptor(key: #keyPath(Category.categoryName), ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: store.getContext(),
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    @IBOutlet weak var doneButtonLabel: UIBarButtonItem!
    @IBOutlet weak var addButtonLabel: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //os_log("CategoryTableViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // UI controls color theme
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
        
        // this will avoid displaying empty rows in the table
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.title = NSLocalizedString("My Categories", comment: "My Categories")
        self.tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.bottom, animated: true)
        
        // fetch database contents
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("CategoryTableViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        }
        
    }

    
    // prepare to transfer data to another view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //os_log("CategoryTableViewController prepare", log: Log.viewcontroller, type: .info)
        
        let destination =  segue.destination as! CategoryEditViewController
        
        if segue.identifier == "editSegueCategory"  {
            // Pass the selected object to the new view controller.
            let category = fetchedResultsController.object(at: self.tableView.indexPathForSelectedRow!)
            destination.currentCategory = category
        }
        
        if segue.identifier == "addSegueCategory"  {
            destination.currentCategory = nil
        }
        
    }


    // return true if ok is clicked, false otherwise
    func showAlertDialog() -> Bool{
        var result : Bool = false
        // Declare Alert
        let message = NSLocalizedString("Are you sure you want to delete? All inventory objects depending will be deleted as well...", comment: "Are you sure you want to delete? All inventory objects depending will be deleted as well...")
        let dialogMessage = UIAlertController(title: Global.confirm, message: message, preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: Global.ok, style: .destructive, handler: { (action) -> Void in
            //print("Ok button click...")
            result = true
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: Global.cancel, style: .cancel) { (action) -> Void in
            result = false
            //print("Cancel button click...")
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
        let title = NSLocalizedString("Delete category", comment: "Delete category")
        
        let message = NSLocalizedString("Are you sure you really want to delete? Any related inventory will be deleted as well!", comment: "Are you sure you really want to delete")
        
        let myActionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // use closure to delete database entry
        let DeleteAction = UIAlertAction(title: Global.delete + " \(category.categoryName!)", style: UIAlertAction.Style.destructive){ (ACTION) in
            _ = store.deleteCategory(category: category)
        }
        
        let CancelAction = UIAlertAction(title: Global.cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
            // do nothing when cancel
        }
        
        myActionSheet.addAction(DeleteAction)
        myActionSheet.addAction(CancelAction)
        
        addActionSheetForiPad(actionSheet: myActionSheet)
        present(myActionSheet, animated: true, completion: nil)
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

// MARK: - UITableViewDataSource
extension CategoryTableViewController {
    // little blue info button as "detail" view (must be set in xcode at cell level
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        //os_log("CategoryTableViewController tableView", log: Log.viewcontroller, type: .info)
        
        //print(indexPath.row)
        let idx = IndexPath(row: indexPath.row, section: 0)
        tableView.selectRow(at: idx, animated: true, scrollPosition: .middle)
        performSegue(withIdentifier: "editSegueCategory", sender: self)
    }
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        let category = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = category.categoryName
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size:20)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        configure(cell: cell, for: indexPath)
        
        // pointer interaction
        if #available(iOS 13.4, *) {
            customPointerInteraction(on: cell, pointerInteractionDelegate: self)
        } else {
            // Fallback on earlier versions
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }
    
    // delete rows via UI with swipe gesture
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete{
            let category = fetchedResultsController.object(at: indexPath)
            confirmDelete(category: category)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension CategoryTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!)
            configure(cell: cell!, for: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        @unknown default:
            os_log("CategoryTableViewController controller", log: Log.viewcontroller, type: .error)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default: break
        }
    }
}
