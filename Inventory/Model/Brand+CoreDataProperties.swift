//
//  Brand+CoreDataProperties.swift
//  Inventory
//
//  Created by Marcus Deuß on 17.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//
//

import Foundation
import CoreData


extension Brand {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Brand> {
        return NSFetchRequest<Brand>(entityName: "Brand")
    }

    @NSManaged public var brandName: String?
    @NSManaged public var brandInventory: NSSet?

}

// MARK: Generated accessors for brandInventory
extension Brand {

    @objc(addBrandInventoryObject:)
    @NSManaged public func addToBrandInventory(_ value: Inventory)

    @objc(removeBrandInventoryObject:)
    @NSManaged public func removeFromBrandInventory(_ value: Inventory)

    @objc(addBrandInventory:)
    @NSManaged public func addToBrandInventory(_ values: NSSet)

    @objc(removeBrandInventory:)
    @NSManaged public func removeFromBrandInventory(_ values: NSSet)

}
