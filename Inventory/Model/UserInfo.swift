//
//  UserInfo.swift
//  Inventory
//
//  Created by Marcus Deuß on 09.04.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import Foundation

class UserInfo{
    var userName : String
    var houseName : String
    
    init(userName: String, houseName: String)
    {
        self.userName = userName
        self.houseName = houseName
    }
    
    init(){
        self.userName = NSLocalizedString("User Name", comment: "User Name")
        self.houseName = NSLocalizedString("House Name", comment: "House Name")
    }
}
