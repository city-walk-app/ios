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
                    HomeView()
                        .environmentObject(UserInfoData())
                }
                // 否则需要登录
                else {
                    LoginView()
                }
            } else {
                LaunchView()
                    .environmentObject(UserInfoData())
                    .environmentObject(GlobalData())
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LaunchScreenData())
        .environmentObject(UserInfoData())
        .environmentObject(GlobalData())
}
