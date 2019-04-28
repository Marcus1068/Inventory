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
    static func showOSVersion() -> String
    {
        return UIDevice.current.systemVersion
    }
    
    // returns the battery level as float
    static func showbatteryLevel() -> Float
    {
        return UIDevice.current.batteryLevel
    }
    
    // returns the device name as String
    static func showDeviceName() -> String
    {
        return UIDevice.current.name
    }
    
    // returns the device running this app as UUID
    static func showDeviceUUID() -> UUID
    {
        return UIDevice.current.identifierForVendor!
    }
}
