// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct AsyncPhoto: View {
    
    @StateObject private var viewModel: AsyncViewModel
    
    @State private var image: Image?
    
    public init(for url: URL?) {
        _viewModel = StateObject(wrappedValue: AsyncViewModel(imageUrl: url))
    }
    
    public var body: some View {
        Group {
            if let image = image {
                image
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
    
//    private func imageFromData(_ data: Data) -> some View {
////        if let cgImageSource = CGImageSourceCreateWithData(data as CFData, nil),
////           let cgImage = CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil) {
////            return Image(decorative: cgImage, scale: 1.0, orientation: .up)
////        } else {
////            return Image(systemName: "photo")
////        }
//        if let image = UIImage(data: data) {
//            return Image(ima)
//        }
//    }
    
    func imageFromData(_ data: Data) -> Image? {
        #if os(iOS)
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        #elseif os(macOS)
        if let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        #endif
        return nil
    }
}
