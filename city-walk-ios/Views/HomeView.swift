//
//  HomeView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/18.
//

import CoreLocation
import MapKit
import SwiftUI

struct RouteDetailForm {
    var route_id: String
    var content: String
    var travel_type: String
    var mood_color: String
    var address: String
    var picture: [String]
}

struct MoodColor {
    var color: String
    var borderColor: String
    var key: String
    var type: String
}

/// 主视图，用于显示地图和操作选项
struct HomeView: View {
    /// 缓存信息
    let cacheInfo = UserCache.shared.getInfo()
    /// 打卡弹窗是否显示
    @State private var visibleSheet = true
    /// 定位服务管理对象
    @State private var locationManager = CLLocationManager()
    /// 位置权限状态
    @State private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    /// 定位数据管理对象
    @StateObject private var locationDataManager = LocationDataManager()
    /// 用户信息数据模型
//    @EnvironmentObject var userInfoDataModel: UserInfoData
    /// 地图区域
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30, longitude: 120),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    /// 心情颜色
    let moodColors: [MoodColor] = [
        MoodColor(color: "#f16a59", borderColor: "#ef442f", key: "EXCITED", type: "兴奋的"),
        MoodColor(color: "#f6a552", borderColor: "#f39026", key: "ENTHUSIASTIC", type: "热情的"),
        MoodColor(color: "#fad35c", borderColor: "#fac736", key: "HAPPY", type: "快乐的"),
        MoodColor(color: "#74cd6d", borderColor: "#50c348", key: "RELAXED", type: "放松的"),
        MoodColor(color: "#4a8cf9", borderColor: "#1d6ff8", key: "CALM", type: "平静的"),
        MoodColor(color: "#af72dc", borderColor: "#9b4fd3", key: "MYSTERIOUS", type: "神秘的"),
        MoodColor(color: "#9b9ca0", borderColor: "#838387", key: "NEUTRAL", type: "中性的"),
    ]
    /// 说点什么输入框
    @State private var content = ""
    /// 用户的身份信息
    @State private var userInfo: UserInfoType?
    /// 打卡详情
    @State private var routeDetailForm = RouteDetailForm(
        route_id: "",
        content: "",
        travel_type: "",
        mood_color: "",
        address: "",
        picture: []
    )
    /// 心情颜色选中的配置
    @State private var moodColorActive: MoodColor?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 地图
                Map(initialPosition: .region(region))
             
                // 头部和底部操作视图
                VStack {
                    // 头部操作栏
                    HStack(alignment: .top) {
                        if let userInfo = cacheInfo {
                            NavigationLink(destination: MainView(user_id: userInfo.user_id)) {
                                if let avatar = userInfo.avatar,
                                   let url = URL(string: avatar)
                                {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 48, height: 48) // 设置图片的大小
                                            .clipShape(Circle()) // 将图片裁剪为圆形
                                    } placeholder: {
                                        // 占位符，图片加载时显示的内容
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 48, height: 48) // 占位符的大小与图片一致
                                            .overlay(Text("加载失败").foregroundColor(.white))
                                    }
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 48, height: 48)
                                        .overlay(Text("无头像").foregroundColor(.white))
                                }
                            }
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 48, height: 48)
                                .overlay(Text("没有登录信息").foregroundColor(.white))
                        }
                            
                        Spacer()
                        
                        VStack {
                            // 设置按钮
                            NavigationLink(destination: SettingView()) {
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
                                self.onRecord()
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
            VStack {
                // 省份图
                AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/provinces/330000.png")) { image in
                    image
                        .resizable()
                        .frame(width: 154, height: 154)
                } placeholder: {}
                
                Text("再获得100经验版图将会升温版图")
                    .foregroundStyle(Color(hex: "#333333"))
                    .padding(.top, 9)
                    .font(.system(size: 14))
                
                Text("表单内容：\(routeDetailForm)")
                
                VStack(spacing: 0) {
                    // 发布瞬间
                    VStack {
                        AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/record-succese-camera.png")) { image in
                            image
                                .resizable()
                                .frame(width: 69, height: 64)
                        } placeholder: {}
                        
                        Button {} label: {
                            Text("发布瞬间")
                                .padding(.vertical, 9)
                                .padding(.horizontal, 48)
                                .foregroundStyle(.white)
                                .background(Color(hex: "#F3943F"))
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    // 选择心情颜色
                    HStack {
                        if let moodColorActive = moodColorActive {
                            Button {
                                self.moodColorActive = nil
                                self.routeDetailForm.mood_color = ""
                            } label: {
                                Circle()
                                    .fill(Color(hex: moodColorActive.color))
                                    .frame(width: 37, height: 37)
                                    .overlay(
                                        Circle()
                                            .stroke(Color(hex: moodColorActive.borderColor), lineWidth: 1) // 圆形边框
                                    )
                            }
                          
                        } else {
                            ForEach(self.moodColors, id: \.key) { item in
                                Button {
                                    self.moodColorActive = item
                                    self.routeDetailForm.mood_color = item.key
                                } label: {
                                    Circle()
                                        .fill(Color(hex: item.color))
                                        .frame(width: 37, height: 37)
                                        .overlay(
                                            Circle()
                                                .stroke(Color(hex: item.borderColor), lineWidth: 1) // 圆形边框
                                        )
                                }
                            }
                        }
                    }
                    .padding(.top, 16)
                    
                    // 选择当前位置
                    Text("选择当前位置")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.top, 25)
                    
                    // 选择当前位置
                    TextEditor(text: $routeDetailForm.content)
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.top, 25)
                        .onAppear {
                            UITextView.appearance().backgroundColor = .clear
                        }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .padding(.top, 16)
                
                Spacer()
                
                HStack {
                    Button {
                        self.visibleSheet.toggle()
                    } label: {
                        Text("取消")
                            .frame(width: 160, height: 48)
                            .font(.system(size: 16))
                            .foregroundStyle(Color(hex: "#F3943F"))
                            .background(Color(hex: "#ffffff"))
                            .border(Color(hex: "#F3943F"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: "#F3943F"), lineWidth: 1) // 使用 overlay 添加圆角边框
                            )
                    }
                    
                    Button {
                        Task {
                            await self.updateRouteDetail() // 完善步行打卡记录详情
                        }
                    } label: {
                        Text("就这样")
                            .frame(width: 160, height: 48)
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                            .background(Color(hex: "#F3943F"))
                            .border(Color(hex: "#F3943F"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: "#F3943F"), lineWidth: 1) // 使用 overlay 添加圆角边框
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 61)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .onAppear {
            Task {
                await self.getLocationPopularRecommend() // 获取周边热门地点
            }
        }
    }
    
    /// 获取周边热门地点
    private func getLocationPopularRecommend() async {
        let longitude = "\(region.center.longitude)"
        let latitude = "\(region.center.latitude)"

        do {
            let res = try await Api.shared.getLocationPopularRecommend(params: [
                "longitude": longitude,
                "latitude": latitude,
            ])
            
            print("获取周边热门地点", res)
            
            if res.code == 200 && res.data != nil {
                let list = res.data!
//                let _landmarks = list.map { item in
//                    Landmark(coordinate: CLLocationCoordinate2D(latitude: Double(item.latitude), longitude: Double(item.longitude)), name: item.name)
//                }
//                landmarks = _landmarks
            }
        } catch {
            print("获取周边热门地点异常")
        }
    }
    
    /// 完善步行打卡记录详情
    private func updateRouteDetail() async {
        do {
            let res = try await Api.shared.updateRouteDetail(params: [:])
            
            print("完善记录详情", res)
            
            if res.code == 200 {
                visibleSheet.toggle()
            }
            
        } catch {
            print("完善步行打卡记录详情异常")
        }
    }
    
    /// 获取用户信息
    private func getUserInfo() async {
        do {
            guard cacheInfo != nil else {
                return
            }
            let res = try await Api.shared.getUserInfo(params: ["user_id": cacheInfo!.user_id])

            print("我的页面获取的用户信息", res)

            if res.code == 200 && res.data != nil {
                userInfo = res.data!
            }
        } catch {
            print("获取用户信息异常")
        }
    }
    
    /// 打卡当前地点
    private func locationCreateRecord(longitude: String, latitude: String) async {
        do {
            let res = try await Api.shared.locationCreateRecord(params: [
                "longitude": longitude,
                "latitude": latitude,
            ])
            
            print("打卡当前地点", res)
            
            if res.code == 200 && res.data != nil {
                visibleSheet.toggle()
            }
        } catch {
            print("打卡当前地点异常")
        }
    }
    
    /// 请求获取位置权限
    private func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 获取当前位置并打卡
    private func onRecord() {
        requestLocationAuthorization() // 请求获取位置权限
        
        switch locationDataManager.locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            let longitude = "\(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "")"
            let latitude = "\(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "")"

            Task {
                await locationCreateRecord(longitude: longitude, latitude: latitude)
            }
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
