//
//  HomeHeaderView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/18.
//

import SwiftUI

/// 头部视图，包含用户信息和设置按钮
struct HomeHeaderView: View {
    /// 用户信息数据模型
    var userInfoDataModel: UserInfoData
    /// 缓存信息
//    let cacheInfo: UserLoginEmail.UserLoginEmailData
//    let cacheInfo = UserCache.shared.getInfo()

    var body: some View {
        HStack {
            Text("\(userInfoDataModel.data)")
            if userInfoDataModel.data == nil {
                NavigationLink(destination: LoginView()) {
                    Image(systemName: "person")
                        .font(.system(size: 24))
                        .foregroundStyle(.black)
                }
            } else {
                NavigationLink(destination: MainView(userId: userInfoDataModel.data!.id)) {
                    URLImage(url: URL(string: "\(BASE_URL)/\(userInfoDataModel.data!.avatar ?? "")")!)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                        .mask(Circle())
                }
            }

            Spacer()

            NavigationLink(destination: SettingView()) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 23))
                    .foregroundStyle(.black)
            }
        }
        .padding()
    }
}
