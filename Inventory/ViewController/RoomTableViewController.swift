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
//  RoomTableViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import CoreData
import os

private let store = CoreDataStorage.shared

class RoomTableViewController: UITableViewController, UIPointerInteractionDelegate {

    
    // cell identifier
    fileprivate let cellIdentifier = "roomCell"
    
    // define fetch results controller based on core data entity (Room)
    // define sort descriptors
    // define cache
    // define sections (optional)
    lazy var fetchedResultsController: NSFetchedResultsController<Room> = {
        let fetchRequest: NSFetchRequest<Room> = Room.fetchRequest()
        //let zoneSort = NSSortDescriptor(key: #keyPath(Team.qualifyingZone), ascending: true)
        //let scoreSort = NSSortDescriptor(key: #keyPath(Team.wins), ascending: false)
        let nameSort = NSSortDescriptor(key: #keyPath(Room.roomName), ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: store.getContext(),
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    
    // add keyboard shortcuts to iPadOS screen when user long presses CMD key
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "", image: nil, action: #selector(doneButton), input: "D", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.done, state: .on),
            UIKeyCommand(title: "", image: nil, action: #selector(addButton), input: "A", modifierFlags: .command, propertyList: nil, alternates: [], discoverabilityTitle: Global.addRoom, state: .on)
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // UI controls color theme
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls

        // this will avoid displaying empty rows in the table
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.title = NSLocalizedString("My Rooms", comment: "My Rooms")
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
        //os_log("RoomTableViewController prepare", log: Log.viewcontroller, type: .info)
        
        let destination =  segue.destination as! RoomEditViewController
        
        if segue.identifier == "editSegueRoom"  {
            // Pass the selected object to the new view controller.
            let room = fetchedResultsController.object(at: self.tableView.indexPathForSelectedRow!)
            destination.currentRoom = room
        }
        
        if segue.identifier == "addSegueRoom"  {
            destination.currentRoom = nil
        }
        
    }
    
    @objc func addButton(){
        performSegue(withIdentifier: "addSegueRoom", sender: nil)
    }
    
    // close view controller
    @IBAction func doneButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
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
    func confirmDelete(room: Room) {
        let title = NSLocalizedString("Delete room", comment: "Delete room")
        let message = NSLocalizedString("Are you sure you really want to delete? Any related inventory will be deleted as well!", comment: "Are you sure you really want to delete")
        
        let myActionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // use closure to delete database entry
        let DeleteAction = UIAlertAction(title: Global.delete + " \(room.roomName!)", style: UIAlertAction.Style.destructive){ (ACTION) in
            _ = store.deleteRoom(room: room)
        }
        myActionSheet.addAction(DeleteAction)
        
        let CancelAction = UIAlertAction(title: Global.cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
            // do nothing when cancel
        }
        myActionSheet.addAction(CancelAction)
        
        addActionSheetForiPad(actionSheet: myActionSheet)
        present(myActionSheet, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension RoomTableViewController {
    
    // little blue info button as "detail" view (must be set in xcode at cell level
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        let idx = IndexPath(row: indexPath.row, section: 0)
        tableView.selectRow(at: idx, animated: true, scrollPosition: .middle)
        performSegue(withIdentifier: "editSegueRoom", sender: self)
    }
    
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        
        let room = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = room.roomName
        
        let imageData = room.roomImage! as Data
        let image = UIImage(data: imageData, scale:1.0)
        cell.imageView?.image = image!
        cell.backgroundColor = UIColor.clear
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
            let room = fetchedResultsController.object(at: indexPath)
            confirmDelete(room: room)
        }
    }
    
    #if targetEnvironment(macCatalyst)
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        
        touchBar.defaultItemIdentifiers = [.touchDone, .fixedSpaceSmall, .touchAdd]
        
        let done = NSButtonTouchBarItem(identifier: .touchDone, title: Global.done, target: self, action: #selector(doneButton(_:)))
        done.bezelColor = Global.colorGreen
        
        let addNew = NSButtonTouchBarItem(identifier: .touchAdd, image: UIImage(systemName: "plus")!, target: self, action: #selector(addButton))
        
        touchBar.templateItems = [done, addNew]
        
        return touchBar
    }

    #endif
}


// MARK: - NSFetchedResultsControllerDelegate
extension RoomTableViewController: NSFetchedResultsControllerDelegate {
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
            os_log("RoomTableViewController controller", log: Log.viewcontroller, type: .error)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // in case a section gets added or deleted
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
