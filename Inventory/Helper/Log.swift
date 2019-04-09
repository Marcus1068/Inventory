//
//  Log.swift
//  Inventory
//
//  Created by Marcus Deuß on 09.04.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import Foundation
import os

private let subsystem = "de.marcus-deuss"

struct Log {
    static let coredata = OSLog(subsystem: subsystem, category: "coredata")
    static let viewcontroller = OSLog(subsystem: subsystem, category: "viewcontroller")
    static let appdelegate = OSLog(subsystem: subsystem, category: "appdelegate")
    static let networking = OSLog(subsystem: subsystem, category: "networking")

}
