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
