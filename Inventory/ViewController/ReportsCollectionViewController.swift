//
//  ReportsCollectionViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 25.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os.log

private let reuseIdentifier = "collectionCellReports"

class ReportsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    
   
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var inventory : [Inventory] = []
    var owner : [Owner] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    func updateSearchResults(for searchController: UISearchController) {
        //
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
        
        self.title = "Reports"

        // Setup the Scope Bar
        owner = CoreDataHandler.fetchAllOwners()
        var list :[String] = []
        
        //var ownerList : Owner
        
        // FIXME tranlation needed
        list.append("All")
        for inv in owner{
            list.append((inv.ownerName)!)
        }
        
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
        
        searchController.searchBar.scopeButtonTitles = list
        searchController.searchBar.delegate = self
        searchController.searchBar.showsScopeBar = true
        
        definesPresentationContext = true
        navigationController?.isNavigationBarHidden = false
   
        self.navigationItem.hidesSearchBarWhenScrolling = false;
        
        let collectionViewLayout = collection.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)   // some distance to top/buttom/left/rigth
        collectionViewLayout?.invalidateLayout()
        
        
        
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return inventory.count    //return number of rows
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ReportsCollectionViewCell
    
        // Configure the cell
    
        let currentInventory : Inventory
        
        currentInventory = inventory[indexPath.row]
        
        cell.inventoryLabel.text = currentInventory.inventoryName
        cell.ownerLabel.text = currentInventory.inventoryOwner?.ownerName
        cell.romeNameLabel.text = currentInventory.inventoryRoom?.roomName
        
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
