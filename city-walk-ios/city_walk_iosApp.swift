//
//  city_walk_iosApp.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

// 全局变量存储导航栏高度
var globalNavigationBarHeight: CGFloat = 44 // 默认值设置为44

@main
struct city_walk_iosApp: App {
    init() {
        // 初始化时获取导航栏高度
        let window = UIApplication.shared.windows.first
        let navHeight = window?.rootViewController?.navigationController?.navigationBar.frame.height
        globalNavigationBarHeight = navHeight ?? 44 // 如果获取失败则使用默认值
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LaunchScreenData())
                .environmentObject(UserInfoData())
//                .environmentObject(GlobalData())
        }
    }
}
