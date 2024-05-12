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
    @EnvironmentObject var userInfoDataModel: UserInfoData

    @State var userInfoItems: [UserInfoDataModel] = [
        UserInfoDataModel(title: "名字", key: "nick_name", icon: "person.fill", color: .blue),
        UserInfoDataModel(title: "邮箱", key: "email", icon: "mic.square.fill", color: .red),
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
                                Text("欢迎使用")
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
                            HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(userInfoItems[index].color) // 修改为指定的颜色
                                    .overlay {
                                        Image(systemName: userInfoItems[index].icon)
                                            .foregroundColor(.white)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 10)) // 添加裁剪圆角

                                Text(userInfoItems[index].title) // 使用条目的 key 属性作为文本

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

                    // 服务

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
