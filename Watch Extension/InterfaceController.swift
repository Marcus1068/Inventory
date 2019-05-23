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

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet weak var pickerOutlet: WKInterfacePicker!
    @IBOutlet weak var myLabel: WKInterfaceLabel!
    
    // MARK: - Messages Table
    
    var messages = [String]() {
        didSet {
            OperationQueue.main.addOperation {
                self.updateMessagesTable()
            }
        }
    }
    
    func updateMessagesTable() {
        /*messagesTable.setNumberOfRows(messages.count, withRowType: "MessageRow")
        for (i, msg) in messages.enumerated() {
            let row = messagesTable.rowController(at: i) as! MessageRow
            row.label.setText(msg) */
    }
    
    var session : WCSession?
    
    let titles = [
        "Most expensive","Most by room",
        "Most by category","success",
        "failure","retry"
    ]
    
    //let stat = Statistics.shared
    
    //var topList : [Inventory] = []
    
    // MARK: - callbacks
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
     
        messages.append("ready")
    }
    
    // FIXME: updateapplicationContext to share data
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // init the session
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        refreshPickerItems()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // MARK: - actions
    
    @IBAction func pickerDidChange(_ value: Int) {
        print(value)
        //let text = titles.index(value, offsetBy: 0)
        myLabel.setText(titles[value])
    }
    
    @IBAction func buttonAction() {
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
        
        pickerOutlet.setItems(pickerItems)
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //os_log("%@", "activationDidCompleteWith activationState:\(activationState) error:\(error)")
        print(activationState)
    }
}
