//
//  LaunchView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/1.
//

// import CoreLocation
import Network
import SwiftUI

struct LaunchView: View {
//    let API = Api()

    /// 用于存储定位权限状态的状态变量，默认为未确定状态
//    @State private var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    /// 用于存储网络权限状态的状态变量，默认为需要连接状态
    @State private var networkAuthorizationStatus: NWPath.Status = .requiresConnection
    /// 缓存信息
    private let cacheInfo = UserCache.shared.getInfo()
    /// 用户信息数据
    /// 通过 @EnvironmentObject 获取全局的 UserInfoData 对象
    @EnvironmentObject var userInfoDataModel: UserInfoData
//    @EnvironmentObject var globalDataModel: GlobalData
    @EnvironmentObject var LaunchScreenDataModel: LaunchScreenData

    var body: some View {
        NavigationStack {
            VStack {
                // logo 和标题
                VStack {
                    Image("logo")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .mask {
                            Circle()
                        }

                    Text("城市漫步 CityWalk")
                        .font(.title3)
                        .bold()
                        .padding(.top, 27)
                }

                Spacer()

                // 底部内容
                Text("记录你走过的每个地方")
                    .font(.system(size: 14))
                    .foregroundStyle(.black.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 100)
            .padding(.bottom, 40)
        }
        .toolbar(.hidden)
        .ignoresSafeArea(.all)
        .navigationBarHidden(true) // 隐藏导航栏
        .onAppear {
            print("进入启动页面")

            self.loadUserInfo() // 获取用户信息
            self.experienceRanking() // 获取经验排行榜
            self.getRouteList() // 获取指定用户去过的省份

            // 如果定位和网络权限都已授权，则跳转页面
            if
//                locationAuthorizationStatus == .authorizedWhenInUse || locationAuthorizationStatus == .authorizedAlways,
                networkAuthorizationStatus == .satisfied
            {
                print("授权了网络")
                self.checkPermissionsAndNavigate()
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
                self.checkPermissionsAndNavigate() // 跳转
            }
        }
    }

    /// 获取用户信息
    private func loadUserInfo() {
        // 将 id 转换为字符串发送请求
//        if let value = cacheInfo?.id {
//            let id = String(describing: value)
//
//            API.userInfo(params: ["id": id]) { result in
//                switch result {
//                case .success(let data):
//                    if data.code == 200 && data.data != nil {
//                        userInfoDataModel.set(data.data!)
//                    }
//                case .failure:
//                    print("接口错误")
//                }
//            }
//
//        } else {
//            print("身份信息不存在")
//        }
    }

    /// 获取经验排行榜
    private func experienceRanking() {
//        API.experienceRanking(params: ["province_code": "330000"]) { result in
//            switch result {
//            case .success(let data):
//                if data.code == 200 && (data.data?.isEmpty) != nil {
//                    self.globalDataModel.setRankingData(data.data!)
//                }
//            case .failure:
//                print("获取失败")
//            }
//        }
    }

    /// 获取指定用户去过的省份
    private func getRouteList() {
//        API.getRouteList(params: ["page": "1", "page_size": "20"]) { result in
//            switch result {
//            case .success(let data):
//                if data.code == 200 && ((data.data?.isEmpty) != nil) {
//                    globalDataModel.setRouterData(data.data!)
//                }
//            case .failure:
//                print("获取失败")
//            }
//        }
    }

    /// 开始跳转首页
    private func checkPermissionsAndNavigate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("准备跳转首页")
            LaunchScreenDataModel.change()
        }
    }
}

#Preview {
    LaunchView()
        .environmentObject(UserInfoData())
//        .environmentObject(GlobalData())
        .environmentObject(LaunchScreenData())
        .environmentObject(FriendsData())
}
