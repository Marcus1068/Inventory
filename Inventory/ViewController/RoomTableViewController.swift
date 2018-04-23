//
//  RoomTableViewController.swift
//  Inventory
//
//  Created by Marcus Deuß on 18.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit
import os.log

class RoomTableViewController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate)
    var rooms : [Room] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // this will avoid displaying empty rows in the table
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // necessary for accessing table cells
        //tableView.dataSource = self
        //tableView.delegate = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        // get the data from Core Data
        rooms = context.fetchAllRooms()
        
        // reload the table
        tableView.reloadData()
        
        //select first row of table
        if(rooms.count > 0)
        {
            let idx = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: idx, animated: true, scrollPosition: .top)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rooms.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath)

        // Configure the cell...
        
        let room = rooms[indexPath.row]
        cell.textLabel?.text = room.roomName
        // cell.detailTextLabel?.text = 

        return cell
    }
    
    // little blue info button as "detail" view (must be set in xcode at cell level
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        os_log("accessoryButtonTappedForRowWith", log: OSLog.default, type: .debug)
        //print(indexPath.row)
        let idx = IndexPath(row: indexPath.row, section: 0)
        tableView.selectRow(at: idx, animated: true, scrollPosition: .middle)
        performSegue(withIdentifier: "editSegueRoom", sender: self)
    }
    
    // prepare to transfer data to another view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        os_log("prepare for segue", log: OSLog.default, type: .debug)
        
        let destination =  segue.destination as! RoomEditViewController
        
        if segue.identifier == "editSegueRoom"  {
            // Pass the selected object to the new view controller.
            if let indexPath = self.tableView.indexPathForSelectedRow { // FIXME
                let selectedRoom = rooms[indexPath.row]
                destination.currentRoom = selectedRoom
            }
        }
        
        if segue.identifier == "addSegueRoom"  {
            destination.currentRoom = nil
        }
        
    }
    
    // delete rows via UI with swipe gesture
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete{
            let room = rooms[indexPath.row]
            //self.tableView.deleteRows(at: [indexPath], with: .automatic)
            //room.removeFromRoomInventory(Inventory)
            context.delete(room)
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            rooms = (UIApplication.shared.delegate as! AppDelegate).fetchAllRooms()
            
            tableView.reloadData()
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
