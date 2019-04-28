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
//  Inventory+CoreDataProperties.swift
//  Inventory
//
//  Created by Marcus Deuß on 19.06.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//
//

import Foundation
import CoreData


extension Inventory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Inventory> {
        return NSFetchRequest<Inventory>(entityName: "Inventory")
    }

    @NSManaged public var dateOfPurchase: NSDate?
    @NSManaged public var image: NSData?
    @NSManaged public var imageFileName: String?
    @NSManaged public var inventoryName: String?
    @NSManaged public var invoice: NSData?
    @NSManaged public var invoiceFileName: String?
    @NSManaged public var price: Int32
    @NSManaged public var remark: String?
    @NSManaged public var serialNumber: String?
    @NSManaged public var timeStamp: NSDate?
    @NSManaged public var warranty: Int32
    @NSManaged public var id: UUID?
    @NSManaged public var inventoryBrand: Brand?
    @NSManaged public var inventoryCategory: Category?
    @NSManaged public var inventoryOwner: Owner?
    @NSManaged public var inventoryRoom: Room?

}
