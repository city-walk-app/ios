//
//  HomeFooterView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/18.
//

import SwiftUI

/// 底部视图，包含打卡按钮和排行榜按钮
struct FooterView: View {
    /// 控制打卡弹窗的显示状态
    @Binding var isCurrentLocation: Bool
    /// 用户输入的文字
    @Binding var text: String
    /// 颜色标签数组
    let colorTags: [Color]
    /// 用户选择的图片
    @Binding var seletImage: UIImage?
    /// 控制图片选择路由的状态
    @Binding var isImageSelectRouter: Bool

    var body: some View {
        HStack {
            Button {
                self.isCurrentLocation.toggle()
            } label: {
                Text("打卡当前地点")
                    .frame(height: 60)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 50)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 33))
            }
            .padding(.trailing, 16)
            .sheet(isPresented: $isCurrentLocation) {
                HomePunchInView(
                    isCurrentLocation: $isCurrentLocation,
                    text: $text,
                    colorTags: colorTags,
                    seletImage: $seletImage,
                    isImageSelectRouter: $isImageSelectRouter
                )
            }

            NavigationLink(destination: RankingView()) {
                Circle()
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "list.star")
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
            }
        }
    }
}
