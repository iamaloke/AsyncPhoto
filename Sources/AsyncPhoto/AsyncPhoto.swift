// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

struct AsyncPhoto: View {
    
    @StateObject private var viewModel: AsyncViewModel
    
    @State private var image: Image?
    
    init(for url: URL?) {
        _viewModel = StateObject(wrappedValue: AsyncViewModel(imageUrl: url))
    }
    
    var body: some View {
        Group {
            if let image = image {
                
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
            } else {
                ProgressView()
                    .onAppear {
                        image = imageFromData(viewModel.imageData)
                    }
            }
        }
        .task {
            await viewModel.fetchImage()
        }
    }
    
    func imageFromData(_ data: Data) -> Image {
        if let cgImageSource = CGImageSourceCreateWithData(data as CFData, nil),
           let cgImage = CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil) {
            return Image(decorative: cgImage, scale: 1.0, orientation: .up)
        } else {
            return Image(systemName: "photo")
        }
    }
}
