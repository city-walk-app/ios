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
    /// 打卡弹窗是否显示
    @State private var visibleSheet = false
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
    
//    private var region: MKCoordinateRegion {
//        MKCoordinateRegion(
//            center: CLLocationCoordinate2D(latitude: 34.011286, longitude: -116.166868),
//            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
//        )
//    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 地图
                Map(initialPosition: .region(region))
             
                // 头部和底部操作视图
                VStack {
                    // 头部操作栏
                    HStack(alignment: .top) {
                        NavigationLink(destination: MainView(user_id: "")) {
                            Circle()
                                .frame(width: 48, height: 48)
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(PlainButtonStyle()) // 移除默认的按钮样式
                            
                        Spacer()
                        
                        VStack {
                            // 设置按钮
                            NavigationLink(destination: LoginView()) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial) // 将毛玻璃效果作为填充色
                                    .frame(width: 42, height: 42)
                                    .overlay {
                                        Image(systemName: "gearshape")
                                            .resizable()
                                            .frame(width: 23, height: 23)
                                            .foregroundColor(.black)
                                    }
                            }
                            .buttonStyle(PlainButtonStyle()) // 移除默认的按钮样式
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial) // 将毛玻璃效果作为填充色
                                .frame(width: 42, height: 42 * 2)
                                .overlay {
                                    VStack(spacing: 0) {
                                        // 切换主题按钮
                                        Button {} label: {
                                            Image(systemName: "map")
                                                .resizable()
                                                .frame(width: 23, height: 23)
                                                .foregroundColor(.black)
                                        }
                                        .frame(width: 42, height: 42)
                                        
                                        // 回到当前位置按钮
                                        Button {} label: {
                                            Image(systemName: "paperplane")
                                                .resizable()
                                                .frame(width: 23, height: 23)
                                                .foregroundColor(.black)
                                        }
                                        .frame(width: 42, height: 42)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 8)) // 裁剪超出部分
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    // 底部功能
                    HStack(spacing: 12) {
                        VStack(spacing: 16) {
                            // 我的朋友
                            NavigationLink(destination: FriendsIView()) {
                                ZStack(alignment: .topLeading) {
                                    // 背景图片
                                    AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-friends.png")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 166, height: 98) // 设置按钮的大小
                                            .clipShape(RoundedRectangle(cornerRadius: 10)) // 裁剪为圆角矩形
                                    } placeholder: {
                                        Color.gray // 占位符颜色
                                            .frame(width: 166, height: 98) // 设置占位符的大小与背景图一致
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    
                                    // 左上角的文字
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("我的朋友")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("My Friends")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.top, 14)
                                    .padding(.leading, 16)
                                }
                                .buttonStyle(PlainButtonStyle()) // 移除默认的按钮样式
                            }
                            
                            // 邀请朋友
                            NavigationLink(destination: InviteView()) {
                                ZStack(alignment: .topLeading) {
                                    // 背景图片
                                    AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-invite.png")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 166, height: 98) // 设置按钮的大小
                                            .clipShape(RoundedRectangle(cornerRadius: 10)) // 裁剪为圆角矩形
                                    } placeholder: {
                                        Color.gray // 占位符颜色
                                            .frame(width: 166, height: 98) // 设置占位符的大小与背景图一致
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    
                                    // 左上角的文字
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("邀请朋友")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("City Walk Together")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.top, 14)
                                    .padding(.leading, 16)
                                }
                                .buttonStyle(PlainButtonStyle()) // 移除默认的按钮样式
                            }
                        }
                        
                        VStack(spacing: 12) {
                            // 地点打卡
                            Button {
                                self.visibleSheet.toggle()
                            } label: {
                                ZStack(alignment: .topLeading) {
                                    // 背景图片
                                    AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-record.png")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 166, height: 120) // 设置按钮的大小
                                            .clipShape(RoundedRectangle(cornerRadius: 10)) // 裁剪为圆角矩形
                                    } placeholder: {
                                        Color.gray // 占位符颜色
                                            .frame(width: 166, height: 120) // 设置占位符的大小与背景图一致
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    
                                    // 左上角的文字
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("打卡")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Record location")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.top, 14)
                                    .padding(.leading, 16)
                                }
                                .buttonStyle(PlainButtonStyle()) // 移除默认的按钮样式
                            }
                            
                            // 排行榜
                            NavigationLink(destination: RankingView()) {
                                ZStack(alignment: .topLeading) {
                                    // 背景图片
                                    AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-ranking.png")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 166, height: 76) // 设置按钮的大小
                                            .clipShape(RoundedRectangle(cornerRadius: 10)) // 裁剪为圆角矩形
                                    } placeholder: {
                                        Color.gray // 占位符颜色
                                            .frame(width: 166, height: 76) // 设置占位符的大小与背景图一致
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    
                                    // 左上角的文字
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("排行榜")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Ranking")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.top, 14)
                                    .padding(.leading, 16)
                                }
                                .buttonStyle(PlainButtonStyle()) // 移除默认的按钮样式
                            }
                        }
                    }
                }
            }
        }
        .background(.black)
        .sheet(isPresented: $visibleSheet) {
            Text("打卡")
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .onAppear {
            // 获取周边热门地点
//            self.getPopularLocations()
//            // 获取用户信息
            ////            self.loadUserInfo()
//            // 请求位置权限
//            self.requestLocationAuthorization()
//
//            Task {
//                await self.loadUserInfo()
//            }
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
//        .environmentObject(UserInfoData())
}
