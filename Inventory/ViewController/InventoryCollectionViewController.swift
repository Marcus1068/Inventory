//
//  CollectionViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import CoreData
import os.log

private let reuseIdentifier = "collectionCell"
private var selectedInventoryItem = Inventory()

class InventoryCollectionViewController: UICollectionViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var organizeButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!

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
    
//    var shouldReloadCollectionView = false
//    var blockOperations: [BlockOperation] = []

    //var deleteMode = false
    var dest = InventoryEditViewController()    // destination view controller
    var size = CGRect()
//    var inventory : [Inventory] = []
    var owner : [Owner] = []
    var filteredInventory:[Inventory] = []   // in case of search filter by inventory name
    
    var selectedForDeleteInventory:[Inventory] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet var collection: UICollectionView!
    
    // store original nav bar buttons
    var leftNavBarButton : UIBarButtonItem? = nil
    var rightNavBarButton : UIBarButtonItem? = nil
    
    // store selected items when delete mode = true
    var indexPaths = [IndexPath]()
    
    // enter delete mode
    var deleteMode: Bool = false {
        didSet {
            collectionView?.allowsMultipleSelection = deleteMode
            
            guard deleteMode else {
                // restore buttons to original setup
                navigationItem.setLeftBarButtonItems([leftNavBarButton!], animated: true)
                navigationItem.setRightBarButtonItems([rightNavBarButton!], animated: true)
                
                return
            }
        }
    }
    
    //var searchFooter = SearchFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // new in ios11: large navbar titles
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // set collection view delegates
        collection.delegate = self
        collection.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder =  NSLocalizedString("Search for Inventory Name", comment: "Search for Inventory Name")
        //searchController.searchBar.delegate = self
        searchController.delegate = self
        //navigationItem.searchController = searchController
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        
        //searchController.searchBar.becomeFirstResponder()
        
        self.navigationItem.titleView = searchController.searchBar
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        
        owner = CoreDataHandler.fetchAllOwners()
        
        // Setup the Scope Bar
        var list :[String] = []
        
        //var ownerList : Owner
        
        let msg = NSLocalizedString("All", comment: "All")
        list.append(msg)
        
        for inv in owner{
            list.append((inv.ownerName)!)
        }
        
        searchController.searchBar.scopeButtonTitles = list
        searchController.searchBar.delegate = self
        searchController.searchBar.showsScopeBar = true
        
        searchController.searchBar.sizeToFit()
        
        let collectionViewLayout = collection.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)   // some distance to top/buttom/left/rigth
        collectionViewLayout?.invalidateLayout()
        
        leftNavBarButton = self.navigationItem.leftBarButtonItems?.first
        rightNavBarButton = self.navigationItem.rightBarButtonItems?.first
        
    }
    
    // initialize the data for the view
    // fetch database etc.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //inventory = CoreDataHandler.fetchInventory()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        collection.reloadData()
    }
    
    
    //MARK: Search Bar
    
    // helper to get database refresh and reload collection as well
    func fetchAndReloadCollection(){
        fetchedResultsController.fetchRequest.predicate = nil
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        collection.reloadData()
    }
    
    // filter for scope of owner (uses segment control to display owners)
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBarIsEmpty()){
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
        
        //print("Taste")
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
            searchBar.text = "AAAA"     // FIXME what does that mean?
        }
    }
    
    // self implemented method
    func filterContentForSearchText(_ searchText: String, scope: String = NSLocalizedString("All", comment: "All")) {
        
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
        // is the selected scope button clicked? true or falase
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        
        if searchBarScopeIsFiltering{
            return true
        }
        
        // true if search controller is active AND (search bar is not empty OR scope filter active)
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    // called by system
    func updateSearchResults(for searchController: UISearchController)
    {
        if(!searchBarIsEmpty()){
            let searchBar = searchController.searchBar
            let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
            filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    /*    override func numberOfSections(in collectionView: UICollectionView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return myInventory.count
     }
     */
    
    // used for footer usage displaying a label with number of elements
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collection.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "header",
                                                                         for: indexPath) as! InventoryHeaderCollectionReusableView
            let sectionInfo = fetchedResultsController.sections?[indexPath.section]
            headerView.roomName.text = sectionInfo?.name
            let room = CoreDataHandler.fetchRoomIcon(roomName: (sectionInfo?.name)!)
            let imageData = room!.roomImage! as Data
            let image = UIImage(data: imageData, scale:1.0)
            headerView.roomIcon.image = image
            
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collection.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "footer",
                                                                         for: indexPath) as! InventoryFooterCollectionReusableView
            
            let sectionInfo = fetchedResultsController.sections?[indexPath.section]
            footerView.searchResultLabel.textColor = themeColor
            //footerView.searchResultLabel.text = String(sectionInfo!.numberOfObjects) + " Inventory item"
            
            if(sectionInfo!.numberOfObjects > 1){
                footerView.searchResultLabel.text = String(sectionInfo!.numberOfObjects) + NSLocalizedString(" Inventory items", comment: " Inventory items")
            }
            else{
                footerView.searchResultLabel.text = String(sectionInfo!.numberOfObjects) + NSLocalizedString(" Inventory item", comment: " Inventory item")
            }
            
  /*          if isFiltering(){
                footerView.searchResultLabel.textColor = UIColor.blue
                footerView.searchResultLabel.text = String(filteredInventory.count) + " Inventory objects found"
            }
            else{
                footerView.searchResultLabel.textColor = UIColor.black
                footerView.searchResultLabel.text = String(inventory.count) + " Inventory objects found"
            }
            */
            return footerView
        
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    // number of sections, section devider is room name
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        
        return sections.count
    }
    
    // number of collection items, depends on filtering on or off (searchbar used or not)
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        // rounded corners for each cell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        // FIXME will be called twice, delays performance massivlely with large data sets
        
        let inv = fetchedResultsController.object(at: indexPath)
        cell.myLabel.text = inv.inventoryName
        cell.ownerLabel.text = inv.inventoryOwner?.ownerName
        cell.categoryNameLabel.text = inv.inventoryCategory?.categoryName
        cell.priceLabel.text = String(inv.price) + "€" // FIXME hardcoded
        cell.warrantyMonthsLabel.text = String(inv.warranty)
        cell.warrantyLabel.text = NSLocalizedString("Warranty:", comment: "Warranty:")
        
        var image: UIImage
        
        if inv.image != nil{
            let imageData = inv.image! as Data
            image = UIImage(data: imageData, scale: 1.0)!
        }
        else{
            // to image, set default image
            let defaultImage = #imageLiteral(resourceName: "Room Icon")
            image = defaultImage 
        }
        cell.myImage.image = image
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
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
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
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
    
    
    // add a new inventory element by simply calling perform segue
    @IBAction func addButton(_ sender: Any) {
        
        performSegue(withIdentifier: "addSegue", sender: self)
    }
    
    // enables delete mode, switches left and right nav bar buttons
    @IBAction func organizeButton(_ sender: Any) {
        
        deleteMode = true
        
        // left nav bar button change to cancel
        self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(InventoryCollectionViewController.cancelDelete)), animated: true)
        
        // right nav bar button to done
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InventoryCollectionViewController.doneDelete)), animated: true)
        
    }
    
    // no inv items deleted, deselect all and enable edit mode again
    @objc func cancelDelete(){
        
        // enable edit mode again
        deleteMode = false
        
        collection.allowsMultipleSelection = false
        
        // deselect all selected items
        for idx in indexPaths{
            
            let cell = collectionView?.cellForItem(at: idx)
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
    
 /*
    @nonobjc private let capital = #selector(CollectionViewCell.capital)
    @nonobjc private let copy = #selector(UIResponderStandardEditActions.copy)
    
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        os_log("shouldShowMenuForItemAt", log: OSLog.default, type: .debug)
        
        let mi = UIMenuItem(title:"Capital", action:capital)
        UIMenuController.shared.menuItems = [mi]
        
        return true
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        os_log("canPerformAction", log: OSLog.default, type: .debug)
        return (action == copy) || (action == capital)
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        os_log("performAction", log: OSLog.default, type: .debug)
     
        if action == copy {
            print ("copy")
        }
        else if action == capital {
            print ("capital")
        }
     }
   */
/*    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    } */
}

// MARK: - NSFetchedResultsControllerDelegate
extension InventoryCollectionViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //collection.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            //print("Insert Object: \(String(describing: newIndexPath))")
            
            collection.reloadData()
 /*           if (collection?.numberOfSections)! > 0 {
                
                if collection?.numberOfItems( inSection: newIndexPath!.section ) == 0 {
                    self.shouldReloadCollectionView = true
                } else {
                    blockOperations.append(
                        BlockOperation(block: { [weak self] in
                            if let this = self {
                                DispatchQueue.main.async {
                                    this.collectionView!.insertItems(at: [newIndexPath!])
                                }
                            }
                        })
                    )
                }
                
            } else {
                self.shouldReloadCollectionView = true
            } */
            break
        case .delete:
            collection.reloadData()
            /*
            print("Delete Object: \(String(describing: indexPath))")
            if collection?.numberOfItems( inSection: indexPath!.section ) == 1 {
                self.shouldReloadCollectionView = true
            } else {
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            DispatchQueue.main.async {
                                this.collectionView!.deleteItems(at: [indexPath!])
                            }
                        }
                    })
                )
            } */
            break
        case .update:
            collection.reloadData()
        /*    print("Update Object: \(String(describing: indexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            
                            this.collection!.reloadItems(at: [indexPath!])
                        }
                    }
                })
            ) */
            break
        case .move:
            //print("Move Object: \(String(describing: indexPath))")
            collection.reloadData()
          /*
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collection!.moveItem(at: indexPath!, to: newIndexPath!)
                        }
                    }
                })
            ) */
            break
        @unknown default:
            os_log("controller: switch unknown default", log: OSLog.default, type: .debug)
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
 /*           blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collection!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            ) */
            break
        case .delete:
            //print("Delete Section: \(sectionIndex)")
            collection.reloadData()
            /*
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collection!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            ) */
            break
        case .update:
            //print("Update Section: \(sectionIndex)")
            collection.reloadData()
            /*
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collection!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            ) */
            break
        default: break
        }
    }
}
