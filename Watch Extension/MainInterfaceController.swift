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
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Marcus Deuß on 23.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import os


class MessageRow: NSObject{
    
    @IBOutlet weak var label: WKInterfaceLabel!
    
}

class MainInterfaceController: WKInterfaceController, WCSessionDelegate {
  
    @IBOutlet weak var messagesTable: WKInterfaceTable!
    @IBOutlet weak var topPrice: WKInterfaceLabel!
    @IBOutlet weak var amountMoney: WKInterfaceLabel!
    @IBOutlet weak var topCategories: WKInterfaceLabel!
    
    var session : WCSession?
    
    // MARK: - Messages Table
    
    var messages = [String]() {
        didSet {
            OperationQueue.main.addOperation {
                //self.updateMessagesTable()
                self.tableRefresh()
                
            }
        }
    }
    
    // contains list of most expensive items
    var topPrices : [String : Int] = [ : ]
    var roomList : [String : Int] = [ : ]
    
    func processApplicationContext() {
    /*    if let iPhoneContext = session!.receivedApplicationContext as? [String : String] {
            
            if iPhoneContext["switchStatus"] == "Vincent" {
                self.messages.append("Vincent")
                // displayLabel.setText("Switch On")
            }
            
            if iPhoneContext["switchStatus"] == "Papa" {
                self.messages.append("Papa")
                // displayLabel.setText("Switch On")
            }
            
            
        } */
    }
    
    // MARK: - table functions
    
    func tableRefresh(){
        messagesTable.setNumberOfRows(messages.count, withRowType: "MessageRow")
        for index in 0 ..< messagesTable.numberOfRows {
            let row = messagesTable.rowController(at: index) as! MessageRow
            row.label.setText(messages[index])
        }
        
    }
    
    //table selection method
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        //print(rowIndex)
        
        //presentController(withName: "TopPrices", context: topPrices)
    }
    
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        os_log("MainInterfaceController: activationDidCompleteWith()", log: Log.viewcontroller, type: .info)
        //print("in watch app: \(activationState)")
    }
    
    // gets called when new iPhone message arrives
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        os_log("MainInterfaceController: didReceiveMessage()", log: Log.viewcontroller, type: .info)
        
        parseMessage(message: message)
        
        // vibrate when messages were received
        WKInterfaceDevice.current().play(.notification)
    }
    

    // app context
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        os_log("MainInterfaceController: didReceiveApplicationContext()", log: Log.viewcontroller, type: .info)
        
        //let msg = applicationContext["msg"]!
        //self.messages.append("AppContext \(msg)")
        
        DispatchQueue.main.async() {
            self.processApplicationContext()
        }
    }
    
    // userInfo
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        os_log("MainInterfaceController: didReceiveUserInfo()", log: Log.viewcontroller, type: .info)
        
        parseMessage(message: userInfo)
        
        // vibrate when messages were received
        WKInterfaceDevice.current().play(.notification)
    }
    
    // parse incoming messages
    func parseMessage(message: [String : Any]){
        // check for messages that come immediately
        
        for (key, value) in message{
            if key == DataKey.AmountMoney{
                let val = value as! Int
                amountMoney.setText(key + ": " + String(val))
            }
            
            if key == DataKey.TopPrice{
                let val = value as! Int
                topPrice.setText(key + ": " + String(val))
            }
            
            if key == DataKey.TopCategories{
                let val = value as! Int
                topCategories.setText(key + ": " + String(val))
            }
            
            // deal with a list of strings sent at once
            // will have prefix which must be removed for further work
            if key.contains(DataKey.MostExpensiveList) {
                // split this: "DataKey.MostExpensiveListInventoryName" : "price" into this:
                // "InventoryName" : number as a dict
                let parsed = key.replacingOccurrences(of: DataKey.MostExpensiveList, with: "")
                let myValue = value as! String
                topPrices[parsed] = Int(myValue)
                
                let val = value as! String
                self.messages.append(parsed + ": " + val)
            }
            
            if key.contains(DataKey.TopRooms) {
                // split this: "DataKey.MostExpensiveListInventoryName" : "price" into this:
                // "InventoryName" : number as a dict
                let parsed = key.replacingOccurrences(of: DataKey.TopRooms, with: "")
                let myValue = value as! Int
                roomList[parsed] = myValue
                
                //let val = value as! Int
                self.messages.append(parsed + ": " + String(myValue))
            }
        }
    }
    
    //let stat = Statistics.shared
    
    //var topList : [Inventory] = []
    
    // MARK: - callbacks
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
     
        messages.append("ready")
    }
    
    // FIXME: updateapplicationContext to share data
    
    override func willActivate() {
        os_log("MainInterfaceController: willActivate()", log: Log.viewcontroller, type: .info)
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // init the session
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        tableRefresh()
        //refreshPickerItems()
    }
    
    override func didDeactivate() {
        os_log("MainInterfaceController: didDeactivate()", log: Log.viewcontroller, type: .info)
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // MARK: - actions
    
 /*   @IBAction func pickerDidChange(_ value: Int) {
        print(value)
        //let text = titles.index(value, offsetBy: 0)
        myLabel.setText(titles[value])
    } */

    @IBAction func roomListAction() {
        //presentController(withName: "RoomList", context: roomList)
    }
    
    @IBAction func topPricesAction() {
        presentController(withName: "TopPrices", context: topPrices)
    }
    
    @IBAction func requestInfo() {
        os_log("MainInterfaceController: requestInfo()", log: Log.viewcontroller, type: .info)
        session?.sendMessage(["request" : "date"],
                             replyHandler: { (response) in
                                self.messages.append("Reply: \(response)")
        },
                             errorHandler: { (error) in
                                print("Error sending message: %@", error)
        }
        )
    }
    
    
}
