//
//  HomeView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

/// https://developer.apple.com/documentation/corelocation/
import CoreLocation
import MapKit

// import PhotosUI
import SwiftUI

struct HomePhotoView: View {
    /// 选择的头像图片
    @State private var isShowAvatarSelectSheet = false
    @Binding var seletImage: UIImage?
    @Binding var isActive: Bool
    
    var body: some View {
        ImagePicker(selectedImage: $seletImage, isImagePickerPresented: $isShowAvatarSelectSheet) {
            if let image = seletImage {
                self.seletImage = image
                // 返回上一层
                self.isActive = false
            }
        }
    }
}

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: HomeMapView
    
    init(parent: HomeMapView) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // 地图区域变化后的事件处理
        parent.region = mapView.region
        
        // getPopularLocations
        
        // 调用传递的闭包
        parent.onRegionChange?()
        
//        parent.getPopularLocations()
        print("地图区域变化：\(mapView.region.center.latitude), \(mapView.region.center.longitude)")
    }
}

struct HomeMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var onRegionChange: (() -> Void)? // 闭包属性
    @Binding var landmarks: [Landmark]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations) // 移除旧的标注
        let annotations = landmarks.map { landmark in
            let annotation = MKPointAnnotation()
            annotation.coordinate = landmark.coordinate
            annotation.title = landmark.name
            return annotation
        }
        uiView.addAnnotations(annotations) // 添加新的标注
    }
}

struct HomeView: View {
    let API = ApiBasic()
    
    @State private var isImageSelectRouter = false
    /// 选择的图片
    @State private var seletImage: UIImage?
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
    @State private var region = MKCoordinateRegion(
        // 地图的中心坐标
        center: CLLocationCoordinate2D(latitude: 30, longitude: 120),
        // 地图显示区域的范围
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    /// 颜色标签
    let colorTags = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.gray, Color.black]
    /// 推荐的地点
//    @State private var popularLocations: [GetPopularLocations.GetPopularLocationsData]?
    // 标注列表
    @State private var landmarks: [Landmark] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 地图
//                Map(coordinateRegion: $region, annotationItems: landmarks) { landmark in
//                    // 为每个地标创建标注视图
//                    MapAnnotation(coordinate: landmark.coordinate) {
//                        VStack {
//                            Text("🔥")
//                                .font(.system(size: 20))
//                        }
//                    }
//                }
                HomeMapView(region: $region, onRegionChange: getPopularLocations, landmarks: $landmarks)
                    .edgesIgnoringSafeArea(.all) // 忽略安全区域边界
//                .onMapCameraChange(frequency: .continuous) { context in
//                    // 地图相机位置变化时获取新的经纬度
//                    let newCenter = context.region.center
//                    let currentLatitude = newCenter.latitude
//                    let currentLongitude = newCenter.longitude
//
//                    print("Latitude: \(currentLatitude), Longitude: \(currentLongitude)")
//                    print(context) // 调试信息
//                }
//                Map(initialPosition: .region(region), annotationItems: landmark)
                
                // 操作选项
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
                    
                    HStack {
                        // 打卡当前地点
                        Button {
                            self.isCurrentLocation.toggle()
                        } label: {
                            Text("打卡当前地点")
                                .frame(height: 60)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 50)
                                .background(.blue, in: RoundedRectangle(cornerRadius: 33))
                        }
                        .padding(.trailing, 16)
                        .sheet(isPresented: $isCurrentLocation) {
                            NavigationView {
                                VStack {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            
                                            Button {
                                                self.isCurrentLocation.toggle()
                                            } label: {
                                                Image(systemName: "xmark.circle")
                                                    .font(.system(size: 27))
                                                    .foregroundStyle(.gray)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text("颜色标签")
                                            
                                            HStack {
                                                ForEach(colorTags.indices, id: \.self) { index in
                                                    Circle()
                                                        .fill(colorTags[index])
                                                        .frame(width: 20, height: 20)
                                                }
                                            }
                                            
                                            Text("这一刻的想法")
                                            
                                            TextField("这一刻的想法？", text: $text)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                
                                            Text("选择当前的照片")
                                            
                                            NavigationLink(
                                                destination: HomePhotoView(seletImage: $seletImage, isActive: $isImageSelectRouter),
                                                isActive: $isImageSelectRouter
                                            ) {
                                                Button {
                                                    self.isImageSelectRouter = true
                                                } label: {
                                                    if let image = self.seletImage {
                                                        Image(uiImage: image)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 200, height: 200)
                                                    } else {
                                                        Rectangle()
                                                            .fill(.gray.opacity(0.1))
                                                            .frame(width: 200, height: 200)
                                                            .overlay {
                                                                Image(systemName: "photo")
                                                            }
                                                    }
                                                }
                                            }
                                            
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
                                    .foregroundStyle(.white)
                                    .bold()
                                    .background(.blue, in: RoundedRectangle(cornerRadius: 30))
                                }
                                .padding(20)
                            }
                        }
                        
                        // 跳转排行榜
                        NavigationLink(destination: RankingView()) {
                            Circle()
                                .frame(width: 60, height: 60)
                                .overlay {
                                    Image(systemName: "list.star")
                                        .foregroundStyle(.white)
                                        .font(.title2)
                                }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        // 当视图出现时执行的方法
        .onAppear {
//            print("123")
            self.getPopularLocations() // 获取周边热门地点
            self.loadUserInfo() // 获取用户信息
            self.requestLocationAuthorization() // 请求位置权限
        }
    }
    
    /// 获取周边热门地点
    private func getPopularLocations() {
//        let longitude = "\(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "")"
//        let latitude = "\(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "")"
            
        let longitude = "\(region.center.longitude)"
        let latitude = "\(region.center.latitude)"
        
        print("获取周边热门地", longitude, latitude)
            
//        API.getPopularLocations(params: ["longitude": "120", "latitude": "30"]) { result in
        API.getPopularLocations(params: ["longitude": longitude, "latitude": latitude]) { result in
//                print("799")
            switch result {
            case .success(let data):
                if data.code == 200 && data.data != nil {
                    //                    print("ddata", data.data)
                       
                    let list = data.data!
                    
                    print(list)

                    let _landmarks = list.map { item in
                        Landmark(coordinate: CLLocationCoordinate2D(latitude: Double(item.latitude), longitude: Double(item.longitude)), name: item.name)
                    }
                        
//                        print("数据", _landmarks)
                        
                    //                    self.popularLocations = data.data!
                    self.landmarks = _landmarks
                }
            case .failure:
                print("接口错误")
            }
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
