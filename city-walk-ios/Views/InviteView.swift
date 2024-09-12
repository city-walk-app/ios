//
//  InviteView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/7/15.
//

import Kingfisher
import SwiftUI

private let inviteBg1 = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/invite-bg-1.jpg")

/// 邀请
struct InviteView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    /// 全球的数据
    @EnvironmentObject private var globalData: GlobalData

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    KFImage(inviteBg1)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    // 按钮操作组
                    HStack(spacing: 23) {
                        Button {
                            Task {
                                await self.friendInvite()
                            }
                        } label: {
                            Text("复制邀请码")
                                .frame(width: 160, height: 48)
                                .font(.system(size: 16))
                                .foregroundStyle(Color("theme-1"))
                                .background(Color(hex: "#ffffff"))
                                .border(Color("theme-1"))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color("theme-1"), lineWidth: 2) // 使用 overlay 添加圆角边框
                                )
                        }

                        Button {
                            Task {
                                await self.friendInvite()
                            }

                            openWeChatApp() // 打开微信
                        } label: {
                            Text("微信粘贴给好友")
                                .frame(width: 160, height: 48)
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                                .background(Color("theme-1"))
                                .border(Color("theme-1"))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color("theme-1"), lineWidth: 1) // 使用 overlay 添加圆角边框
                                )
                        }
                    }
                    .padding(.top, 34)
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
    private func friendInvite() async {
        do {
            let res = try await Api.shared.friendInvite(params: [:])

            print("邀请结果", res)

//            globalData.hiddenLoading()

            guard res.code == 200, let data = res.data else {
                return
            }

            let code = try encrypt(string: "city-walk:" + data, usingKey: crytpoKey)

            print("code", code)

//            let resultCode = try decrypt(base64String: code, usingKey: crytpoKey)
//
//            print("解密结果", resultCode)

            UIPasteboard.general.string = code

            globalData.showToast(title: "复制成功")
        } catch {
            print("邀请朋友异常")
        }
    }

    /// 打开微信
    private func openWeChatApp() {
        if let url = URL(string: "weixin://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                globalData.showToast(title: "无法打开微信")
            }
        }
    }
}

#Preview {
    InviteView()
        .environmentObject(GlobalData())
}
