//
//  URLImage.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

// 一个简单的异步图像加载视图
struct URLImage: View {
    let url: URL
    @State private var image: Image? = nil

    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
        }.resume()
    }
}
