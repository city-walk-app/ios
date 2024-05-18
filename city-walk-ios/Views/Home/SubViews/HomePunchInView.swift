//
//  HomePunchInView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/18.
//

import SwiftUI

/// 打卡视图，显示打卡详情
struct HomePunchInView: View {
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
        NavigationView {
            VStack {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button {
                            self.isCurrentLocation.toggle()
                        } label: {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 27))
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("颜色标签")
                        
                        HStack {
                            ForEach(colorTags.indices, id: \.self) { index in
                                Circle()
                                    .fill(colorTags[index])
                                    .frame(width: 20, height: 20)
                            }
                        }
                        
                        Text("这一刻的想法")
                        
                        TextField("这一刻的想法？", text: $text)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("选择当前的照片")
                        
                        NavigationLink(
                            destination: HomePhotoView(seletImage: $seletImage, isActive: $isImageSelectRouter),
                            isActive: $isImageSelectRouter
                        ) {
                            Button {
                                self.isImageSelectRouter = true
                            } label: {
                                if let image = self.seletImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 200, height: 200)
                                } else {
                                    Rectangle()
                                        .fill(.gray.opacity(0.1))
                                        .frame(width: 200, height: 200)
                                        .overlay {
                                            Image(systemName: "photo")
                                        }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                Button {
                    // 调用打卡逻辑
                } label: {
                    Spacer()
                    Text("就这样")
                    Spacer()
                }
                .frame(height: 50)
                .foregroundStyle(.white)
                .bold()
                .background(.blue, in: RoundedRectangle(cornerRadius: 30))
            }
            .padding(20)
        }
    }
}
