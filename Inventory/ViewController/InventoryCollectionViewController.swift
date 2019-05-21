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
//  InventoryCollectionViewController.swift
//  Inventory
//  initial view controller, will be loaded after appdelegate and before other view controllers
//
//  Created by Marcus Deuß on 25.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import CoreData
import os
import MobileCoreServices
import AVFoundation
import PDFKit


private let reuseIdentifier = "collectionCellReports"
private var selectedInventoryItem = Inventory()

class InventoryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UICollectionViewDropDelegate {
    
    
    // define fetch results controller based on core data entity (Room)
    // define sort descriptors
    // define cache
    // define sections (optional)
    lazy var fetchedResultsController: NSFetchedResultsController<Inventory> = {
        let fetchRequest: NSFetchRequest<Inventory> = Inventory.fetchRequest()
        let roomSort = NSSortDescriptor(key: #keyPath(Inventory.inventoryRoom.roomName), ascending: true)
        let invnameSort = NSSortDescriptor(key: #keyPath(Inventory.inventoryName), ascending: true)
        fetchRequest.sortDescriptors = [roomSort, invnameSort]  // first by section sort, then by item name sort
        fetchRequest.predicate = nil
        //          NSPredicate(format: "inventoryRoom.inventoryName = %@", searchText) : nil
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataHandler.getContext(),
            sectionNameKeyPath: #keyPath(Inventory.inventoryRoom.roomName),     // section defined here
            cacheName: nil)  // "inventoryCache"
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
   
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var ownersSegment: UISegmentedControl!
    @IBOutlet weak var roomsSegment: UISegmentedControl!
    @IBOutlet weak var filterByOwnerLabel: UILabel!
    @IBOutlet weak var filterByRoomLabel: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!
    @IBOutlet weak var numberOfItems: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    
    // gesture recignizer for long press
    var gestureRecognizer = UILongPressGestureRecognizer()
    
    // store original nav bar buttons
    var leftNavBarButton : UIBarButtonItem? = nil
    var rightNavBarButton : UIBarButtonItem? = nil
    
    var owner : [Owner] = []
    var room : [Room] = []
    var brand: [Brand] = []
    var category: [Category] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var dest = InventoryEditViewController()    // destination view controller
    var selectedForDeleteInventory:[Inventory] = []
    
    // store selected items when delete mode = true
    var indexPathsForDeletion = [IndexPath]()
    
    // needed for long press gesture recognizer
    var longPressInventoryItem : Inventory?
    
    // enter delete mode
    var deleteMode: Bool = false {
        didSet {
            collection?.allowsMultipleSelection = deleteMode
            
            guard deleteMode else {
                // restore buttons to original setup
                navigationItem.setLeftBarButtonItems([leftNavBarButton!], animated: true)
                navigationItem.setRightBarButtonItems([rightNavBarButton!], animated: true)
                
                return
            }
        }
    }
    
    // MARK: - drop support
    
    // define the file types for drop support
    func collectionView(_ collectionView: UICollectionView,
                        canHandle session: UIDropSession) -> Bool{
        //os_log("InventoryCollectionViewController dropSessionDidUpdate", log: Log.viewcontroller, type: .info)
        
        return session.hasItemsConforming(toTypeIdentifiers:
            [kUTTypeImage as String, kUTTypePDF as String])
    }
    
    // As the user’s finger moves, the collection view tracks the potential drop location and notifies your delegate by calling its collectionView(_:dropSessionDidUpdate:withDestinationIndexPath:)
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
        //os_log("InventoryCollectionViewController dropSessionDidUpdate", log: Log.viewcontroller, type: .info)
        
        if session.localDragSession != nil {
            return UICollectionViewDropProposal(operation: .forbidden,
                                                intent: .unspecified)
        } else {
            return UICollectionViewDropProposal(operation: .copy,
                                                intent: .insertIntoDestinationIndexPath)
        }
    }
    
    // perform the drop operation, get image from external app and change image of selected (dropped) inventory item
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        //os_log("InventoryCollectionViewController dropSessionDidUpdate", log: Log.viewcontroller, type: .info)
        
        let destinationIndexPath =
            coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        switch coordinator.proposal.operation {
        case .copy:
            
            let items = coordinator.items
            
            for item in items {
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: {(newImage, error)  -> Void in
                    
                    if let image = newImage as? UIImage {
                        DispatchQueue.main.async {
                            let inv = self.fetchedResultsController.object(at: destinationIndexPath)
                            //print(inv.inventoryName!)
                            // image binary data
                            let imageData = image.jpegData(compressionQuality: Global.imageQuality)
                            inv.image = imageData! as NSData
                            inv.imageFileName = Global.generateFilename(invname: inv.inventoryName!) + ".jpg"
                            
                            _ = CoreDataHandler.saveInventory(inventory: inv)
                            
                            self.collection.reloadData()
                            
                            // create a sound ID, in this case its the tweet sound.
                            let systemSoundID: SystemSoundID = SystemSoundID(Global.systemSound)
                            
                            // to play sound
                            AudioServicesPlaySystemSound (systemSoundID)
                        }
                        //self.images.insert(image, at: destinationIndexPath.item)
                        
                        /*DispatchQueue.main.async {
                            collectionView.insertItems(
                                at: [destinationIndexPath])
                        } */
                    }
                })
                
                item.dragItem.itemProvider.loadObject(ofClass: DropFile.self) { (provider, error) in
                    //print("loaded urls")
                    DispatchQueue.main.async {
                        if let fileItem = provider as? DropFile {
                            let inv = self.fetchedResultsController.object(at: destinationIndexPath)
                            //print(inv.inventoryName!)
                            
                            let url = Global.createTempDropObject(fileItems: [fileItem])
                            let pdf = PDFDocument(url: url!) // FIXME change to document instead of pdf document
                            inv.invoice = pdf?.dataRepresentation() as NSData?
                            inv.invoiceFileName = Global.generateFilename(invname: inv.inventoryName!) + ".pdf"
                            _ = CoreDataHandler.saveInventory(inventory: inv)
                            
                            self.collection.reloadData()
                            
                            // create a sound ID, in this case its the tweet sound.
                            let systemSoundID: SystemSoundID = SystemSoundID(Global.systemSound)
                            
                            // to play sound
                            AudioServicesPlaySystemSound (systemSoundID)
                            }
                        }
                    }
            }
        default: return
        }
    }
    
    // MARK: - methods
    
    // fill a segment controll with values
    func replaceSegmentContents(segments: Array<String>, control: UISegmentedControl) {
        control.removeAllSegments()
        for segment in segments {
            control.insertSegment(withTitle: segment, at: control.numberOfSegments, animated: false)
        }
    }
    
    // first actions taken here
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //os_log("InventoryCollectionViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        
        
        
    /*    if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
       */
        //self.navigationItem.titleView = UIView()
         self.title = nil
        
        // to enable drag/drop support
        collection.dropDelegate = self
        
        // enable filtering
        filterSwitch.isOn = true
        
        // set colors for UI controls
        filterSwitch.tintColor = themeColorUIControls
        filterSwitch.onTintColor = themeColorUIControls
        roomsSegment.tintColor = themeColorUIControls
        ownersSegment.tintColor = themeColorUIControls
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
        
        
        // set collection view delegates
        collection.delegate = self
        collection.dataSource = self


        // Do any additional setup after loading the view.
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.delegate = self
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        self.navigationItem.titleView = searchController.searchBar
        searchController.searchBar.placeholder = NSLocalizedString("Search for Inventory", comment: "Search for Inventory")
        searchController.searchBar.delegate = self
        searchController.searchBar.showsScopeBar = false
        navigationController?.isNavigationBarHidden = false
   
        self.navigationItem.hidesSearchBarWhenScrolling = false;
        
        let collectionViewLayout = collection.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)   // some distance to top/buttom/left/rigth
        collectionViewLayout?.invalidateLayout()
        
        //collection.contentOffset.y += 100
        
        leftNavBarButton = self.navigationItem.leftBarButtonItems?.first
        rightNavBarButton = self.navigationItem.rightBarButtonItems?.first
        
        // check for camera permission
        let _ = Global.checkCameraPermission()
        
        
    }

    fileprivate func updateNumberOfItemsLabel() {
        let obj = NSLocalizedString("items", comment: "items")
        let countAll = fetchedResultsController.fetchedObjects?.count ?? 0
        self.numberOfItems.text = String(countAll) + " " + obj + " " + NSLocalizedString("in inventory", comment: "in inventory")
    }
    
    // initialize the data for the view
    // fetch database etc.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
        //os_log("InventoryCollectionViewController viewWillAppear", log: Log.viewcontroller, type: .info)
        
        // reset: no inv item selected
        longPressInventoryItem = nil
        
        // clear selected index paths
        //indexPathsForDeletion.removeAll()
        //selectedForDeleteInventory.removeAll()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController viewWillAppear", log: Log.coredata, type: .error)
        }
        
        //self.title = NSLocalizedString("My Inventory", comment: "My Inventory")
        
        updateNumberOfItemsLabel()
        
        collection.reloadData()
        
        // Setup the Scope Bars
        owner = CoreDataHandler.fetchAllOwners()
        room = CoreDataHandler.fetchAllRooms()
        
        // also load brand and category to see if there are any object
        category = CoreDataHandler.fetchAllCategories()
        brand = CoreDataHandler.fetchAllBrands()
        
        var listOwners :[String] = []
        var listRooms :[String] = []
        
        let allOwners = Global.all
        listOwners.append(allOwners)
        for inv in owner{
            listOwners.append((inv.ownerName)!)
        }
        ownerLabel.text = Global.all
        
        replaceSegmentContents(segments: listOwners, control: ownersSegment)
        ownersSegment.selectedSegmentIndex = 0
        
        let allRooms = Global.all
        listRooms.append(allRooms)
        for inv in room{
            listRooms.append((inv.roomName)!)
        }
        roomLabel.text = Global.all
        
        replaceSegmentContents(segments: listRooms, control: roomsSegment)
        roomsSegment.selectedSegmentIndex = 0
        
        // set collection view to always scroll to top when opening view
        if fetchedResultsController.fetchedObjects!.count > 0{
            let indexPathForFirstRow = IndexPath(row: 0, section: 0)
            self.collection?.selectItem(at: indexPathForFirstRow, animated: true, scrollPosition: .top)
        }
        
        // register peek and pop function
        registerForPeekAndPopWithCollectionView(collectionView: collection)
    }
    
    // when user chooses a different tab bar item and view disapprears
    override func viewWillDisappear(_ animated: Bool) {
        /* print("disappear")
        collection.removeGestureRecognizer(gestureRecognizer)
        collection.resignFirstResponder() */
    }
    
    // number of sections, section devider is room name
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        
        return sections.count
    }
    
    // number of collection items, depends on filtering on or off (searchbar used or not)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InventoryCollectionViewCell
    
        // rounded corners for each cell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        // Configure the cell
    
        let inv = fetchedResultsController.object(at: indexPath)
        
        //let currentInventory : Inventory
        
        //currentInventory = inv
        
        cell.inventoryLabel.text = inv.inventoryName
        cell.ownerLabel.text = inv.inventoryOwner?.ownerName?.truncate(length: 11)
        cell.brandNameLabel.text = inv.inventoryBrand?.brandName?.truncate(length: 11)
        cell.categoryLabel.text = inv.inventoryCategory?.categoryName?.truncate(length: 11)
        
        cell.priceLabel.text = String(inv.price) + Global.currencySymbol!
        
        var image: UIImage
        
        if inv.image != nil{
            let imageData = inv.image! as Data
            image = UIImage(data: imageData, scale:1.0)!
        }
        else{
            // to image, set default image
            let defaultImage = #imageLiteral(resourceName: "Room Icon")
            image = defaultImage
        }
        
        cell.myImage.image = image
        cell.layer.borderWidth = 0.0
        cell.layer.borderColor = UIColor.clear.cgColor
        
        return cell
    }
    
    // used for footer usage displaying a label with number of elements
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collection.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "reportHeader",
                                                                         for: indexPath) as! InventoryHeaderCollectionReusableView
            let sectionInfo = fetchedResultsController.sections?[indexPath.section]
            headerView.roomLabel.text = sectionInfo?.name
            let room = CoreDataHandler.fetchRoomIcon(roomName: (sectionInfo?.name)!)
            let imageData = room!.roomImage! as Data
            let image = UIImage(data: imageData, scale:1.0)
            headerView.roomIcon.image = image
            
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collection.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "reportFooter",
                                                                         for: indexPath) as! InventoryFooterCollectionReusableView
            
            let sectionInfo = fetchedResultsController.sections?[indexPath.section]
            //footerView.searchResultLabel.textColor = themeColor
            //footerView.searchResultLabel.text = String(sectionInfo!.numberOfObjects) + " Inventory item"
            
            if(sectionInfo!.numberOfObjects > 1){
                footerView.searchResultLabel.text = String(sectionInfo!.numberOfObjects) + " " + NSLocalizedString("Inventory items", comment: "Inventory items")
            }
            else{
                footerView.searchResultLabel.text = String(sectionInfo!.numberOfObjects) + " " + NSLocalizedString("Inventory item", comment: "Inventory item")
            }
            
            
            return footerView
            
        default:
            os_log("InventoryCollectionViewController collectionView viewForSupplementaryElementOfKind", log: Log.viewcontroller, type: .error)
            assert(false, "Unexpected element kind")
            
        }
        
        fatalError("Unexpected element kind")
    }

    // selects a cell with thick border in theme color
    private func selectCell(indexPath: IndexPath){
        let cell = collection.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 4.0
        cell?.layer.borderColor = themeColor.cgColor
        
    }
    
    // deselects a cell to remove thick border and theme color
    private func deSelectCell(indexPath: IndexPath){
        let cell = collection.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0.0
        cell?.layer.borderColor = UIColor.clear.cgColor
        
    }
    /*
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let inv = fetchedResultsController.object(at: indexPath)
        
        dest.currentInventory = inv
        selectedInventoryItem = inv
        
        //collectionView.cellForItem(at: indexPath as IndexPath)?.backgroundColor = UIColor.red
        if deleteMode{
            selectCell(indexPath: indexPath)
            selectedForDeleteInventory.append(inv)
            indexPathsForDeletion.append(indexPath)
            //print("selected \(indexPathsForDeletion.count)")
        }
        
        return true
    } */
    
    // The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let cell = collectionView.cellForItem(at: indexPath) as! InventoryCollectionViewCell
        
        //cell.toggleSelected()
       
        let inv = fetchedResultsController.object(at: indexPath)
        
        dest.currentInventory = inv
        selectedInventoryItem = inv

        //collectionView.cellForItem(at: indexPath as IndexPath)?.backgroundColor = UIColor.red
        if deleteMode{
            selectCell(indexPath: indexPath)
            selectedForDeleteInventory.append(inv)
            indexPathsForDeletion.append(indexPath)
            //print("selected \(indexPathsForDeletion.count)")
        }
    }
    
    // will be called before prepare and avoids core data error:
    // "Core data error at runtime: Failed to call designated initializer on NSManagedObject class "Inventory""
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        let inv = fetchedResultsController.object(at: indexPath)
        
        dest.currentInventory = inv
        selectedInventoryItem = inv
        
        return true
    }
    
    // The collection view calls this method when the user successfully deselects an item in the collection view. It does not call this method when you programmatically deselect items.
    // when deselecting collection items remove them from list of objects to delete
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //let cell = collectionView.cellForItem(at: indexPath) as! InventoryCollectionViewCell
        
        //cell.toggleSelected()
        
        if deleteMode{
            if indexPathsForDeletion.count > 0{
                selectedForDeleteInventory.removeLast()
                deSelectCell(indexPath: indexPath)
                indexPathsForDeletion.removeLast()
                //print("selected \(indexPathsForDeletion.count)")
            }
        }
    }

    // avoid automatic segue in case of delete mode
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        // do not perform segue if delete mode
        if deleteMode  {
            // your code here, like badParameters  = false, e.t.c
            return false
        }
        
        // check if any rooms, categories, brands and owners are available, otherwise refuse to add an item
        if room.count > 0 && category.count > 0 && brand.count > 0 && owner.count > 0{
            return true
        }
        else{
            let message = NSLocalizedString("Please add at least one room, category, owner and brand in 'Manage Items' for adding new inventory objects", comment: "Please add at least one room, category, owner and brand in 'Manage Items' for adding new inventory objects") 
            let myActionSheet = UIAlertController(title: Global.error, message: message, preferredStyle: UIAlertController.Style.actionSheet)
            
            let action = UIAlertAction(title: Global.cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
                // do nothing when cancel
            }
            
            myActionSheet.addAction(action)
            addActionSheetForiPad(actionSheet: myActionSheet)
            present(myActionSheet, animated: true, completion: nil)
            
            return false
        }
        
        //return true
    }
    
    // prepare to transfer data to another view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //os_log("InventoryCollectionViewController prepare", log: Log.viewcontroller, type: .info)
        
        let destination =  segue.destination as! InventoryEditViewController
        
        if segue.identifier == "addSegue" {
            
            destination.currentInventory = nil
        }
        
        if segue.identifier == "editSegue"  {
            destination.currentInventory = selectedInventoryItem
            dest = destination
        }
    }
    
    // MARK - search
    
    // needed for iPad
    func configureCancelBarButton() {
        //let cancelButton = UIBarButtonItem()
        //cancelButton.image = UIImage(named: "cancelButton")
        //cancelButton.action = #selector(InventoryCollectionViewController.iPadCancelButton)
        //cancelButton.target = self
        self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(InventoryCollectionViewController.iPadCancelButton)), animated: true)
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        //self.navigationItem.setLeftBarButton(cancelButton, animated: true)
    }
   
    @objc func iPadCancelButton()
    {
        fetchedResultsController.fetchRequest.predicate = nil
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController iPadCancelButton", log: Log.viewcontroller, type: .error)
        }
        
        self.searchController.searchBar.endEditing(true)
        searchController.searchBar.text? = ""
        navigationItem.setLeftBarButtonItems([leftNavBarButton!], animated: true)
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        collection.reloadData()
    }
    
    // called by system when entered search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
        // It's an iPhone
            break
            
        case .pad:
        // It's an iPad
            configureCancelBarButton()
            break
            
        case .unspecified:
            // Uh, oh! What could it be?
            break
            
        default:
            break
        }
        
    }
    
    // called when search bar cancel button was clicked, does only work on iPhones, not iPad (Apple bug)
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchedResultsController.fetchRequest.predicate = nil
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController searchBarTextDidBeginEditing", log: Log.viewcontroller, type: .error)
        }
        
        collection.reloadData()
    }
    
    // something entered in search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
/*        if (searchBarIsEmpty()){
            fetchedResultsController.fetchRequest.predicate = nil
            do {
                try fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("Fetching error: \(error), \(error.userInfo)")
            }
            collection.reloadData()
        } else {
            //currentInventory = inventory[indexPath.row]
        }
        
        //print("Taste") */
    }
    
    // called by system when entered search bar
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchController.searchBar.showsScopeBar = true
        if (!searchBarIsEmpty()){
            /*        fetchedResultsController.fetchRequest.predicate = nil
             do {
             try fetchedResultsController.performFetch()
             } catch let error as NSError {
             print("Fetching error: \(error), \(error.userInfo)")
             }
             collection.reloadData() */
            //searchBar.text = "AAAA"
        }
    }
    
    // self implemented method
    func filterContentForSearchText(_ searchText: String) {
        
        /*       filteredInventory = inventory.filter({( inv : Inventory) -> Bool in
         let doesOwnerMatch = (scope == "All") || (inv.inventoryOwner?.ownerName == scope)
         
         if searchBarIsEmpty() {
         return doesOwnerMatch
         } else {
         return doesOwnerMatch && inv.inventoryName!.lowercased().contains(searchText.lowercased())
         }
         })
         */
        fetchedResultsController.fetchRequest.predicate = searchText.count > 0 ?
            NSPredicate(format: "inventoryName contains[c] %@", searchText.lowercased()) : nil
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController filterContentForSearchText", log: Log.coredata, type: .error)
        }
        
        collection.reloadData()
    }
    
    // Returns true if the search text is empty or nil
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // is filter mode enabled?
    func isFiltering() -> Bool {
        // true if search controller is active AND (search bar is not empty OR scope filter active)
        return searchController.isActive && (!searchBarIsEmpty())
    }
    
    // called by system - main search method
    func updateSearchResults(for searchController: UISearchController)
    {
        if(!searchBarIsEmpty()){
            filterContentForSearchText(searchController.searchBar.text!)
        }
    }
    
    // MARK  - Actions
    
    // rooms segment selection
    @IBAction func roomsSelectionSegment(_ sender: Any) {
        switch roomsSegment.selectedSegmentIndex
        {
        case 0: // not filtering by rooms
            // not filtering by room, not filtering by owners
            if(ownersSegment.selectedSegmentIndex == 0)
            {
                fetchedResultsController.fetchRequest.predicate = nil
                roomLabel.text = Global.all
            }
                // not filtering by rooms, filtering by owners
            else{
                let ownerName = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
                ownerLabel.text = ownerName
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryOwner.ownerName = %@", ownerName!)
            }
            break
            
        default:    // filtering by rooms
            // filtering by rooms, not filtering by owners
            if(ownersSegment.selectedSegmentIndex == 0)
            {
                let roomName = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
                roomLabel.text = roomName
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryRoom.roomName = %@", roomName!)
            }
                // filtering by rooms AND filtering by owners
            else{
                let ownerName = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
                ownerLabel.text = ownerName
                let roomName = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
                roomLabel.text = roomName
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryOwner.ownerName = %@ AND inventoryRoom.roomName = %@", ownerName!, roomName!)
            }
            break
        }
        
        // fetch
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController roomsSelectionSegment", log: Log.coredata, type: .error)
        }
        
        collection.reloadData()
    }
    
    // owners segment selection
    @IBAction func ownersSelectionSegment(_ sender: Any) {
        switch ownersSegment.selectedSegmentIndex
        {
        case 0: // not filtering by owners
            // not filtering by room, not filtering by owners
            if(roomsSegment.selectedSegmentIndex == 0)
            {
                fetchedResultsController.fetchRequest.predicate = nil
                ownerLabel.text = Global.all
            }
                // filtering by rooms, not filtering by owners
            else{
                let roomName = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
                roomLabel.text = roomName
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryRoom.roomName = %@", roomName!)
            }
            break
            
        default: // filtering by owners
            // not filtering by rooms, filtering by owners
            if(roomsSegment.selectedSegmentIndex == 0)
            {
                let ownerName = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
                ownerLabel.text = ownerName
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryOwner.ownerName = %@", ownerName!)
            }
                // filtering by rooms AND filtering by owners
            else{
                let ownerName = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
                ownerLabel.text = ownerName
                let roomName = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
                roomLabel.text = roomName
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryOwner.ownerName = %@ AND inventoryRoom.roomName = %@", ownerName!, roomName!)
            }
            break
        }
        
        // fetch
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController ownersSelectionSegment", log: Log.coredata, type: .error)
        }
        
        collection.reloadData()
    }
    
    
    // enable or disable the filtering mechanics
    @IBAction func filterSwitchAction(_ sender: UISwitch) {
        // enable filter segments
        if sender.isOn
        {
            roomsSegment.isEnabled = true
            roomsSegment.isHidden = false
            ownersSegment.isEnabled = true
            ownersSegment.isHidden = false
            filterByRoomLabel.isHidden = false
            filterByOwnerLabel.isHidden = false
            
            roomLabel.isHidden = false
            ownerLabel.isHidden = false
            // set filters to ALL for rooms and owners, otherwise no data is selectable
            roomsSegment.selectedSegmentIndex = 0
            ownersSegment.selectedSegmentIndex = 0
            
            //let position = collection!.contentInset.top
            
            //collection.contentOffset.y -= 100
        }
            // disable filter segments
        else{
            roomsSegment.isEnabled = false
            roomsSegment.isHidden = true
            ownersSegment.isEnabled = false
            ownersSegment.isHidden = true
            filterByRoomLabel.isHidden = true
            filterByOwnerLabel.isHidden = true
            
            roomLabel.isHidden = true
            ownerLabel.isHidden = true
            
            // set filters to ALL for rooms and owners, otherwise no data is selectable
            roomsSegment.selectedSegmentIndex = 0
            ownersSegment.selectedSegmentIndex = 0
            
            fetchedResultsController.fetchRequest.predicate = nil
            // fetch
            do {
                try fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("Fetching error: \(error), \(error.userInfo)")
                os_log("InventoryCollectionViewController filterSwitchAction", log: Log.coredata, type: .error)
            }
            
            //let position = collection!.contentInset.top
            
            //collection.contentOffset.y += 100
            
            collection.reloadData()
        }
    }
    
    // MARK: - button actions
    
    @IBAction func addBarButton(_ sender: Any) {
        performSegue(withIdentifier: "addSegue", sender: self)
    }
    
    @IBAction func organizeBarButton(_ sender: Any) {
        deleteMode = true
        
        // left nav bar button change to cancel
        self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(InventoryCollectionViewController.cancelDelete)), animated: true)
        
        // right nav bar button to done
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InventoryCollectionViewController.doneDelete)), animated: true)
        
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
    }
    
    // no inv items deleted, deselect all and enable edit mode again
    @objc func cancelDelete(){
        // enable edit mode again
        deleteMode = false
        collection.allowsMultipleSelection = false
        
        // deselect all selected items
        //print("cancel delete: selected \(indexPathsForDeletion.count)")
        for idx in indexPathsForDeletion{
            deSelectCell(indexPath: idx)
        }
        
        indexPathsForDeletion.removeAll()
        selectedForDeleteInventory.removeAll()
        
        // FIXME: - deselect does not always work
        collection.reloadData()
    }
    
    // delete inventory objects which are selected
    @objc func doneDelete(){
        // enable edit mode again
        deleteMode = false
        collection.allowsMultipleSelection = false
        
        // delete all selected items
        for idx in indexPathsForDeletion{
            deSelectCell(indexPath: idx)
        }
        
        // delete from database
        for inv in selectedForDeleteInventory{
            //print(inv.inventoryName!)
            _ = CoreDataHandler.deleteInventory(inventory: inv)
        }
        
        indexPathsForDeletion.removeAll()
        selectedForDeleteInventory.removeAll()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("InventoryCollectionViewController doneDelete", log: Log.viewcontroller, type: .error)
        }
        
        collection.reloadData()
        //updateViewTitle()
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension InventoryCollectionViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //collection.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
        case .delete:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
        case .update:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
        case .move:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
        @unknown default:
            os_log("InventoryCollectionViewController controller: switch unknown default", log: Log.viewcontroller, type: .error)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        /*      if (self.shouldReloadCollectionView) {
         DispatchQueue.main.async {
         self.collection.reloadData();
         }
         } else {
         DispatchQueue.main.async {
         self.collection!.performBatchUpdates({ () -> Void in
         for operation: BlockOperation in self.blockOperations {
         operation.start()
         }
         }, completion: { (finished) -> Void in
         self.blockOperations.removeAll(keepingCapacity: false)
         })
         }
         } */
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        //let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
            
        case .delete:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
            
        case .update:
            collection.reloadData()
            updateNumberOfItemsLabel()
            break
            
        default:
            break
        }
    }
    
}

// implement peek and pop on 3D touch enabled devices like iPhone 8 onwards
extension InventoryCollectionViewController: UIViewControllerPreviewingDelegate {
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collection.indexPathForItem(at: location),
            let cell = collection.cellForItem(at: indexPath) else { return nil }
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "EditViewController") as? InventoryEditViewController else { return nil }
        
        let inv = fetchedResultsController.object(at: indexPath)
        
        detailVC.delegate = self
        detailVC.currentInventory = inv
        detailVC.preferredContentSize = CGSize(width: 0.0, height: 400)
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
    
    
    // pop will open new view controller
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: nil)
    }
}

// MARK: - InventoryEditViewControllerDelegate
extension InventoryCollectionViewController: InventoryEditViewControllerDelegate {
    func inventoryEditViewController(_ controller: InventoryEditViewController, didSelect action: UIPreviewAction, for previewedController: UIViewController, which inventory: Inventory) {
        
        switch action.title {
        case Global.cancel:
            //print("cancel")
            //navigationController?.show(previewedController, sender: nil)
            // do nothing
            break
            
        case Global.delete:
            // delete current inventory object
            //print(inventory.inventoryName!)
            _ = CoreDataHandler.deleteInventory(inventory: inventory)
            do {
                try fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("Fetching error: \(error), \(error.userInfo)")
                os_log("InventoryCollectionViewController didSelect", log: Log.viewcontroller, type: .error)
            }
            collection.reloadData()
            //navigationController?.show(previewedController, sender: nil)
            break
        
        case Global.duplicate:
            // duplicate current inventory object
            //print("duplicate")
            if let _ = duplicateIntentoryItem(inv: inventory){
                do {
                    try fetchedResultsController.performFetch()
                } catch let error as NSError {
                    print("Fetching error: \(error), \(error.userInfo)")
                    os_log("InventoryCollectionViewController didSelect", log: Log.viewcontroller, type: .error)
                }
                collection.reloadData()
            }
            break
            
        case Global.edit:
            navigationController?.show(previewedController, sender: nil)
            break
            
        case Global.printInvoice:
            if let print = inventory.invoice{
                //print("drucken")
                if UIPrintInteractionController.canPrint(print as Data) {
                    let printInfo = UIPrintInfo(dictionary: nil)
                    printInfo.jobName = inventory.invoiceFileName!
                    printInfo.outputType = .general
                    
                    let printController = UIPrintInteractionController.shared
                    printController.printInfo = printInfo
                    printController.showsNumberOfCopies = false
                    
                    printController.printingItem = print
                    
                    printController.present(animated: true, completionHandler: nil)
                }
                else{
                    let title = NSLocalizedString("No invoice", comment: "No invoice")
                    let message = NSLocalizedString("Item does not have an invoice to print, please attach an invoice to your item first", comment: "Item does not have an invoice to print")
                    let myActionSheet = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)
                    
                    let action = UIAlertAction(title: Global.cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
                        // do nothing when cancel
                    }
                    
                    myActionSheet.addAction(action)
                    addActionSheetForiPad(actionSheet: myActionSheet)
                    present(myActionSheet, animated: true, completion: nil)
                }
            }
            //navigationController?.show(previewedController, sender: nil)
            break
            
        default:
            break
        }
    }
    
    // duplicate inventory item in memory and in core data
    func duplicateIntentoryItem(inv: Inventory) -> Inventory?{
        let context = CoreDataHandler.getContext()
        let currentInventory = Inventory(context: context) // setup new inventory object
    
        // duplicate every attribute but UUID, has to be new, and inventory name gets "inv name (copy)"
        currentInventory.id = UUID()
        currentInventory.inventoryName = inv.inventoryName! + " (" + Global.copy + ")"
        currentInventory.dateOfPurchase = inv.dateOfPurchase
        currentInventory.price = inv.price
        currentInventory.remark = inv.remark
        currentInventory.serialNumber = inv.serialNumber
        currentInventory.warranty = inv.warranty
        currentInventory.inventoryOwner = inv.inventoryOwner
        currentInventory.inventoryRoom = inv.inventoryRoom
        currentInventory.inventoryBrand = inv.inventoryBrand
        currentInventory.inventoryCategory = inv.inventoryCategory
        currentInventory.timeStamp = Date() as NSDate?  // set new date since this is a copy but new
        currentInventory.image = inv.image
        currentInventory.imageFileName = inv.imageFileName
        currentInventory.invoice = inv.invoice
        currentInventory.invoiceFileName = inv.invoiceFileName
        
        _ = CoreDataHandler.saveInventory(inventory: currentInventory)
        
        return currentInventory
    }
}

// implement peek and pop on 3D touch enabled devices like iPhone 8 onwards
// if not available offer menu and long press gesture recognizer
extension InventoryCollectionViewController {
    func registerForPeekAndPopWithCollectionView(collectionView: UICollectionView) {
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: collectionView)
        }
        else{
            // long press gesture recignizer
            gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(InventoryCollectionViewController.longPressGesture))
            
            gestureRecognizer.minimumPressDuration = 0.3
            collection.addGestureRecognizer(gestureRecognizer)
            //print("gesture rec. registered")
        }
    }
}

// for handling long press gesture recognizer
extension InventoryCollectionViewController{
    
    // must return true otherwise no UIMenu appears
    override var canBecomeFirstResponder: Bool{
        //print("canbecomefirstresponder")
        return true
    }
    /*
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return true
    } */
    
    // gets called by long press gesture in case we do not have a 3D touch enabled device
    @objc func longPressGesture(sender: UILongPressGestureRecognizer){
        //print(sender.state)
        guard sender.state == .began
            //let senderView = sender.view
            else { return }
        
        //print("long press")
        //print(collection.isFirstResponder)
        // Make collection the window's first responder
        self.becomeFirstResponder()
        
        //print("after become")
        //print(collection.isFirstResponder)
        
        let menuController: UIMenuController = UIMenuController.shared
        
        // Set up the shared UIMenuController
        let duplicateMenuItem = UIMenuItem(title: Global.duplicate, action: #selector(duplicateTapped))
        let deleteMenuItem = UIMenuItem(title: Global.delete, action: #selector(deleteTapped))
        let cancelMenuItem = UIMenuItem(title: Global.cancel, action: #selector(cancelTapped))
        
        // Animate the menu onto view
        menuController.setMenuVisible(true, animated: true)
        menuController.arrowDirection = UIMenuController.ArrowDirection.default
        menuController.menuItems = [duplicateMenuItem, deleteMenuItem, cancelMenuItem]
        
        
        // Tell the menu controller the first responder's frame and its super view
        //menuController.setTargetRect(CGRect.zero, in: gestureRecognizer.view!)
        
        // Set the location of the menu in the view.
        let location = gestureRecognizer.location(in: collection)
        //print(location)
        let menuLocation = CGRect(x: location.x, y: location.y, width: 0, height: 0)   // FIXME 40 hard coded!!!
        menuController.setTargetRect(menuLocation, in: collection)
        
        let point = location
        let indexPath = collection.indexPathForItem(at: point)
        
        if indexPath != nil {
            let inv = fetchedResultsController.object(at: indexPath!)
            longPressInventoryItem = inv
        }
        
    }
    // duplicate menu item
    @objc func duplicateTapped() {
        if let inv = longPressInventoryItem{
            if let _ = duplicateIntentoryItem(inv: inv){
                do {
                    try fetchedResultsController.performFetch()
                } catch let error as NSError {
                    print("Fetching error: \(error), \(error.userInfo)")
                    os_log("InventoryCollectionViewController duplicateTapped", log: Log.viewcontroller, type: .error)
                }
                collection.reloadData()
            }
        }
        // ...
        // This would be a good place to optionally resign
        // responsiveView's first responder status if you need to
        self.view.resignFirstResponder()
        longPressInventoryItem = nil
    }
    
    // delete menu item
    @objc func deleteTapped() {
        if let inv = longPressInventoryItem{
            _ = CoreDataHandler.deleteInventory(inventory: inv)
            do {
                try fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("Fetching error: \(error), \(error.userInfo)")
                os_log("InventoryCollectionViewController deleteTapped", log: Log.viewcontroller, type: .error)
            }
            collection.reloadData()
        }
        // ...
        self.view.resignFirstResponder()
        longPressInventoryItem = nil
    }
    
    // cancel tapped
    @objc func cancelTapped() {
        self.view.resignFirstResponder()
        longPressInventoryItem = nil
    }
}
