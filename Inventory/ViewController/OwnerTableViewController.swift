//
//  OwnerTableViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 01.05.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import CoreData
import os.log

class OwnerTableViewController: UITableViewController {
    
    // cell identifier
    fileprivate let cellIdentifier = "ownerCell"
    
    // define fetch results controller based on core data entity
    // define sort descriptors
    // define cache
    // define sections (optional)
    lazy var fetchedResultsController: NSFetchedResultsController<Owner> = {
        let fetchRequest: NSFetchRequest<Owner> = Owner.fetchRequest()
        //let zoneSort = NSSortDescriptor(key: #keyPath(Team.qualifyingZone), ascending: true)
        //let scoreSort = NSSortDescriptor(key: #keyPath(Team.wins), ascending: false)
        let nameSort = NSSortDescriptor(key: #keyPath(Owner.ownerName), ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataHandler.getContext(),
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    @IBOutlet weak var doneButtonLabel: UIBarButtonItem!
    @IBOutlet weak var addButtonLabel: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // this will avoid displaying empty rows in the table
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.title = "My Owners"
        self.tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.bottom, animated: true)
        
        // fetch database contents
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
    }
    
    
    // prepare to transfer data to another view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        os_log("prepare for segue", log: OSLog.default, type: .debug)
        
        let destination =  segue.destination as! OwnerEditViewController
        
        if segue.identifier == "editSegueOwner"  {
            // Pass the selected object to the new view controller.
            let owner = fetchedResultsController.object(at: self.tableView.indexPathForSelectedRow!)
            destination.currentOwner = owner
        }
        
        if segue.identifier == "addSegueOwner"  {
            destination.currentOwner = nil
        }
        
    }
    
    // return true if ok is clicked, false otherwise
    func showAlertDialog() -> Bool{
        
        var result : Bool = false
        // Declare Alert
        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete? All inventory objects depending will be deleted as well...", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .destructive, handler: { (action) -> Void in
            result = true
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            result = false
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
    func confirmDelete(owner: Owner) {
        let alert = UIAlertController(title: "Delete owner", message: "Are you sure you want to permanently delete \(owner.ownerName!)? Any related inventory with this owner will be deleted as well!", preferredStyle: .actionSheet)
        
        // use closure to delete database entry
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive){ (action:UIAlertAction) in
            _ = CoreDataHandler.deleteOwner(owner: owner)
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

// MARK: - UITableViewDataSource
extension OwnerTableViewController {
    
    // little blue info button as "detail" view (must be set in xcode at cell level
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        os_log("accessoryButtonTappedForRowWith", log: OSLog.default, type: .debug)
        //print(indexPath.row)
        let idx = IndexPath(row: indexPath.row, section: 0)
        tableView.selectRow(at: idx, animated: true, scrollPosition: .middle)
        performSegue(withIdentifier: "editSegueOwner", sender: self)
    }
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        
        let owner = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = owner.ownerName
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
            let owner = fetchedResultsController.object(at: indexPath)
            confirmDelete(owner: owner)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension OwnerTableViewController: NSFetchedResultsControllerDelegate {
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
