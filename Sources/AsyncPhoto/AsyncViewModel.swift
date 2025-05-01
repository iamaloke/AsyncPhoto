//
//  AsyncViewModel.swift
//  AsyncPhoto
//
//  Created by Alok Kumar on 01/05/25.
//

import SwiftUI

@MainActor
class AsyncViewModel: ObservableObject {
    
    @Published var imageData: Data = Data()
    private var imageUrl: URL?
    
    init(imageUrl: URL?) {
        self.imageUrl = imageUrl
    }
    
    func fetchImage() async {
        do {
            imageData = try await AsyncImage().download(imageUrl: imageUrl)
        } catch {
            debugPrint("URL not valid: \(imageUrl?.absoluteString ?? "")")
        }
    }
}
