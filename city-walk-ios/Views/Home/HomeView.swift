//
//  HomeView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/18.
//

import CoreLocation
import MapKit
import SwiftUI

/// 主视图，用于显示地图和操作选项
struct HomeView: View {
    /// API对象，用于进行网络请求
//    let API = Api()
    
    /// 控制图片选择路由的状态
    @State private var isImageSelectRouter = false
    /// 用户选择的图片
    @State private var seletImage: UIImage?
    /// 缓存信息
    let cacheInfo = UserCache.shared.getInfo()
    /// 底部选中的索引
    @State var selectedIndex = 0
    /// 用户输入的文字
    @State private var text = ""
    /// 控制打卡弹窗的显示状态
    @State private var isCurrentLocation = false
    /// 定位服务管理对象
    @State private var locationManager = CLLocationManager()
    /// 位置权限状态
    @State private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    /// 定位数据管理对象
    @StateObject private var locationDataManager = LocationDataManager()
    /// 用户信息数据模型
    @EnvironmentObject var userInfoDataModel: UserInfoData
    /// 地图区域
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30, longitude: 120),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    /// 颜色标签数组
    let colorTags = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.gray, Color.black]
    /// 标注列表
    @State private var landmarks: [Landmark] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 地图视图
                HomeMapView(region: $region, onRegionChange: getPopularLocations, landmarks: $landmarks)
                    .edgesIgnoringSafeArea(.all)
                
                // 头部和底部操作视图
                VStack {
                    HomeHeaderView()
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            NavigationLink(destination: InviteView()) {
                                Text("邀请朋友")
                                    .frame(height: 60)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 50)
                                    .background(.blue, in: RoundedRectangle(cornerRadius: 33))
                            }
//                            NavigationLink(destination: InviteView()) {
                            Text("地点打卡")
                                .frame(height: 60)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 50)
                                .background(.blue, in: RoundedRectangle(cornerRadius: 33))
//                            }
                        }
                        HStack {
                            NavigationLink(destination: FriendsIView()) {
                                Text("朋友列表")
                                    .frame(height: 60)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 50)
                                    .background(.blue, in: RoundedRectangle(cornerRadius: 33))
                            }
                            NavigationLink(destination: RankingView()) {
                                Text("排行榜")
                                    .frame(height: 60)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 50)
                                    .background(.blue, in: RoundedRectangle(cornerRadius: 33))
                            }
                        }
                    }
                    
//                    FooterView(
//                        isCurrentLocation: $isCurrentLocation,
//                        text: $text,
//                        colorTags: colorTags,
//                        seletImage: $seletImage,
//                        isImageSelectRouter: $isImageSelectRouter
//                    )
//                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .onAppear {
            // 获取周边热门地点
            self.getPopularLocations()
            // 获取用户信息
//            self.loadUserInfo()
            // 请求位置权限
            self.requestLocationAuthorization()
            
            Task {
                await self.loadUserInfo()
            }
        }
    }
    
    /// 获取周边热门地点
    private func getPopularLocations() {
        let longitude = "\(region.center.longitude)"
        let latitude = "\(region.center.latitude)"
        
//        API.getPopularLocations(params: ["longitude": longitude, "latitude": latitude]) { result in
//            switch result {
//            case .success(let data):
//                if data.code == 200 && data.data != nil {
//                    let list = data.data!
//                    let _landmarks = list.map { item in
//                        Landmark(coordinate: CLLocationCoordinate2D(latitude: Double(item.latitude), longitude: Double(item.longitude)), name: item.name)
//                    }
//                    self.landmarks = _landmarks
//                }
//            case .failure:
//                print("接口错误")
//            }
//        }
    }
    
    /// 获取用户信息
    private func loadUserInfo() async {
        if let value = cacheInfo?.user_id {
            let user_id = String(describing: value)
            do {
                let params = ["user_id": user_id] // 根据您的实际参数
                let res = try await Api.shared.getUserInfo(params: params)
                
                print("获取的用户信息", res)
                
                if res.code == 200 && res.data != nil {
//                    otherUserInfo = res.data!
                    userInfoDataModel.set(res.data!)
                }
            } catch {
                print("获取用户信息异常")
            }
        } else {
            print("身份信息不存在请登录")
        }
    }
    
    /// 请求获取位置权限
    private func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 打卡当前地点
    private func createPositionRecord(longitude: String, latitude: String) {
//        API.createPositionRecord(params: ["longitude": longitude, "latitude": latitude, "address": "地址", "name": "名字"]) { result in
//            switch result {
//            case .success(let data):
//                if data.code == 200 {
//                    isCurrentLocation.toggle()
//                }
//            case .failure:
//                print("获取失败")
//            }
//        }
    }
    
    /// 获取当前位置并打卡
    private func currentLocation() {
        requestLocationAuthorization()
        switch locationDataManager.locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            let longitude = "\(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "")"
            let latitude = "\(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "")"
            createPositionRecord(longitude: longitude, latitude: latitude)
        case .restricted, .denied:
            print("当前位置数据被限制或拒绝")
        case .notDetermined:
            print("正在获取位置信息...")
        default:
            print("未知错误")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserInfoData())
}
