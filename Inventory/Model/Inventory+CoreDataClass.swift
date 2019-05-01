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
//  Inventory+CoreDataClass.swift
//  Inventory
//
//  Created by Marcus Deuß on 17.04.18.
//  Copyright © 2018 Marcus Deuß. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Inventory)
public class Inventory: NSManagedObject {
    func stringForDateOfPurchase() -> String {
        guard let dateOfPurchase = dateOfPurchase else { return "" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "YY-MM-DD"  // FIXME: hard coded date format
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: dateOfPurchase as Date)
    }
    
    func stringForDateTimeStamp() -> String {
        guard let ts = timeStamp else { return "" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "YY-MM-DD"
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: ts as Date)
    }
    
    // generate one line for CVS file per database entry and check for nil
    // all objects have to be converted to string
    func csv() -> String {
        let coalescedInventoryName = inventoryName ?? ""
        let coalescedPrice = String(price)
        let coalescedRemark = remark ?? ""
        let coalescedSerialNumber = serialNumber ?? ""
        let coalescedWarranty = String(warranty)
        let coalescedRoomName = inventoryRoom?.roomName ?? ""
        let coalescedBrandName = inventoryBrand?.brandName ?? ""
        let coalescedOwnerName = inventoryOwner?.ownerName ?? ""
        let coalescedCategoryName = inventoryCategory?.categoryName ?? ""
        let coalescedImageFileName = imageFileName ?? ""
        let coalescedInvoiceFileName = invoiceFileName ?? ""
        let coalescedID = id?.uuidString ?? ""
        
        let newLine = """
        \(coalescedInventoryName),\(stringForDateOfPurchase()),\(coalescedPrice),\(coalescedSerialNumber),\(coalescedRemark),\(stringForDateTimeStamp()),\(coalescedRoomName),\(coalescedOwnerName),\(coalescedCategoryName),\(coalescedBrandName),\(coalescedWarranty),\(coalescedImageFileName),\(coalescedInvoiceFileName),\(coalescedID)\n
        """
        return newLine
    }
}
