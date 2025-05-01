//
//  AsyncImage.swift
//  AsyncPhoto
//
//  Created by Alok Kumar on 01/05/25.
//

import Foundation

class AsyncImage {
    
    private var cache = PhotoCache()
    
    func download(imageUrl: URL?) async throws -> Data {
        guard let url = imageUrl else {
            throw NSError(domain: "URL not found", code: 404)
        }
        
        let key = url.absoluteString
        
        if let cachedData = await cache.get(key: key) {
            debugPrint("loaded from cache: \(url.absoluteString)")
            return cachedData
        }
        
        let (data, httpResponse) = try await URLSession.shared.data(from: url)
        
        guard let response = httpResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(response.statusCode) else {
            throw URLError(.init(rawValue: response.statusCode))
        }
        
        debugPrint("cached: \(url.absoluteString)")
        await cache.set(data, key: url.absoluteString)
        
        return data
    }
}
