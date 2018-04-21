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
    
    var inventory : [Inventory] = []
    var owner : [Owner] = []
    var filteredInventory:[Inventory] = []   // in case of search filter by inventory name
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let context = (UIApplication.shared.delegate as! AppDelegate)
    
    @IBOutlet var collection: UICollectionView!
    
    //var searchFooter = SearchFooter()
    
    override func viewDidLoad() {
        os_log("viewDidLoad in InventoryCollectionViewController", log: OSLog.default, type: .debug)
        
        super.viewDidLoad()
        
        //selectedItem = Inventory(context: context)
        
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
        //searchController.dimsBackgroundDuringPresentation = true
        
        searchController.searchBar.becomeFirstResponder()
        
        self.navigationItem.titleView = searchController.searchBar
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        inventory = context.fetchInventory()
        owner = context.fetchAllOwners()
        
        // Setup the Scope Bar
        var list :[String] = []
        
        //var ownerList : Owner
        
        // FIXME tranlation needed
        list.append("All")
        for inv in owner{
            list.append((inv.ownerName)!)
        }
        
        
        searchController.searchBar.scopeButtonTitles = list
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        searchController.searchBar.showsScopeBar = true
        
        
        //SearchFooter.init(frame: <#T##CGRect#>)
        
        //searchController.searchBar.
        
        //        // generate sample data if none available
        //        if (myInventory.count == 0){
        //            context.generateSampleData()
        //        }
        //
        collection.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        os_log("viewDidAppear in InventoryCollectionViewController", log: OSLog.default, type: .debug)
        
        super.viewDidAppear(animated)
        
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
    /*
     func filterContentForSearchText(_ searchText: String, scope: String = "All") {
     filteredInventory = inventory.filter({( inv : Inventory) -> Bool in
     return inv.inventoryName!.lowercased().contains(searchText.lowercased())
     })
     
     collection.reloadData()
     }
     */
    
    // called by system when entered search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searchController.searchBar.showsScopeBar = true
        //collectionView.reloadData()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        filteredInventory = inventory.filter({( inv : Inventory) -> Bool in
            let doesOwnerMatch = (scope == "All") || (inv.inventoryOwner?.ownerName == scope)
            
            if searchBarIsEmpty() {
                return doesOwnerMatch
            } else {
                return doesOwnerMatch && inv.inventoryName!.lowercased().contains(searchText.lowercased())
            }
        })
        
        collection.reloadData()
    }
    
    // Returns true if the search text is empty or nil
    func searchBarIsEmpty() -> Bool {
        
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    /*
     // determine if filtering is needed
     func isFiltering() -> Bool {
     return searchController.isActive && !searchBarIsEmpty()
     }
     */
    // called by system
    func updateSearchResults(for searchController: UISearchController)
    {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionElementKindSectionFooter:
            let footerView = collection.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "footer",
                                                                         for: indexPath) as! SearchFooter
            
            //footerView.backgroundColor = UIColor.green
            //footerView.searchResultLabel.text = "blablö"
            
            return footerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isFiltering() {
            
            //searchFooter.setIsFilteringToShow(filteredItemCount: filteredInventory.count, of: inventory.count)
            return filteredInventory.count
        }
        
        //searchFooter.setNotFiltering()
        return inventory.count    //return number of rows
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        // Configure the cell
        
        let currentInventory : Inventory
        
        if isFiltering() {
            currentInventory = filteredInventory[indexPath.row]
        } else {
            currentInventory = inventory[indexPath.row]
        }
        
        cell.myLabel.text = currentInventory.inventoryName
        cell.ownerLabel.text = currentInventory.inventoryOwner?.ownerName
        cell.priceLabel.text = String(currentInventory.price) + "€"
        let imageData = currentInventory.image! as Data
        let image = UIImage(data: imageData, scale:1.0)
        cell.myImage.image = image!
        
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
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}
