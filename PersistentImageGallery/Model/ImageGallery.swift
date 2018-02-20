//
//  ImageGallery.swift
//  PersistentImageGallery
//
//  Created by Alan Tseng on 2/19/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import Foundation

struct ImageGallery: Codable {
    
    var urlInfo: [Int: [URL:Int]]
    
    init(urlInfo: [Int: [URL: Int]]) {
        self.urlInfo = urlInfo
    }
    
    // MARK: - Convenience init for Decoding JSON
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(ImageGallery.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    // MARK: - Encoding
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
}
