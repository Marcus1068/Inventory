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

class InventoryCollectionViewController: UICollectionViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate)
    var myInventory : [Inventory] = []
    
    @IBOutlet var collection: UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        myInventory = context.fetchInventory()
        
        // generate sample data if none available
        if (myInventory.count == 0){
            context.generateSampleData()
        }
        
        context.showSampleData() // FIXME comment in release
        
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

/*    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return myInventory.count
    }
*/

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return myInventory.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
    
        // Configure the cell
        
        cell.myLabel.text = myInventory[indexPath.item].inventoryName
        let imageData = myInventory[indexPath.row].image! as Data
        let image = UIImage(data: imageData, scale:1.0)
        cell.myImage.image = image!
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        performSegue(withIdentifier: "editSegue", sender: self)
        
    }
    
    // prepare to transfer data to another view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        os_log("prepare for segue", log: OSLog.default, type: .debug)
 
        let destination =  segue.destination as! EditInventoryViewController
        
        if segue.identifier == "addSegue" {
            let a = ""
            // Pass the selected object to the new view controller.
     //       if let indexPath = collection.item {
      //          let _ = myInventory[indexPath.row]
                //destination.currentInventory = nil
    //        }
            os_log("addSegue selected", log: OSLog.default, type: .debug)
    
            
        }
        
        if segue.identifier == "editSegue"  {
    
    
            // Pass the selected object to the new view controller.
      //      if let indexPath = self.collectionView.indexPathForSelectedRow { // FIXME
       //         let selectedInventory = myInventory[indexPath.row]
                //destination.currentInventory = selectedVokabel
        //    }
            os_log("editSegue selected", log: OSLog.default, type: .debug)
        }
   
    }
    
    @IBAction func addButton(_ sender: Any) {
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
