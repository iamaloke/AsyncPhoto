// The Swift Programming Language
// https://docs.swift.org/swift-book

#if canImport(AppKit)
import AppKit
#endif
import Combine
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public class AsyncPhoto: @unchecked Sendable {
    
    @State private var image: Image?
    
    private var cache = PhotoCache()
    
    public static let shared = AsyncPhoto()
    
    private init() {}
    
    public func download(imageUrl: URL?) async throws -> some View {
        guard let url = imageUrl else {
            throw NSError(domain: "URL not found", code: 404)
        }
        
        let key = url.absoluteString
        
        if let cachedData = await cache.get(key: key) {
            return imageView(data: cachedData)
        }
        
        let (data, httpResponse) = try await URLSession.shared.data(from: url)
        
        guard let response = httpResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(response.statusCode) else {
            throw URLError(.init(rawValue: response.statusCode))
        }
        
        await cache.set(data, key: key)
        
        return imageView(data: data)
    }
    
    @ViewBuilder
    private func imageView(data: Data?) -> some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .onAppear {
                        if let data = data {
#if os(macOS)
                            if let nsImage = NSImage(data: data) {
                                self.image = Image(nsImage: nsImage)
                            } else {
                                self.image = Image(systemName: "photo")
                            }
#else
                            if let uiImage = UIImage(data: data) {
                                self.image = Image(uiImage: uiImage)
                            } else {
                                self.image = Image(systemName: "photo")
                            }
#endif
                        }
                    }
            }
        }
    }
}
