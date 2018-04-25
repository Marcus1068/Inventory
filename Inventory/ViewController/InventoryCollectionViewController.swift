//
//  CollectionViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os.log

private let reuseIdentifier = "collectionCell"
private var selectedInventoryItem = Inventory()


class InventoryCollectionViewController: UICollectionViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    var size = CGRect()
    var inventory : [Inventory] = []
    var owner : [Owner] = []
    var filteredInventory:[Inventory] = []   // in case of search filter by inventory name
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // let context = (UIApplication.shared.delegate as! AppDelegate)
    
    @IBOutlet var collection: UICollectionView!
    
    //var searchFooter = SearchFooter()
    
    override func viewDidLoad() {
        os_log("viewDidLoad in InventoryCollectionViewController", log: OSLog.default, type: .debug)
        
        super.viewDidLoad()
        
        // set collection view delegates
        collection.delegate = self
        collection.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Inventory Name"
        //searchController.searchBar.delegate = self
        searchController.delegate = self
        //navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        
        searchController.searchBar.becomeFirstResponder()
        
        self.navigationItem.titleView = searchController.searchBar
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        
        owner = CoreDataHandler.fetchAllOwners()
        
        // Setup the Scope Bar
        var list :[String] = []
        
        //var ownerList : Owner
        
        // FIXME tranlation needed
        list.append("All")
        for inv in owner{
            list.append((inv.ownerName)!)
        }
        
        
        searchController.searchBar.scopeButtonTitles = list
        searchController.searchBar.delegate = self
        searchController.searchBar.showsScopeBar = true
        
        searchController.searchBar.sizeToFit()
        
        
        let collectionViewLayout = collection.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)   // some distance to top/buttom/left/rigth
        collectionViewLayout?.invalidateLayout()
        
        // collection.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        os_log("viewDidAppear in InventoryCollectionViewController", log: OSLog.default, type: .debug)
        
        super.viewDidAppear(animated)
        
        inventory = CoreDataHandler.fetchInventory()
        
        collection.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Search Bar
    
    // filter for scope of owner (uses segment controll to display owners
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(searchBar.scopeButtonTitles![selectedScope])
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    // called by system when entered search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searchController.searchBar.showsScopeBar = true
        //collectionView.reloadData()
    }
    
    // called by system when entered search bar
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchController.searchBar.showsScopeBar = true
        collection.reloadData()
    }
    
    // self implemented method
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        filteredInventory = inventory.filter({( inv : Inventory) -> Bool in
            let doesOwnerMatch = (scope == "All") || (inv.inventoryOwner?.ownerName == scope)
            
            if searchBarIsEmpty() {
                return doesOwnerMatch
            } else {
                return doesOwnerMatch && inv.inventoryName!.lowercased().contains(searchText.lowercased())
            }
        })
        
        print(inventory.count)
        print(filteredInventory.count)
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    /*    override func numberOfSections(in collectionView: UICollectionView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return myInventory.count
     }
     */
    
    // used for footer usage displaying a label with number of elements
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionElementKindSectionFooter:
            let footerView = collection.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "footer",
                                                                         for: indexPath) as! SearchFooter
            
            if isFiltering(){
                footerView.searchResultLabel.textColor = UIColor.blue
                footerView.searchResultLabel.text = String(filteredInventory.count) + " Inventory objects found"
            }
            else{
                footerView.searchResultLabel.textColor = UIColor.black
                footerView.searchResultLabel.text = String(inventory.count) + " Inventory objects found"
            }
            
            return footerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    // number of collection items, depends on filtering on or off (searchbar used or not)
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isFiltering() {
            return filteredInventory.count
        }
        
        return inventory.count    //return number of rows
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        // FIXME will be called twice, delays performance massivlely with large data sets
        
        // Configure the cell
        
        let currentInventory : Inventory
        
        if isFiltering() {
            currentInventory = filteredInventory[indexPath.row]
        } else {
            currentInventory = inventory[indexPath.row]
        }
        
        cell.myLabel.text = currentInventory.inventoryName
        cell.ownerLabel.text = currentInventory.inventoryOwner?.ownerName
        cell.roomNameLabel.text = currentInventory.inventoryRoom?.roomName
        
        cell.priceLabel.text = String(currentInventory.price) + "€"
        let imageData = currentInventory.image! as Data
        let image = UIImage(data: imageData, scale:1.0)
        cell.myImage.image = image!
        
        // rounded corners for each cell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isFiltering() {
            selectedInventoryItem = filteredInventory[indexPath.row]
        } else {
            selectedInventoryItem = inventory[indexPath.row]
        }
        
        performSegue(withIdentifier: "editSegue", sender: self)
        
    }
    
    // prepare to transfer data to another view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destination =  segue.destination as! EditInventoryViewController
        
        if segue.identifier == "addSegue" {
            //os_log("addSegue selected", log: OSLog.default, type: .debug)
            
            destination.currentInventory = nil
        }
        
        if segue.identifier == "editSegue"  {
            //os_log("editSegue selected", log: OSLog.default, type: .debug)
            
            destination.currentInventory = selectedInventoryItem
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        os_log("addButton", log: OSLog.default, type: .debug)
        
        performSegue(withIdentifier: "addSegue", sender: self)
    }
    
    @IBAction func organizeButton(_ sender: Any) {
        // Enable editing.
        //self.editor.setEditing(true, animated: true)
    }
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
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
    
    
}
