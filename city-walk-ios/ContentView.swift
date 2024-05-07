//
//  ContentView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

struct ContentView: View {
    /// 添加一个状态来控制是否跳转跳转页面
    @State private var navigateRunView = false

    var body: some View {
        ZStack {
            if navigateRunView == true {
                LayoutView()
                    .environmentObject(UserInfoData()) // 注入用户信息环境变量
                    .environmentObject(TabbarData())
            } else {
                LaunchView()
                    .environmentObject(UserInfoData()) // 注入用户信息环境变量
                    .environmentObject(TabbarData())
            }
        }
        .onAppear {
            self.checkPermissionsAndNavigate()
        }
    }

    // 检查权限并延迟跳转
    private func checkPermissionsAndNavigate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("准备跳转首页")
            navigateRunView = true
        }
    }
}

#Preview {
    ContentView()
}
