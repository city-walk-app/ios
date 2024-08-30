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
    /// 缓存数据
    @EnvironmentObject private var storageData: StorageData

    var body: some View {
        Group {
            if launchScreenData.states == .leave {
                if storageData.token != nil && storageData.token != "" {
                    homeViewGroup
                } else {
                    LoginView()
                        .environmentObject(StorageData())
                        .environmentObject(LoadingData())
                        .environmentObject(HomeData())
                        .environmentObject(GlobalData())
                }
            } else {
                LaunchView()
            }
        }
    }

    private var homeViewGroup: some View {
        HomeView()
            .environmentObject(FriendsData())
            .environmentObject(RankingData())
            .environmentObject(MainData())
            .environmentObject(LoadingData())
            .environmentObject(HomeData())
            .environmentObject(StorageData())
            .environmentObject(GlobalData())
    }
}

#Preview {
    ContentView()
        .environmentObject(LaunchScreenData())
        .environmentObject(StorageData())
}
