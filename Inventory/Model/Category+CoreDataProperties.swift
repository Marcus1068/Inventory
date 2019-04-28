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
//  Category+CoreDataProperties.swift
//  Inventory
//
//  Created by Marcus Deuß on 23.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var categoryName: String?
    @NSManaged public var categoryInventory: NSSet?

}

// MARK: Generated accessors for categoryInventory
extension Category {

    @objc(addCategoryInventoryObject:)
    @NSManaged public func addToCategoryInventory(_ value: Inventory)

    @objc(removeCategoryInventoryObject:)
    @NSManaged public func removeFromCategoryInventory(_ value: Inventory)

    @objc(addCategoryInventory:)
    @NSManaged public func addToCategoryInventory(_ values: NSSet)

    @objc(removeCategoryInventory:)
    @NSManaged public func removeFromCategoryInventory(_ values: NSSet)

}
