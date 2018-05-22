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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var ownersSegment: UISegmentedControl!
    @IBOutlet weak var roomsSegment: UISegmentedControl!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var filterByOwnerLabel: UILabel!
    @IBOutlet weak var filterByRoomLabel: UILabel!
    
    var owner : [Owner] = []
    var room : [Room] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    func updateSearchResults(for searchController: UISearchController) {
        //
    }
    
    // fill a segment controll with values
    func replaceOwnersSegments(segments: Array<String>) {
        ownersSegment.removeAllSegments()
        for segment in segments {
            ownersSegment.insertSegment(withTitle: segment, at: ownersSegment.numberOfSegments, animated: false)
        }
    }
    
    // fill a segment controll with values
    func replaceRoomsSegments(segments: Array<String>) {
        roomsSegment.removeAllSegments()
        for segment in segments {
            roomsSegment.insertSegment(withTitle: segment, at: roomsSegment.numberOfSegments, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
        
        self.title = "Reports"
        filterButton.setTitle("Filter on", for: .normal)
        
        // Setup the Scope Bars
        owner = CoreDataHandler.fetchAllOwners()
        room = CoreDataHandler.fetchAllRooms()
        
        var listOwners :[String] = []
        var listRooms :[String] = []
        
        // FIXME tranlation needed
        listOwners.append("All")
        for inv in owner{
            listOwners.append((inv.ownerName)!)
        }
        
        replaceOwnersSegments(segments: listOwners)
        ownersSegment.selectedSegmentIndex = 0
        
        listRooms.append("All")
        for inv in room{
            listRooms.append((inv.roomName)!)
        }
        
        replaceRoomsSegments(segments: listRooms)
        roomsSegment.selectedSegmentIndex = 0
        
        searchBar.isHidden = true
        /*
        self made search bar
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search for Inventory Name"
        self.searchBar.scopeButtonTitles = list
        
        self.searchBar.showsScopeBar = true
        //self.searchBar.becomeFirstResponder()
        self.searchBar.sizeToFit()
        self.navigationItem.titleView = searchBar
        self.searchBar.sizeToFit()
        */
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // set collection view delegates
        collection.delegate = self
        collection.dataSource = self

        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Inventory"
        //searchController.searchBar.delegate = self
        searchController.delegate = self
        //navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        
        //searchController.searchBar.becomeFirstResponder()
        
        self.navigationItem.titleView = searchController.searchBar
        
        //searchController.searchBar.scopeButtonTitles = list
        searchController.searchBar.delegate = self
        searchController.searchBar.showsScopeBar = false
        
        definesPresentationContext = true
        navigationController?.isNavigationBarHidden = false
   
        self.navigationItem.hidesSearchBarWhenScrolling = false;
        
        let collectionViewLayout = collection.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)   // some distance to top/buttom/left/rigth
        collectionViewLayout?.invalidateLayout()
        
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    


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
        
        cell.priceLabel.text = String(inv.price) + "€"
        let imageData = inv.image! as Data
        let image = UIImage(data: imageData, scale:1.0)
        cell.myImage.image = image!
        
        
        return cell
    }

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
    
    // filter button enables or disables segment controls
    @IBAction func filterButtonAction(_ sender: Any) {
        let title = filterButton.title(for: .normal)
        
        // enable filter segments
        if title == "Filter off"
        {
            filterButton.setTitle("Filter on", for: .normal)
            roomsSegment.isEnabled = true
            roomsSegment.isHidden = false
            ownersSegment.isEnabled = true
            ownersSegment.isHidden = false
            filterByRoomLabel.isHidden = false
            filterByOwnerLabel.isHidden = false
            
            // set filters to ALL for rooms and owners, otherwise no data is selectable
            roomsSegment.selectedSegmentIndex = 0
            ownersSegment.selectedSegmentIndex = 0
        }
            // disable filter segments
        else{
            filterButton.setTitle("Filter off", for: .normal)
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
            
            collection.reloadData()
        }
        
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
            print("Insert Section: \(sectionIndex)")
            
            break
        case .delete:
            print("Delete Section: \(sectionIndex)")
            collection.reloadData()
            
            break
        case .update:
            print("Update Section: \(sectionIndex)")
            collection.reloadData()
            
            break
        default:
            break
        }
    }
}
