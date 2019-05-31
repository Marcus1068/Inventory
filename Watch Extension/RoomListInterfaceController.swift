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
//  RoomListInterfaceController.swift
//  Watch Extension
//
//  Created by Marcus Deuß on 27.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import WatchKit
import Foundation


class RoomListInterfaceController: WKInterfaceController {

    // contains list of rooms with item occurance per room
    var roomList : [String : Int] = [ : ]{
        didSet{
            OperationQueue.main.addOperation {
                self.tableRefresh()
            }
        }
    }
    
    @IBOutlet weak var tableForRooms: WKInterfaceTable!
    
    // MARK: - table functions
    
    func tableRefresh(){
        tableForRooms.setNumberOfRows(roomList.count, withRowType: "RoomsRowController")
        var index : Int = 0
        for (idx, val) in roomList.sorted(by: {$0.value > $1.value}){
            let row = tableForRooms.rowController(at: index) as! RoomsRowController
            index += 1
            row.roomNameLabel.setText(String(index) + ": " + idx)
            row.countLabel.setText(String(val))
        }
    }
    
    // MARK: - table functions
    //table selection method
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        //presentController(withName: "TopPrices", context: top)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        if let myRoomList = context as? [String : Int] {
            self.roomList = myRoomList
        }
        
        self.setTitle(Local.mostUsedRooms)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        tableRefresh()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
