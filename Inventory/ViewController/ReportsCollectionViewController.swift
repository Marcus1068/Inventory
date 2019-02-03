//
//  ReportsCollectionViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 25.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import CoreData
import os.log

private let reuseIdentifier = "collectionCellReports"
private var selectedInventoryItem = Inventory()

class ReportsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
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
    
    // store original nav bar buttons
    var leftNavBarButton : UIBarButtonItem? = nil
    var rightNavBarButton : UIBarButtonItem? = nil
    
    var owner : [Owner] = []
    var room : [Room] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    var dest = InventoryEditViewController()    // destination view controller
    var selectedForDeleteInventory:[Inventory] = []
    
    // store selected items when delete mode = true
    var indexPaths = [IndexPath]()
    
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
    
    // MARK - methods
    
    // fill a segment controll with values
    func replaceSegmentContents(segments: Array<String>, control: UISegmentedControl) {
        control.removeAllSegments()
        for segment in segments {
            control.insertSegment(withTitle: segment, at: control.numberOfSegments, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
        
        // set view title
        self.title = "Reports"
        
        // enable filtering
        filterSwitch.isOn = true
        filterSwitch.tintColor = themeColor
        filterSwitch.onTintColor = themeColor
        
        // Setup the Scope Bars
        owner = CoreDataHandler.fetchAllOwners()
        room = CoreDataHandler.fetchAllRooms()
        
        var listOwners :[String] = []
        var listRooms :[String] = []
        
        // FIXME tranlation needed
        let allOwners = NSLocalizedString("All", comment: "All")
        listOwners.append(allOwners)
        for inv in owner{
            listOwners.append((inv.ownerName)!)
        }
        
        replaceSegmentContents(segments: listOwners, control: ownersSegment)
        ownersSegment.selectedSegmentIndex = 0
        
        let allRooms = NSLocalizedString("All", comment: "All")
        listRooms.append(allRooms)
        for inv in room{
            listRooms.append((inv.roomName)!)
        }
        
        replaceSegmentContents(segments: listRooms, control: roomsSegment)
        roomsSegment.selectedSegmentIndex = 0
        
        
        // set collection view delegates
        collection.delegate = self
        collection.dataSource = self


        // Do any additional setup after loading the view.
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.delegate = self
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        self.navigationItem.titleView = searchController.searchBar
        searchController.searchBar.placeholder = "Search for Inventory"
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
    }

    // initialize the data for the view
    // fetch database etc.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
 
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        collection.reloadData()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ReportsCollectionViewCell
    
        // rounded corners for each cell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        // Configure the cell
    
        let inv = fetchedResultsController.object(at: indexPath)
        
        //let currentInventory : Inventory
        
        //currentInventory = inv
        
        cell.inventoryLabel.text = inv.inventoryName
        cell.ownerLabel.text = inv.inventoryOwner?.ownerName
        cell.romeNameLabel.text = inv.inventoryRoom?.roomName
        
        cell.priceLabel.text = String(inv.price) + "€"  //FIXME hardcoded currency
        
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
        
        return cell
    }
    
    // used for footer usage displaying a label with number of elements
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collection.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "reportHeader",
                                                                         for: indexPath) as! ReportsHeaderCollectionReusableView
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
                                                                         for: indexPath) as! ReportsFooterCollectionReusableView
            
            let sectionInfo = fetchedResultsController.sections?[indexPath.section]
            footerView.searchResultLabel.textColor = themeColor
            //footerView.searchResultLabel.text = String(sectionInfo!.numberOfObjects) + " Inventory item"
            
            if(sectionInfo!.numberOfObjects > 1){
                footerView.searchResultLabel.text = String(sectionInfo!.numberOfObjects) + NSLocalizedString(" Inventory items", comment: " Inventory items")
            }
            else{
                footerView.searchResultLabel.text = String(sectionInfo!.numberOfObjects) + NSLocalizedString(" Inventory item", comment: " Inventory item")
            }
            
            
            return footerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let inv = fetchedResultsController.object(at: indexPath)
        
        dest.currentInventory = inv
        selectedInventoryItem = inv
        
        //collectionView.cellForItem(at: indexPath as IndexPath)?.backgroundColor = UIColor.red
        if deleteMode{
            let cell = collection.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 5.0
            cell?.layer.borderColor = themeColor.cgColor
            
            indexPaths.append(indexPath)
            selectedForDeleteInventory.append(inv)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //collectionView.cellForItem(at: indexPath as IndexPath)?.backgroundColor = UIColor.clear
        //let inv = fetchedResultsController.object(at: indexPath)
        
        if deleteMode{
            let cell = collection.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 0.0
            cell?.layer.borderColor = UIColor.clear.cgColor
            
            if indexPaths.count > 0{
                indexPaths.removeLast()
                //selectedForDeleteInventory.remove(at: indexPath.item)
                selectedForDeleteInventory.removeLast()
            }
        }
    }
    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    // avoid automatic segue in case of delete mode
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if deleteMode  {
            // your code here, like badParameters  = false, e.t.c
            return false
        }
        return true
    }
    
    // prepare to transfer data to another view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
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
    // called by system when entered search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    
    // called when search bar cancel button was clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchedResultsController.fetchRequest.predicate = nil
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
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
                
            }
                // not filtering by rooms, filtering by owners
            else{
                let ownerName = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryOwner.ownerName = %@", ownerName!)
            }
            break
            
        default:    // filtering by rooms
            
            // filtering by rooms, not filtering by owners
            if(ownersSegment.selectedSegmentIndex == 0)
            {
                let roomName = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryRoom.roomName = %@", roomName!)
            }
                // filtering by rooms AND filtering by owners
            else{
                let ownerName = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
                let roomName = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
                
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryOwner.ownerName = %@ AND inventoryRoom.roomName = %@", ownerName!, roomName!)
            }
            break
        }
        
        // fetch
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
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
                
            }
                // filtering by rooms, not filtering by owners
            else{
                let roomName = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryRoom.roomName = %@", roomName!)
            }
            break
            
        default: // filtering by owners
            
            // not filtering by rooms, filtering by owners
            if(roomsSegment.selectedSegmentIndex == 0)
            {
                let ownerName = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryOwner.ownerName = %@", ownerName!)
            }
                // filtering by rooms AND filtering by owners
            else{
                let ownerName = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
                let roomName = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
                
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "inventoryOwner.ownerName = %@ AND inventoryRoom.roomName = %@", ownerName!, roomName!)
            }
            break
        }
        
        // fetch
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
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
            
            // set filters to ALL for rooms and owners, otherwise no data is selectable
            roomsSegment.selectedSegmentIndex = 0
            ownersSegment.selectedSegmentIndex = 0
            
            fetchedResultsController.fetchRequest.predicate = nil
            // fetch
            do {
                try fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("Fetching error: \(error), \(error.userInfo)")
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
        self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ReportsCollectionViewController.cancelDelete)), animated: true)
        
        // right nav bar button to done
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ReportsCollectionViewController.doneDelete)), animated: true)
        
    }
    
    // no inv items deleted, deselect all and enable edit mode again
    @objc func cancelDelete(){
        
        // enable edit mode again
        deleteMode = false
        
        collection.allowsMultipleSelection = false
        
        // deselect all selected items
        for idx in indexPaths{
            
            let cell = collection?.cellForItem(at: idx)
            cell?.layer.borderWidth = 0.0
            cell?.layer.borderColor = UIColor.clear.cgColor
        }
        
        indexPaths.removeAll()
        selectedForDeleteInventory.removeAll()
    }
    
    // delete inventory objects which are selected
    @objc func doneDelete(){
        
        deleteMode = false
        collection.allowsMultipleSelection = false
        
        // delete all selected items
        for idx in indexPaths{
            let cell = collection.cellForItem(at: idx)
            cell?.layer.borderWidth = 0.0
            cell?.layer.borderColor = UIColor.clear.cgColor
        }
        
        // delete from database
        for inv in selectedForDeleteInventory{
            print(inv.inventoryName!)
            _ = CoreDataHandler.deleteInventory(inventory: inv)
        }
        
        indexPaths.removeAll()
        selectedForDeleteInventory.removeAll()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        collection.reloadData()
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension ReportsCollectionViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //collection.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collection.reloadData()
            break
        case .delete:
            collection.reloadData()
            break
        case .update:
            collection.reloadData()
            break
        case .move:
            collection.reloadData()
            break
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
            //print("Insert Section: \(sectionIndex)")
            
            break
        case .delete:
            //print("Delete Section: \(sectionIndex)")
            collection.reloadData()
            
            break
        case .update:
            //print("Update Section: \(sectionIndex)")
            collection.reloadData()
            
            break
        default:
            break
        }
    }
    
}
