//
//  DeviceInfo.swift
//  Inventory
//
//  Created by Marcus Deuß on 17.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit

class DeviceInfo: NSObject {
    
    // iOS version info
    static func showOSVersion() -> String
        
    {
        return UIDevice.current.systemVersion
    }
    
    // returns the battery level as float
    static func showbatteryLevel() -> Float
    {
        return UIDevice.current.batteryLevel
    }
    
}
