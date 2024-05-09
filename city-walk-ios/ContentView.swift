//
//  ContentView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

struct ContentView: View {
    /// 添加一个状态来控制是否跳转跳转页面
//    @State private var navigateRunView = false

    @EnvironmentObject var LaunchScreenDataModel: LaunchScreenData

    var body: some View {
        ZStack {
            // 离开启动页面进入模板页
            if LaunchScreenDataModel.states == .leave {
                LayoutView()
                    .environmentObject(UserInfoData())
                    .environmentObject(TabbarData())
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
}
