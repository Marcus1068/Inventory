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

class InterfaceController: WKInterfaceController, WCSessionDelegate {
  
    @IBOutlet weak var messagesTable: WKInterfaceTable!
    
    var session : WCSession?
    
    let titles = [
        "Most expensive","Most by room",
        "Most by category","success",
        "failure","retry"
    ]
    
    // MARK: - Messages Table
    
    var messages = [String]() {
        didSet {
            OperationQueue.main.addOperation {
                self.updateMessagesTable()
            }
        }
    }
    
    func processApplicationContext() {
        if let iPhoneContext = session!.receivedApplicationContext as? [String : String] {
            
            
            if iPhoneContext["switchStatus"] == "Vincent" {
                print("Vincent")
                // displayLabel.setText("Switch On")
            }
            
            if iPhoneContext["switchStatus"] == "Emily" {
                print("Emily")
                // displayLabel.setText("Switch On")
            }
            
            if iPhoneContext["Name"] == "Hans" {
                print("Hans")
                print(iPhoneContext["Name"] as Any)
                // displayLabel.setText("Switch On")
            }
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        os_log("InterfaceController: activationDidCompleteWith()", log: Log.viewcontroller, type: .info)
        print("in watch app: \(activationState)")
    }
    
    // gets called when new iPhone message arrives
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        os_log("InterfaceController: didReceiveMessage()", log: Log.viewcontroller, type: .info)
        
        let msg = message["msg"]!
        self.messages.append("Message \(msg)")
        // vibrate when message received
        WKInterfaceDevice.current().play(.notification)
    }
    
    // app context
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        os_log("InterfaceController: didReceiveApplicationContext()", log: Log.viewcontroller, type: .info)
        
        //let msg = applicationContext["msg"]!
        //self.messages.append("AppContext \(msg)")
        
        DispatchQueue.main.async() {
            self.processApplicationContext()
        }
    }
    
    // userInfo
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        os_log("InterfaceController: didReceiveUserInfo()", log: Log.viewcontroller, type: .info)
        
        let msg = userInfo["msg"]!
        self.messages.append("UserInfo \(msg)")
    }
    
    func updateMessagesTable() {
        messagesTable.setNumberOfRows(messages.count, withRowType: "MessageRow")
        for (i, msg) in messages.enumerated() {
            let row = messagesTable.rowController(at: i) as! MessageRow
            row.label.setText(msg)
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
        os_log("InterfaceController: willActivate()", log: Log.viewcontroller, type: .info)
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // init the session
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        //refreshPickerItems()
    }
    
    override func didDeactivate() {
        os_log("InterfaceController: didDeactivate()", log: Log.viewcontroller, type: .info)
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
        os_log("InterfaceController: requestInfo()", log: Log.viewcontroller, type: .info)
        session?.sendMessage(["request" : "date"],
                             replyHandler: { (response) in
                                self.messages.append("Reply: \(response)")
        },
                             errorHandler: { (error) in
                                print("Error sending message: %@", error)
        }
        )
    }
    
    // MARK: - helper methods
    
    func refreshPickerItems(){
        var pickerItems:[WKPickerItem] = []
        
        for item in titles{
            let pickerItem = WKPickerItem()
            pickerItem.title = item
            pickerItems += [pickerItem]
        }
        
        //pickerOutlet.setItems(pickerItems)
    }
}
