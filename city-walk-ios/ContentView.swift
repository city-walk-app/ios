//
//  ContentView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var launchScreenDataModel: LaunchScreenData
    @EnvironmentObject var userInfoDataModel: UserInfoData

    var body: some View {
        ZStack {
            // 离开启动页面进入模板页
            if launchScreenDataModel.states == .leave {
                // 如果存在信息，进入 layour
                if (userInfoDataModel.cacheInfo != nil) && (userInfoDataModel.cacheInfo?.id != nil) {
                    LayoutView()
                        .environmentObject(UserInfoData())
                        .environmentObject(TabbarData())
                }
                // 否则需要登录
                else {
                    LoginView()
                }
            } else {
                LaunchView()
                    .environmentObject(UserInfoData())
                    .environmentObject(TabbarData())
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LaunchScreenData())
        .environmentObject(UserInfoData())
}
