//
//  ContentView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

struct ContentView: View {
    /// 启动页面数据
    @EnvironmentObject private var launchScreenData: LaunchScreenData
    /// 用户数据
    @EnvironmentObject private var userInfoData: UserInfoData

    var body: some View {
        Group {
            if launchScreenData.states == .leave {
                if userInfoData.cacheInfo != nil {
                    homeViewGroup
                } else {
                    LoginView()
                }
            } else {
                LaunchView()
            }
        }
        .environmentObject(UserInfoData())
    }

    private var homeViewGroup: some View {
        HomeView()
            .environmentObject(FriendsData())
            .environmentObject(RankingData())
            .environmentObject(MainData())
            .environmentObject(LoadingData())
            .environmentObject(HomeData())
    }
}

#Preview {
    ContentView()
        .environmentObject(LaunchScreenData())
        .environmentObject(UserInfoData())
}
