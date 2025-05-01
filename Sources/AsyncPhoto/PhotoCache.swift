//
//  PhotoCache.swift
//  AsyncPhoto
//
//  Created by Alok Kumar on 01/05/25.
//

import Foundation

actor PhotoCache {
    
    private var cache = NSCache<NSString, NSData>()
    
    func set(_ data: Data, key: String) {
        cache.setObject(data as NSData, forKey: key as NSString)
    }
    
    func get(key: String) -> Data? {
        cache.object(forKey: key as NSString) as? Data
    }
    
}
