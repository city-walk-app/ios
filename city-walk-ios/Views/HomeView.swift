//
//  HomeView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

/// https://developer.apple.com/documentation/corelocation/
import CoreLocation

// import PhotosUI
import SwiftUI

struct HomeView: View {
    let API = ApiBasic()
    
    /// 缓存信息
    let cacheInfo = UserCache.shared.getInfo()
    /// 底部选中的索引
    @State var selectedIndex = 0
    /// 这一刻的想法
    @State private var text = ""
    /// 是否显示打卡弹窗
    @State private var isCurrentLocation = false
    /// 用户信息
//    @State private var userInfo: UserInfo.UserInfoData?
    /// 定位服务相关
    @State private var locationManager = CLLocationManager()
    @State private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @StateObject private var locationDataManager = LocationDataManager()
    /// 用户信息数据
    @EnvironmentObject var userInfoDataModel: UserInfoData
    
    var body: some View {
        NavigationStack {
            VStack {
                // 头部信息
                HStack {
                    if userInfoDataModel.data == nil {
                        NavigationLink(destination: LoginView()) {
                            Image(systemName: "person")
                                .font(.system(size: 24))
                                .foregroundStyle(.black)
                        }
                    } else {
                        NavigationLink(destination: MainView(userId: cacheInfo!.id)) {
                            URLImage(url: URL(string: "\(BASE_URL)/\(userInfoDataModel.data!.avatar ?? "")")!)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .mask(Circle())
                        }
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: SettingView()) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 23))
                            .foregroundStyle(.black)
                    }
                }
                .padding()
                
                Spacer()
                
                Text("🌏")
                    .font(.system(size: 230))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(radius: 15)
                
                VStack {
                    NavigationLink(destination: RankingView()) {
                        Text("排行榜")
                    }
                    Button {
                        isCurrentLocation.toggle()
                    } label: {
                        Text("打卡当前地点")
                    }
                    .sheet(isPresented: $isCurrentLocation) {
                        VStack {
                            VStack {
                                HStack {
                                    Spacer()
                                        
                                    Button {
                                        isCurrentLocation.toggle()
                                    } label: {
                                        Image(systemName: "xmark.circle")
                                            .font(.system(size: 27))
                                            .foregroundStyle(.gray)
                                    }
                                }
                                    
                                VStack(alignment: .leading) {
                                    Text("当前位置")
                                        .font(.title)
                                        .bold()
                                    
                                    Text("\(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "Error loading")")
                                        .font(.title2)
                                       
                                    Text("\(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "Error loading")")
                                        .font(.title2)
                                      
                                    TextField("这一刻的想法？", text: $text)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                        
                                    Spacer()
                                }
                            }
                            
                            // 确认按钮
                            Button {
                                self.currentLocation()
                            } label: {
                                Spacer()
                                Text("就这样")
                                Spacer()
                            }
                            .frame(height: 50)
                            .foregroundStyle(.black.opacity(0.8))
                            .bold()
                            .background(.blue.opacity(0.07), in: RoundedRectangle(cornerRadius: 17))
                        }
                        .padding(20)
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        // 当视图出现时执行的方法
        .onAppear {
            self.loadUserInfo() // 获取用户信息
            self.requestLocationAuthorization() // 请求位置权限
        }
    }
    
    /// 获取用户信息
    private func loadUserInfo() {
        // 将 id 转换为字符串发送请求
        if let value = cacheInfo?.id {
            let id = String(describing: value)
            
            API.userInfo(params: ["id": id]) { result in
                
                switch result {
                case .success(let data):
                    if data.code == 200 && data.data != nil {
                        userInfoDataModel.set(data.data!)
                    }
                case .failure:
                    print("接口错误")
                }
            }
          
        } else {
            print("身份信息不存在")
        }
    }
    
    /// 请求获取位置权限
    private func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 打卡当前地点
    private func createPositionRecord(longitude: String, latitude: String) {
        print("获取到的参数\(longitude),\(latitude)")
        
        API.createPositionRecord(params:
            [
                "longitude": longitude,
                "latitude": latitude,
                "address": "地址",
                "name": "名字",
            ]
        ) { result in
            switch result {
            case .success(let data):
                print("打卡成功", data)
                
                if data.code == 200 {
                    isCurrentLocation.toggle()
                }
            case .failure:
                print("获取失败")
            }
        }
    }
    
    /// 点击再次获取当前位置信息
    private func currentLocation() {
        requestLocationAuthorization()
        
        switch locationDataManager.locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            
            let longitude: String = "\(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "")"
            let latitude: String = "\(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "")"
           
            createPositionRecord(longitude: longitude, latitude: latitude)
        case .restricted,
             .denied:
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
