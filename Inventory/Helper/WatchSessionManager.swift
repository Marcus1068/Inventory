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
    
    override init() {
        super.init()
        
        //startSession()
        
        os_log("%@ WatchSessionManager: Paired Watch:", log: Log.viewcontroller, type: .info, session!.isPaired)
        os_log("%@ WatchSessionManager: Installed:", log: Log.viewcontroller, type: .info, session!.isWatchAppInstalled)
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
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        os_log("%@", "WatchSessionManager: activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        os_log("%@ WatchSessionManager: sessionDidBecomeInactive:", log: Log.viewcontroller, type: .info, session)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        os_log("%@ WatchSessionManager: sessionDidDeactivate:", log: Log.viewcontroller, type: .info, session)
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        os_log("%@ WatchSessionManager: sessionWatchStateDidChange:", log: Log.viewcontroller, type: .info, session)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        os_log("didReceiveMessage: %@", log: Log.viewcontroller, type: .info, message)
        if message["request"] as? String == "date" {
            replyHandler(["date" : "\(Date())"])
        }
    }
    
}

extension WatchSessionManager{
    
    // send messages to watch
    func updateApplicationContext(applicationContext: [String : String]) throws {
        if let session = validSession{
            do{
                try session.updateApplicationContext(applicationContext)
            } catch let error{
                throw error
            }
        }
    }
    
    // send messages to watch
    func updateApplicationContext(applicationContext: [String : Int]) throws {
        if let session = validSession{
            do{
                try session.updateApplicationContext(applicationContext)
            } catch let error{
                throw error
            }
        }
    }
    
}
