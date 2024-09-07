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

    var body: some View {
        Group {
            if launchScreenData.states == .leave {
                homeViewGroup
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
            .environmentObject(HomeData())
            .environmentObject(StorageData())
            .environmentObject(GlobalData())
    }
}

#Preview {
    ContentView()
        .environmentObject(LaunchScreenData())
}
