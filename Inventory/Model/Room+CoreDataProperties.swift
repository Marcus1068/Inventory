//
//  Room+CoreDataProperties.swift
//  Inventory
//
//  Created by Marcus Deuß on 23.04.18.
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
