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
//  WatchConstants.swift
//  Inventory
//
//  Created by Marcus Deuß on 25.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import Foundation

public struct DataKey {
    // for use with Watch communication
    static let TopPrice = "TopPrice"
    static let TopRooms = "TopRooms"
    static let AmountMoney = "AmountMoney"
    static let TopOwners = "TopOwners"
    static let TopCategories = "TopCategories"
    static let TopBrands = "TopBrands"
    static let ImageData = "ImageData"
    static let MostExpensiveList = "MostExpensiveList"
    static let ItemCount = "ItemCount"
}

// used for general localization
public struct Local{
    //User region setting return
    static let locale = Locale.current
    
    //Returns true if the locale uses the metric system (Note: Only three countries do not use the metric system: the US, Liberia and Myanmar.)
    static let isMetric = locale.usesMetricSystem
    
    //Returns the currency code of the locale. For example, for “zh-Hant-HK”, returns “HKD”.
    static let currencyCode  = locale.currencyCode
    
    //Returns the currency symbol of the locale. For example, for “zh-Hant-HK”, returns “HK$”.
    static let currencySymbol = locale.currencySymbol
    
    static let languageCode = locale.languageCode
    
    static let mostExpensiveItems = NSLocalizedString("Most expensive items", comment: "Most expensive items")
    static let mostUsedRooms = NSLocalizedString("Most used rooms", comment: "Most used rooms")
    static let mostUsedCategories = NSLocalizedString("Most used categories", comment: "Most used categories")
    static let mostUsedBrands = NSLocalizedString("Most used brands", comment: "Most used brands")
    static let mostUsedOwners = NSLocalizedString("Most used owners", comment: "Most used owners")
    
    static func currentLocaleForDate() -> String{
        return Local.languageCode!
        
    }
    
    // app group name
    static let appGroup = "group.de.marcus-deuss"
    
}

