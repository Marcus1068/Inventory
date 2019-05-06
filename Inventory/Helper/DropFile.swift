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
//  PDFDocument.swift
//  Inventory
//
//  Created by Marcus Deuß on 06.05.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import UIKit
import MobileCoreServices

// this class is needed for getting Drag/Drop support on iPad up and running for PDF file types
// URL and UIImage are supported natively, but PDF is not...
// this class can support other file types as well
class DropFile : NSObject, NSItemProviderReading {
    let fileData:Data?
    
    required init(data:Data, typeIdentifier:String) {
        fileData = data
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypePDF as String]
        
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(data: data, typeIdentifier: typeIdentifier)
    }
}
