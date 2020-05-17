//
//  UserDefaultKeys.swift
//  Inventory
//
//  Created by Marcus Deuß on 17.05.20.
//  Copyright © 2020 Marcus Deuß. All rights reserved.
//

import Foundation




class UserDefaultKeys{
    static let lastVersionPromptedForReviewKey: String = "lastVersionPromptedForReviewKey"
    static let processCompletedCountKey: String = "processCompletedCountKey"
    
    static let firstRun = "firstRun"
    
    // MARK: - Preferred Background Color
        
    static let nameColorKey = "nameColorKey" // Key for obtainins the preference view color.
}



// Extend UserDefaults for quick access to nameColorKey.
extension UserDefaults {
    
    @objc dynamic var nameColorKey: Int {
        return integer(forKey: UserDefaultKeys.nameColorKey)
    }
    
}
