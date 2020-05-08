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
//  DeviceInfo.swift
//  Inventory
//
//  Created by Marcus Deuß on 17.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//

import UIKit

class DeviceInfo: NSObject {
    
    // iOS version info
    /// get the current iOS version
    ///
    /// - Parameters:
    ///
    /// - Returns: String with version number
    
    static func getOSVersion() -> String
    {
        return UIDevice.current.systemVersion
    }
    
    static func getOSName() -> String{
        return UIDevice.current.systemName
    }
    
    // iOS battery level
    /// get the current iOS battery level
    ///
    /// - Parameters:
    ///
    /// - Returns: Float with battery level
    
    static func getbatteryLevel() -> Float
    {
        return UIDevice.current.batteryLevel
    }
    
    /// get the current iOS device name
    ///
    /// - Parameters:
    /// - Returns:  the device name as String
    
    static func getDeviceName() -> String
    {
        return UIDevice.current.name
    }
    
    /// get the current iOS device UUID
    ///
    /// - Parameters:
    /// - Returns:  the device UUID
    
    static func getDeviceUUID() -> UUID
    {
        return UIDevice.current.identifierForVendor!
    }
}
