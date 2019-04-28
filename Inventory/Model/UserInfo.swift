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
//  UserInfo.swift
//  Inventory
//
//  Created by Marcus Deuß on 09.04.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import Foundation

// singleton approach for storing user data app wide
class UserInfo{
    static var userName : String = NSLocalizedString("User Name", comment: "User Name")
    static var houseName : String = NSLocalizedString("House Name", comment: "House Name")
}
