//
//  SettingView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/20.
//

import SwiftUI

struct UserInfoDataModel {
    let title: String
    let key: String
    let icon: String
    let color: Color
}

struct SettingView: View {
    /// 是否跳转到登录页面
    @State private var isGoLoginView = false
    /// 是否显示退出登录的按钮确认框
    @State private var showingLogoutAlert = false
    /// 用户信息
    @EnvironmentObject var userInfoDataModel: UserInfoData
    /// 用户信息列表选项
    let userInfoItems: [UserInfoDataModel] = [
        UserInfoDataModel(title: "名字", key: "nick_name", icon: "person.fill", color: .blue),
        UserInfoDataModel(title: "性别", key: "gender", icon: "mic.square.fill", color: .red),
        UserInfoDataModel(title: "城市", key: "city", icon: "mic.square.fill", color: .red),
        UserInfoDataModel(title: "邮箱", key: "nick_name", icon: "person.fill", color: .blue),
        UserInfoDataModel(title: "手机", key: "mobel", icon: "circle.square", color: .orange),
        UserInfoDataModel(title: "签名", key: "signature", icon: "house", color: .green)
    ]

    var body: some View {
        NavigationStack {
            // 跳转到登录页面
            NavigationLink(
                destination: LoginView(),
                isActive: $isGoLoginView
            ) {
                EmptyView()
            }

            // 选项列表
            VStack {
                List {
                    // 基本信息
                    Section {
                        Button {} label: {
                            HStack {
                                URLImage(url: URL(string: "\(BASE_URL)/\(userInfoDataModel.data!.avatar ?? "")")!)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 70, height: 70)
                                    .mask(Circle())
                                Text("欢迎使用 City Walk!")
                                    .foregroundStyle(.black)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }

                    // 信息
                    Section {
                        ForEach(userInfoItems.indices, id: \.self) { index in
                            Button {} label: {
                                HStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 36, height: 36)
                                        .foregroundColor(userInfoItems[index].color) // 修改为指定的颜色
                                        .overlay {
                                            Image(systemName: userInfoItems[index].icon)
                                                .foregroundColor(.white)
                                        }

                                    Text(userInfoItems[index].title)
                                        .foregroundStyle(.black)

                                    Spacer()

                                    // 使用 userInfoDataModel.data 字典中对应 key 的值作为文本
                                    //                                if let value = userInfoDataModel.data?[userInfoItems[index].key] {
                                    //                                    Text(value)
                                    //                                }

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }

                    // 赞助
                    Section {
                        Button {} label: {
                            Text("赞助")
                        }
                    }

                    // 作者
                    Section(header: Text("作者")) {
                        Button {} label: {
                            HStack {
                                Text("微信")

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }

                        Button {} label: {
                            HStack {
                                Text("𝕏")

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }

                        Button {} label: {
                            HStack {
                                Text("Github")

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    // 应用服务
                    Section {
                        Button {} label: {
                            Text("给个好评")
                        }

                        Button {} label: {
                            Text("分享给好友")
                        }

                        Button {} label: {
                            Text("加入CityWalk开发者")
                        }
                    }

                    // 退出登录
                    Section {
                        Button {
                            self.showingLogoutAlert.toggle()
                        } label: {
                            HStack {
                                Spacer()
                                Text("退出登录")
                                    .foregroundStyle(.red)
                                Spacer()
                            }
                        }
                        .alert(isPresented: $showingLogoutAlert) {
                            // 当 showingLogoutAlert 为 true 时，显示确认框
                            Alert(
                                title: Text("提示"),
                                message: Text("确定退出当前账号吗?"),
                                primaryButton: .destructive(Text("确定"), action: {
                                    UserCache.shared.deleteInfo()
                                    isGoLoginView = true
                                }),
                                secondaryButton: .cancel(Text("取消"))
                            )
                        }
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

#Preview {
    SettingView()
        .environmentObject(UserInfoData())
}
