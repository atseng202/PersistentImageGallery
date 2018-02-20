//
//  Document.swift
//  PersistentImageGallery
//
//  Created by Alan Tseng on 2/19/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

