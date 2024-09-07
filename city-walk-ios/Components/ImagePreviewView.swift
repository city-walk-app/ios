//
//  ImagePreviewView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/9/7.
//

import Kingfisher
import SwiftUI

/// 图片预览视图，支持左右滑动切换图片
struct ImagePreviewView: View {
    let images: [String]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            TabView(selection: $selectedIndex) {
                ForEach(images.indices, id: \.self) { index in
                    KFImage(URL(string: images[index]))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .edgesIgnoringSafeArea(.all)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always)) // 支持滑动切换
            .onTapGesture {
                // 点击图片退出预览
                isPresented = false
            }
        }
    }
}

#Preview {
    ImagePreviewView(images: [
        "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/uploads/test/2024-08-22/1724295860236-a21b737d67520929.jpg",
        "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/uploads/test/2024-08-22/1724300512162-c703dda74c507907.jpg",
        "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/uploads/test/2024-08-22/1724298982901-67c252707036cab1.jpg",
        "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/uploads/test/2024-09-07/1725699329061-1d97de8e7daac1cd.jpg",
    ],
    selectedIndex: .constant(0),
    isPresented: .constant(true))
}
