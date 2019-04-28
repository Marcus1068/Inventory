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
//  Room+CoreDataProperties.swift
//  Inventory
//
//  Created by Marcus Deuß on 20.05.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//
//

import Foundation
import CoreData


extension Room {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Room> {
        return NSFetchRequest<Room>(entityName: "Room")
    }

    @NSManaged public var roomName: String?
    @NSManaged public var roomImage: NSData?
    @NSManaged public var roomInventory: NSSet?

}

// MARK: Generated accessors for roomInventory
extension Room {

    @objc(addRoomInventoryObject:)
    @NSManaged public func addToRoomInventory(_ value: Inventory)

    @objc(removeRoomInventoryObject:)
    @NSManaged public func removeFromRoomInventory(_ value: Inventory)

    @objc(addRoomInventory:)
    @NSManaged public func addToRoomInventory(_ values: NSSet)

    @objc(removeRoomInventory:)
    @NSManaged public func removeFromRoomInventory(_ values: NSSet)

}
