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
//  Owner+CoreDataProperties.swift
//  Inventory
//
//  Created by Marcus Deuß on 23.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//
//

import Foundation
import CoreData


extension Owner {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Owner> {
        return NSFetchRequest<Owner>(entityName: "Owner")
    }

    @NSManaged public var ownerName: String?
    @NSManaged public var ownerInventory: NSSet?

}

// MARK: Generated accessors for ownerInventory
extension Owner {

    @objc(addOwnerInventoryObject:)
    @NSManaged public func addToOwnerInventory(_ value: Inventory)

    @objc(removeOwnerInventoryObject:)
    @NSManaged public func removeFromOwnerInventory(_ value: Inventory)

    @objc(addOwnerInventory:)
    @NSManaged public func addToOwnerInventory(_ values: NSSet)

    @objc(removeOwnerInventory:)
    @NSManaged public func removeFromOwnerInventory(_ values: NSSet)

}
