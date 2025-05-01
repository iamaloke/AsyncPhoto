// The Swift Programming Language
// https://docs.swift.org/swift-book

import Combine
import SwiftUI

class AsyncDownloader {
    
    private var cache = PhotoCache()
    
    //public static let shared = AsyncDownloader()
    
    //private init() {}
    
    func download(imageUrl: URL?) async throws -> Data {
        guard let url = imageUrl else {
            throw NSError(domain: "URL not found", code: 404)
        }
        
        let key = url.absoluteString
        
        if let cachedData = await cache.get(key: key) {
            return cachedData
        }
        
        let (data, httpResponse) = try await URLSession.shared.data(from: url)
        
        guard let response = httpResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(response.statusCode) else {
            throw URLError(.init(rawValue: response.statusCode))
        }
        
        await cache.set(data, key: url.absoluteString)
        
        return data
    }
}

struct AsyncPhoto: View {
    
    @StateObject private var viewModel = ViewModel()
    
    @State private var image: Image?
    
    @State private var imageUrl: URL
    
    init(for url: URL) {
        self.imageUrl = url
    }
    
    
    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                if let data = viewModel.imageData {
                    imageFromData(data)
                }
            }
        }
        .task {
            await viewModel.fetchImage(for: imageUrl)
        }
    }
    
    @ViewBuilder
    func imageFromData(_ data: Data) -> some View {
        if let cgImageSource = CGImageSourceCreateWithData(data as CFData, nil),
           let cgImage = CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil) {
            Image(decorative: cgImage, scale: 1.0, orientation: .up)
        } else {
            Image(systemName: "photo")
                .foregroundColor(.gray)
        }
    }
}

@MainActor
class ViewModel: ObservableObject {
    
    @Published var imageData: Data?
    
    func fetchImage(for url: URL?) async {
        do {
            imageData = try await AsyncDownloader().download(imageUrl: url)
        } catch {
            debugPrint("URL not valid: \(url?.absoluteString ?? "")")
        }
    }
}
