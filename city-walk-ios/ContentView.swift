//
//  ContentView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

struct ContentView: View {
    /// 启动页面数据
    @EnvironmentObject var launchScreenData: LaunchScreenData
    /// 用户数据
    @EnvironmentObject var userInfoData: UserInfoData

    var body: some View {
        ZStack {
            // 离开启动页面进入模板页
            if launchScreenData.states == .leave {
                // 如果存在信息，进入首页
                if (userInfoData.cacheInfo != nil) && (userInfoData.cacheInfo?.user_id != nil) {
                    HomeView()
                        .environmentObject(UserInfoData())
                        .environmentObject(FriendsData())
                        .environmentObject(RankingData())
                        .environmentObject(MainData())
                }
                // 否则需要登录
                else {
                    LoginView()
                }
            } else {
                LaunchView()
                    .environmentObject(UserInfoData())
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LaunchScreenData())
        .environmentObject(UserInfoData())
        .environmentObject(FriendsData())
        .environmentObject(RankingData())
        .environmentObject(MainData())
}
