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

    /// 全球的数据
    @EnvironmentObject private var globalData: GlobalData

    var body: some View {
        NavigationView {
            VStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(
                                // colors: [Color(hex: "#ec7b45"), Color(hex: "#f0a953")]
                                colors: [Color(hex: "#de646c"), Color(hex: "#f0a953")]
                            ),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        VStack {
                            Image("logo")
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 120, height: 120)

                            Text("City Walk")
                                .font(.system(size: 46))
                                .bold()
                                .foregroundStyle(.white)

                            Text("记录你走过的每个地方。")
                                .font(.system(size: 15))
                                .foregroundStyle(.white)
                        }
                        .shadow(radius: 10)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
//                    .shadow(radius: 7)

                Spacer()

                Button {
                    Task {
                        await self.friendInvite() // 邀请朋友
                    }
                } label: {
                    Label("复制邀请码分享", systemImage: "doc.on.doc")
                        .frame(width: 300, height: 48)
                        .font(.system(size: 16))
                        .foregroundStyle(Color("theme-1"))
                        .background(Color("background-1"))
                        .border(Color("theme-1"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color("theme-1"), lineWidth: 2) // 使用 overlay 添加圆角边框
                        )
                }
                .padding(.top, 30)

                Button {
                    Task {
                        await self.friendInvite()
                    }

                    openWeChatApp() // 打开微信
                } label: {
                    Label("微信粘贴给好友", systemImage: "ellipsis.message")
                        .frame(width: 300, height: 48)
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
                .padding(.top, 9)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, viewPaddingTop)
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
