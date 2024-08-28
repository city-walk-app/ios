//
//  LaunchView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/1.
//

import Network
import SwiftUI

struct LaunchView: View {
    /// 缓存信息
//    private let cacheInfo = UserCache.shared.getInfo()

    /// 用户信息数据
//    @EnvironmentObject private var userInfoDataModel: UserInfoData
    // 启动页数据
    @EnvironmentObject private var launchScreenData: LaunchScreenData

    /// 用于存储网络权限状态的状态变量，默认为需要连接状态
    @State private var networkAuthorizationStatus: NWPath.Status = .requiresConnection

    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .frame(width: 90, height: 90)
                .mask {
                    RoundedRectangle(cornerRadius: 29)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // 如果定位和网络权限都已授权，则跳转页面
            if
//                locationAuthorizationStatus == .authorizedWhenInUse || locationAuthorizationStatus == .authorizedAlways,
                networkAuthorizationStatus == .satisfied
            {
                print("授权了网络")
                self.goHome()
                return
            }

            print("没有授权")

            // 请求定位权限
//            CLLocationManager().requestWhenInUseAuthorization()

            // 请求网络权限
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                DispatchQueue.main.async {
                    self.networkAuthorizationStatus = path.status
                }
            }
            let queue = DispatchQueue(label: "NetworkMonitor")
            monitor.start(queue: queue)
        }
//        .onChange(of: locationAuthorizationStatus) {
//            // 如果定位权限已授权
//            if locationAuthorizationStatus == .authorizedWhenInUse || locationAuthorizationStatus == .authorizedAlways {
//                //                navigateRunView = true // 设置为 true，以触发导航到首页
//                print("定位授权改变")
//            }
//        }
        .onChange(of: networkAuthorizationStatus) {
            // 如果网络权限已授权
            if networkAuthorizationStatus == .satisfied {
                print("网络授权改变")
                self.goHome() // 跳转
            }
        }
    }

    /// 开始跳转首页
    private func goHome() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("准备跳转首页")
            launchScreenData.change()
        }
    }
}

#Preview {
    LaunchView()
        .environmentObject(LaunchScreenData())
}
