//
//  InviteView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/7/15.
//

import SwiftUI

/// 邀请
struct InviteView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    /// loading 数据
    @EnvironmentObject private var loadingData: LoadingData

    var body: some View {
        NavigationView {
            ScrollView {
                ZStack {
                    VStack {
                        // 按钮操作组
                        HStack(spacing: 23) {
                            Button {
                                Task {
                                    await self.friendInvite()
                                }
                            } label: {
                                Text("复制邀请链接")
                                    .frame(width: 160, height: 48)
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color("theme-1"))
                                    .background(Color(hex: "#ffffff"))
                                    .border(Color("theme-1"))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color("theme-1"), lineWidth: 1) // 使用 overlay 添加圆角边框
                                    )
                            }

//                            Button {} label: {
//                                Text("分享")
//                                    .frame(width: 160, height: 48)
//                                    .font(.system(size: 16))
//                                    .foregroundStyle(.white)
//                                    .background(Color("theme-1"))
//                                    .border(Color("theme-1"))
//                                    .clipShape(RoundedRectangle(cornerRadius: 14))
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 14)
//                                            .stroke(Color("theme-1"), lineWidth: 1) // 使用 overlay 添加圆角边框
//                                    )
//                            }
                        }
                        .padding(.top, 34)
                    }

                    // loading 组件
                    Loading()
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

    /// 邀请朋友
    func friendInvite() async {
        do {
            loadingData.showLoading(options: LoadingParams(title: "处理中..."))

            let res = try await Api.shared.friendInvite(params: [:])

            loadingData.hiddenLoading()

            guard res.code == 200, let data = res.data else {
                return
            }

            UIPasteboard.general.string = data
        } catch {
            print("邀请朋友异常")
            loadingData.hiddenLoading()
        }
    }
}

#Preview {
    InviteView()
        .environmentObject(LoadingData())
}
