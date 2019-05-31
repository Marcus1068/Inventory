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
//  ConnectivityHandler.swift
//  Inventory
//
//  Created by Marcus Deuß on 23.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import Foundation
import WatchConnectivity
import os


/// for handling communication with watch app
/// in AppDelegate:
/// var connectivityHandler : ConnectivityHandler?
/// func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

/// if WCSession.isSupported() {
///    self.connectivityHandler = ConnectivityHandler()
/// } else {
///     NSLog("WCSession not supported (f.e. on iPad).")
/// }

/// Override point for customization after application launch.
/// return true
/// }

class WatchSessionManager : NSObject, WCSessionDelegate {
    
    static let sharedManager = WatchSessionManager()
    
    private let session : WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    private var items = [String]() {
        didSet {
            //DispatchQueue.main.async {
                //self.updateTable()
            print(1)
            }
        }
    
    override init() {
        super.init()
        
        //startSession()
        
        //os_log("%@ WatchSessionManager: Paired Watch:", log: Log.viewcontroller, type: .info, session!.isPaired)
        //os_log("%@ WatchSessionManager: Installed:", log: Log.viewcontroller, type: .info, session!.isWatchAppInstalled)
    }
    
    // check for valid session
    var validSession: WCSession?{
        if let session = session, session.isPaired && session.isWatchAppInstalled{
            return session
        }
        return nil
    }
    
    func startSession(){
        session?.delegate = self
        session?.activate()
    }
    
    private func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    private func isReachable() -> Bool {
        return session!.isReachable
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //os_log("%@", "WatchSessionManager: activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //os_log("%@ WatchSessionManager: sessionDidBecomeInactive:", log: Log.viewcontroller, type: .info, session)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //os_log("%@ WatchSessionManager: sessionDidDeactivate:", log: Log.viewcontroller, type: .info, session)
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        //os_log("%@ WatchSessionManager: sessionWatchStateDidChange:", log: Log.viewcontroller, type: .info, session)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        //os_log("didReceiveMessage: %@", log: Log.viewcontroller, type: .info, message)
        if message["request"] as? String == "date" {
            replyHandler(["date" : "\(Date())"])
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        // do something
        //os_log("WatchSessionManager: sessionReachabilityDidChange()", log: Log.viewcontroller, type: .info)
    }
    
    // send data (for images etc)
    func sendMessageData(data: Data, replyHandler: ((Data) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        //os_log("WatchSessionManager: sendMessageData()", log: Log.viewcontroller, type: .info)
        session?.activate()
        session?.sendMessageData(data, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    // send dict message
    func sendMessage(message: [String : Any]) {
        //os_log("WatchSessionManager: sendMessage()", log: Log.viewcontroller, type: .info)
        
        if isReachable() {
            session?.sendMessage(message, replyHandler: nil, errorHandler: { (error) in
                print("Error sending message: %@", error)
            })
        } else {
            print("iPhone is not reachable!!")
        }
    }
    
    // send a list of top priced items to watch
    func sendTopPricesListToWatch(count: Int){
        // watch app context
        let watchSessionManager = WatchSessionManager.sharedManager
        
        var returnMessage: [String : Any] = [ : ]
        
        let list = Statistics.shared.mostExpensiveItems(elementsCount: count)
        for inv in list{
            returnMessage[DataKey.MostExpensiveList + inv.inventoryName!] = String(inv.price) as Any
        }
        
        let _ = watchSessionManager.transferUserInfo(userInfo: returnMessage)
    }
    
    // send a list of rooms with number of items per room in it
    func sendItemsByRoomListToWatch(){
        // watch app context
        let watchSessionManager = WatchSessionManager.sharedManager
        
        var returnMessage: [String : Any] = [ : ]
        
        let list = Statistics.shared.countItemsByRoomDict()
        for (key, val) in list{
            returnMessage[DataKey.TopRooms + key] = Int(val) as Any
        }
        
        let _ = watchSessionManager.transferUserInfo(userInfo: returnMessage)
    }
    
    // send a list of categories with number of items per category in it
    func sendItemsByCategoryListToWatch(){
        // watch app context
        let watchSessionManager = WatchSessionManager.sharedManager
        
        var returnMessage: [String : Any] = [ : ]
        
        let list = Statistics.shared.countItemsByCategoryDict()
        for (key, val) in list{
            returnMessage[DataKey.TopCategories + key] = Int(val) as Any
        }
        
        let _ = watchSessionManager.transferUserInfo(userInfo: returnMessage)
    }
    
    // send a list of brands with number of items per brand in it
    func sendItemsByBrandListToWatch(){
        // watch app context
        let watchSessionManager = WatchSessionManager.sharedManager
        
        var returnMessage: [String : Any] = [ : ]
        
        let list = Statistics.shared.countItemsByBrandDict()
        for (key, val) in list{
            returnMessage[DataKey.TopBrands + key] = Int(val) as Any
        }
        
        let _ = watchSessionManager.transferUserInfo(userInfo: returnMessage)
    }
    
    // send a list of owners with number of items per owner in it
    func sendItemsByOwnerListToWatch(){
        // watch app context
        let watchSessionManager = WatchSessionManager.sharedManager
        
        var returnMessage: [String : Any] = [ : ]
        
        let list = Statistics.shared.countItemsByOwnerDict()
        for (key, val) in list{
            returnMessage[DataKey.TopOwners + key] = Int(val) as Any
        }
        
        let _ = watchSessionManager.transferUserInfo(userInfo: returnMessage)
    }
    
}

extension WatchSessionManager{
    
    // send messages to watch with key (String) and value (Any)
    func updateApplicationContext(applicationContext: [String : Any]) throws {
        if let session = validSession{
            do{
                try session.updateApplicationContext(applicationContext)
            } catch let error{
                throw error
            }
        }
    }
    
    // background Sender
    func transferUserInfo(userInfo: [String : Any]) -> WCSessionUserInfoTransfer? {
        return validSession?.transferUserInfo(userInfo)
    }
}
