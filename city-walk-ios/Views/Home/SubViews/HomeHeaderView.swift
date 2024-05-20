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
    @EnvironmentObject var userInfoDataModel: UserInfoData

    var body: some View {
        HStack {
            if let info = userInfoDataModel.data {
                NavigationLink(destination: MainView(userId: info.id)) {
                    URLImage(url: URL(string: "\(BASE_URL)/\(info.avatar ?? "")")!)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                        .mask(Circle())
                }
            } else {
                NavigationLink(destination: LoginView()) {
                    Image(systemName: "person")
                        .font(.system(size: 24))
                        .foregroundStyle(.black)
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
