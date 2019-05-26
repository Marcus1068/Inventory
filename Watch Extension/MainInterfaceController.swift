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

class TopPrice :NSObject{
    var prices : [String : Int] = [ : ]
    var item : [String] = []
    var value : [String] = []
    
    override init(){
        super.init()
        
        prices = [ : ]
        item = []
        value = []
    }
    
}

class MessageRow: NSObject{
    
    @IBOutlet weak var label: WKInterfaceLabel!
    
}

class MainInterfaceController: WKInterfaceController, WCSessionDelegate {
  
    @IBOutlet weak var messagesTable: WKInterfaceTable!
    @IBOutlet weak var topPrice: WKInterfaceLabel!
    @IBOutlet weak var amountMoney: WKInterfaceLabel!
    @IBOutlet weak var topCategories: WKInterfaceLabel!
    
    var session : WCSession?

    var top = TopPrice()
    
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
    
    func tableRefresh(){
        messagesTable.setNumberOfRows(messages.count, withRowType: "MessageRow")
        for index in 0 ..< messagesTable.numberOfRows {
            let row = messagesTable.rowController(at: index) as! MessageRow
            row.label.setText(messages[index])
        }
        
    }
    
    // MARK: - table functions
    //table selection method
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        print(rowIndex)
        //let flight = flights[rowIndex]
        top.prices = topPrices
        presentController(withName: "TopPrices", context: top)
    }
    
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        os_log("MainInterfaceController: activationDidCompleteWith()", log: Log.viewcontroller, type: .info)
        //print("in watch app: \(activationState)")
    }
    
    // gets called when new iPhone message arrives
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        os_log("MainInterfaceController: didReceiveMessage()", log: Log.viewcontroller, type: .info)
        
        // check for message that come immediately
        
        for (key, value) in message{
            if key == DataKey.AmountMoney{
                let val = value as! Int
                amountMoney.setText(key + ": " + String(val))
            }
            
            if key == DataKey.TopPrice{
                let val = value as! Int
                topPrice.setText(key + ": " + String(val))
            }
            
            if key == DataKey.Topcategories{
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

                top.item.append(parsed)
                top.value.append(String(myValue))
                
                let val = value as! String
                self.messages.append(parsed + ": " + val)
            }
        }
        
        // sorted dict of most expensive items
        for (idx, val) in topPrices.sorted(by: {$0.value > $1.value}){
            print(idx, val)
        }
        
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
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        os_log("MainInterfaceController: didReceiveUserInfo()", log: Log.viewcontroller, type: .info)
        
        let msg = userInfo["msg"]!
        self.messages.append("UserInfo \(msg)")
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
