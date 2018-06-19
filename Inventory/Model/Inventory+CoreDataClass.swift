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
        dateFormatter.dateFormat = "YY-MM-DD"
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
