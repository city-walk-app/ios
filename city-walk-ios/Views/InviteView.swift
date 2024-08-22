//
//  InviteView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/7/15.
//

import SwiftUI

struct InviteView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

//    @EnvironmentObject var loadingData: LoadingData

    var body: some View {
        NavigationView {
            ScrollView {
                ZStack {
                    VStack {
                        // 按钮操作组
                        HStack(spacing: 23) {
                            Button {
//                                loadingData.showLoading(options: LoadingParams(title: "处理中..."))
                            } label: {
                                Text("复制邀请链接")
                                    .frame(width: 160, height: 48)
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color(hex: "#F3943F"))
                                    .background(Color(hex: "#ffffff"))
                                    .border(Color(hex: "#F3943F"))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color(hex: "#F3943F"), lineWidth: 1) // 使用 overlay 添加圆角边框
                                    )
                            }

                            Button {
//                                loadingData.showLoading(options: LoadingParams(title: "处理中..."))
                            } label: {
                                Text("分享")
                                    .frame(width: 160, height: 48)
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white)
                                    .background(Color(hex: "#F3943F"))
                                    .border(Color(hex: "#F3943F"))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color(hex: "#F3943F"), lineWidth: 1) // 使用 overlay 添加圆角边框
                                    )
                            }
                        }
                        .padding(.top, 34)
                    }

//                    Loading()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 200)
                .padding(.top, viewPaddingTop)
                .frame(maxWidth: .infinity)
            }
            .overlay(alignment: .top) {
                VariableBlurView(maxBlurRadius: 12)
                    .frame(height: topSafeAreaInsets + globalNavigationBarHeight)
                    .ignoresSafeArea()
            }
            .background(viewBackground)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("邀请朋友")
                    .font(.headline)
            }
        }
        .navigationBarItems(leading: BackButton(action: {
            self.presentationMode.wrappedValue.dismiss() // 返回上一个视图
        })) // 自定义返回按钮
    }
}

#Preview {
    InviteView()
//        .environmentObject(LoadingData())
}
