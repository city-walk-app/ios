//
//  HomeView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/18.
//

import Combine
import CoreLocation
import Kingfisher
import MapKit
import SwiftUI

/// 心情颜色
private let moodColorList = moodColors
/// 最多选择的照片数量
private let pictureMaxCount = 2
/// 经度偏移量
private let longitudeOffset = 0.00428
/// 纬度偏移量
private let latitudeOffset = -0.00294

/// 主视图，用于显示地图和操作选项
struct HomeView: View {
    /// loading 数据
    @EnvironmentObject private var loadingData: LoadingData
    /// 首页数据
    @EnvironmentObject private var homeData: HomeData
    /// 缓存数据
    @EnvironmentObject private var storageData: StorageData
    
    /// 定位数据管理对象
    @StateObject private var locationDataManager = LocationDataManager()
    /// 定位服务管理对象
    private var locationManager = CLLocationManager()

    /// 打卡弹窗是否显示
    @State private var visibleSheet = false
    /// 是否显示选择的菜单
    @State private var visibleActionSheet = false
 
    /// 位置权限状态
    @State private var authorizationStatus: CLAuthorizationStatus = .notDetermined
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
    /// 打卡信息详情
    @State private var recordDetail: LocationCreateRecordType.LocationCreateRecordData? = nil
    /// 键盘高度
    @State private var keyboardHeight: CGFloat = 0
    /// 是否显示全屏对话框
    @State private var visibleFullScreenCover = false
    /// 选择的图片文件列表
    @State private var selectedImages: [UIImage] = []
    /// 用户位置
//    @State private var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    /// 是否显示朋友邀请确认框
    @State private var isShowFriendInviteAlert = false
    /// 朋友申请信息
    @State private var friendInviteDetail: GetFriendInviteInfoType.GetFriendInviteInfoData?
    /// 朋友邀请 id
    @State private var invite_id: String?
    /// 是否显示卫星地图
    @State private var isSatelliteMap = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 地图
                Map(coordinateRegion: $homeData.region, showsUserLocation: true, annotationItems: homeData.landmarks ?? []) { landmark in
                    MapAnnotation(coordinate: landmark.coordinate) {
                        HomeLandmarkView(landmark: landmark, storageData: storageData)
                    }
                }
                .ignoresSafeArea(.all) // 忽略安全区域边缘
                .mapStyle(isSatelliteMap ? .hybrid : .standard)
                .onAppear {
                    if var currentLocation = locationManager.location?.coordinate {
                        currentLocation.latitude = currentLocation.latitude + latitudeOffset
                        currentLocation.longitude = currentLocation.longitude + longitudeOffset
                        
                        // SwiftUI 期望这些变化是在主线程上完成的
                        DispatchQueue.main.async {
                            homeData.region.center = currentLocation
                            homeData.userLocation = currentLocation // 更新 location 为当前用户位置
                        }
                    }
                }
                
                // 头部和底部操作视图
                VStack {
                    // 头部操作栏
                    HomeHeaderView(storageData: storageData, isSatelliteMap: $isSatelliteMap)
                
                    Spacer()
                    
                    // 底部卡片
                    HomeBottomCardsView(onRecord: self.onRecord)
                }
                .ignoresSafeArea(.all, edges: .bottom)
                
                // loading 组件
                Loading()
            }
            .overlay(alignment: .top) {
                VariableBlurView(maxBlurRadius: 12)
                    .frame(height: topSafeAreaInsets)
                    .ignoresSafeArea()
                    .zIndex(20)
            }
        }
        // 打卡的对话框
        .sheet(isPresented: $visibleSheet, onDismiss: { clearStepFormData() }) {
            HomeRecordSheetView(
                recordDetail: $recordDetail,
                selectedImages: $selectedImages,
                visibleActionSheet: $visibleActionSheet,
                visibleFullScreenCover: $visibleFullScreenCover,
                visibleSheet: $visibleSheet,
                routeDetailForm: $routeDetailForm,
                moodColorActive: $moodColorActive,
                keyboardHeight: $keyboardHeight,
                homeData: homeData,
                updateRouteDetail: updateRouteDetail
            )
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .alert(isPresented: $isShowFriendInviteAlert) {
            Alert(
                title: Text("提示"),
                message: Text("\(friendInviteDetail?.name ?? "")申请加你为好友，你同意吗？"),
                primaryButton: .destructive(Text("确定"), action: {
                    Task {
                        await self.friendConfirmInvite()
                    }
                }),
                secondaryButton: .cancel(Text("取消"))
            )
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }

            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                keyboardHeight = 0
            }

            Task {
                await self.getUserInfo() // 获取用户信息
                await homeData.getTodayRecord() // 获取今天的打卡记录
            }

            self.readClipboard() // 读取剪贴板
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
//        // 退出到桌面返回执行
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
//            self.readClipboard() // 读取剪贴板
//
//            Task {
//                await self.getUserInfo() // 获取用户信息
//                await homeData.getTodayRecord() // 获取今天的打卡记录
//            }
//        }
    }
    
    /// 同意好友申请
    private func friendConfirmInvite() async {
        guard let invite_id = invite_id else {
            return
        }
        
        do {
            let res = try await Api.shared.friendConfirmInvite(params: ["invite_id": invite_id])
            
            print("同意好友请求返回值", res)
            
            if res.code == 200 {
                print("同意成功")
            }
        } catch {
            print("同意好友申请异常")
        }
    }
    
    /// 读取剪贴板
    private func readClipboard() {
        // 读取剪贴板中的文本内容
        if let clipboardText = UIPasteboard.general.string {
            print("剪贴板内容: \(clipboardText)")
            invite_id = clipboardText
            Task {
                await getFriendInviteInfo()
            }
        } else {
            print("剪贴板中没有文本内容")
        }
    }
    
    /// 获取邀请详情
    func getFriendInviteInfo() async {
        guard let invite_id = invite_id else {
            return
        }

        do {
            let res = try await Api.shared.getFriendInviteInfo(params: ["invite_id": invite_id])
            
            print("邀请详情", res)
            
            guard res.code == 200, let data = res.data else {
                return
            }
            
            friendInviteDetail = data
            isShowFriendInviteAlert.toggle()
        } catch {
            print("获取邀请详情异常")
        }
    }
    
    /// 清除打卡对话框内容
    private func clearStepFormData() {
        routeDetailForm = RouteDetailForm(
            route_id: "",
            content: "",
            travel_type: "",
            mood_color: "",
            address: "",
            picture: []
        )
        
        recordDetail = nil
        moodColorActive = nil
        selectedImages = []
    }
    
    /// 隐藏键盘
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// 完善步行打卡记录详情
    private func updateRouteDetail() async {
        if routeDetailForm.route_id.isEmpty {
            return
        }
        
        do {
            loadingData.showLoading(options: LoadingParams(title: "提交中..."))
            
            // 有选择照片
            if !selectedImages.isEmpty {
                let uploadedImageURLs = await uploadImages(images: selectedImages)
                
                print("上传图片的结果", uploadedImageURLs)
                
                routeDetailForm.picture = uploadedImageURLs
            }
            
            let res = try await Api.shared.updateRouteDetail(params: [
                "route_id": routeDetailForm.route_id,
                "content": routeDetailForm.content,
                "travel_type": routeDetailForm.travel_type,
                "mood_color": routeDetailForm.mood_color,
                "address": routeDetailForm.address,
                "picture": routeDetailForm.picture,
                "longitude": routeDetailForm.longitude ?? "",
                "latitude": routeDetailForm.latitude ?? "",
            ])
            
            loadingData.hiddenLoading()
            
            print("完善记录详情", res)
            
            if res.code == 200 {
                visibleSheet.toggle()
                
                await homeData.getTodayRecord() // 获取今天的打卡记录
                clearStepFormData() // 清空表单
            }
            
        } catch {
            print("完善步行打卡记录详情异常")
            loadingData.hiddenLoading()
        }
    }
    
    /// 获取用户信息
    private func getUserInfo() async {
        guard storageData.userInfo != nil else {
            return
        }
        
        do {
            let res = try await Api.shared.getUserInfo(params: ["user_id": storageData.userInfo!.user_id])

            print("我的页面获取的用户信息", res)
            
            guard res.code == 200, let data = res.data else {
                return
            }

            userInfo = data
            storageData.saveUserInfo(info: data)
        } catch {
            print("获取用户信息异常")
        }
    }
    
    /// 打卡当前地点
    private func locationCreateRecord(longitude: String, latitude: String) async {
        do {
            loadingData.showLoading(options: LoadingParams(title: "打卡中..."))
            
            let res = try await Api.shared.locationCreateRecord(params: [
                "longitude": longitude,
                "latitude": latitude,
            ])
            
            loadingData.hiddenLoading()
            
            print("打卡结果", res)

            guard res.code == 200, let data = res.data else {
                return
            }
            
            recordDetail = data
                
            recordDetail!.province_url = data.province_code != nil
                ? "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/provinces/\(data.province_code!).png"
                : nil
                
            routeDetailForm.route_id = data.route_id
                
            visibleSheet.toggle() // 打开对话框
           
        } catch {
            print("打卡当前地点异常")
            loadingData.hiddenLoading()
        }
    }
    
    /// 获取当前位置并打卡
    private func onRecord() async {
        locationDataManager.checkLocationAuthorization()
        
        // 获取经纬度的字符串描述
        if let location = locationDataManager.locationManager.location {
            let longitudeString = location.coordinate.longitude.description
            let latitudeString = location.coordinate.latitude.description
            
            // 安全地将字符串转换为 Double
            if let longitude = Double(longitudeString),
               let latitude = Double(latitudeString)
            {
                let lon = longitude + longitudeOffset
                let lat = latitude + latitudeOffset
                
                print("打卡当前经纬度", lon, lat)
                
                await locationCreateRecord(longitude: "\(lon)", latitude: "\(lat)") // 打卡当前地点
            } else {
                print("经度或纬度转换失败")
            }
        } else {
            print("无法获取位置数据")
        }
    }
}

/// 首页地图标点
private struct HomeLandmarkView: View {
    /// 地图标点
    var landmark: Landmark
    /// 缓存数据
    var storageData: StorageData
    
    var body: some View {
        // 标点
        if landmark.type == .record {
            VStack(spacing: 3) {
                KFImage(homeMarkers)
                    .placeholder {
                        Color.clear
                            .frame(width: 50, height: 64)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 64)
        
                if let picture = landmark.picure, !picture.isEmpty {
                    ForEach(picture, id: \.self) { item in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("background-1"))
                            .frame(width: 90, height: 90)
                            .overlay {
                                KFImage(URL(string: item))
                                    .resizable()
                                    .frame(width: 82, height: 82)
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .clipped()
                            }
                            .shadow(radius: 5)
                    }
                }
            }
        }
        // 用户位置
        else if landmark.type == .user {
            if let userInfo = storageData.userInfo {
                if let avatar = userInfo.avatar,
                   let url = URL(string: avatar)
                {
                    KFImage(url)
                        .placeholder {
                            Circle()
                                .fill(skeletonBackground)
                                .frame(width: 53, height: 53)
                                .shadow(radius: 10)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 53, height: 53)
                        .clipShape(
                            Circle()
                        )
                }
            }
        }
    }
}

// 打卡 sheet 对话框内容
private struct HomeRecordSheetView: View {
    /// 打卡信息详情
    @Binding var recordDetail: LocationCreateRecordType.LocationCreateRecordData?
    /// 选择的图片文件列表
    @Binding var selectedImages: [UIImage]
    /// 是否显示选择的菜单
    @Binding var visibleActionSheet: Bool
    /// 是否显示全屏对话框
    @Binding var visibleFullScreenCover: Bool
    /// 打卡弹窗是否显示
    @Binding var visibleSheet: Bool
    /// 打卡详情
    @Binding var routeDetailForm: RouteDetailForm
    /// 心情颜色选中的配置
    @Binding var moodColorActive: MoodColor?
    /// 键盘高度
    @Binding var keyboardHeight: CGFloat
    /// 首页数据
    var homeData: HomeData
    /// 完善步行打卡记录详情
    var updateRouteDetail: () async -> Void

    /// 推荐的地址列表
    @State private var addressList: [GetAroundAddressType.GetAroundAddressData] = []
    /// 全屏弹窗显示的类型
    @State private var fullScreenCoverType: FullScreenCoverType = .picture
    
    var body: some View {
        ZStack {
            VStack {
                // 省份图
                if let recordDetail = self.recordDetail {
                    // 省份图
                    if let province_url = recordDetail.province_url {
                        // 省份图
                        Color.clear
                            .frame(width: 154, height: 154) // 保持原有的尺寸但设置为透明
                            .background(
                                Color(hex: recordDetail.background_color ?? "#F3943F")
                                    .mask {
                                        KFImage(URL(string: province_url))
                                            .placeholder {
                                                Color.clear
                                            }
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    }
                            )
                    }
                    
                    // 文案
                    Text("\(recordDetail.content ?? "当前地点打卡成功")")
                        .foregroundStyle(Color(hex: recordDetail.background_color ?? "#F3943F"))
                        .padding(.top, 9)
                        .font(.system(size: 16))
                        .bold()
                }
                
                VStack(spacing: 0) {
                    HStack {
                        // 一张照片都没选择
                        if selectedImages.count == 0 || selectedImages.isEmpty {
                            // 发布瞬间
                            Button {
                                self.fullScreenCoverType = .picture
                                self.visibleFullScreenCover.toggle()
                            } label: {
                                VStack {
                                    KFImage(recordSucceseCamera)
                                        .placeholder {
                                            Color.clear
                                                .frame(width: 69, height: 64)
                                        }
                                        .resizable()
                                        .frame(width: 69, height: 64)

                                    Text("发布瞬间")
                                        .padding(.vertical, 9)
                                        .padding(.horizontal, 48)
                                        .foregroundStyle(.white)
                                        .background(Color(hex: "#F3943F"))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        // 选择了一张照片
                        else if selectedImages.count == 1 {
                            let columns = [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                            ]

                            LazyVGrid(columns: columns) {
                                Image(uiImage: selectedImages[0])
                                    .resizable()
                                    .frame(height: 134)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .onLongPressGesture {
                                        visibleActionSheet.toggle()
                                    }

                                Button {
                                    self.fullScreenCoverType = .picture
                                    self.visibleFullScreenCover.toggle()
                                } label: {
                                    KFImage(recordSucceseCamera)
                                        .placeholder {
                                            Color.clear
                                                .frame(width: 69, height: 64)
                                        }
                                        .resizable()
                                        .frame(width: 69, height: 64)
                                }
                            }
                        }
                        // 选择了两张照片
                        else if selectedImages.count == 2 {
                            let columns = [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                            ]

                            LazyVGrid(columns: columns) {
                                ForEach(selectedImages, id: \.self) { item in
                                    Image(uiImage: item)
                                        .resizable()
                                        .frame(height: 134)
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .onLongPressGesture {
                                            visibleActionSheet.toggle()
                                        }
                                }
                            }
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [Color(hex: "#FFF2D1"), Color(hex: "#ffffff")]
                            ),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color(hex: "#9F9F9F").opacity(0.4), radius: 4.4, x: 0, y: 1)
                    // 选择照片的全屏弹出对话框
                    .fullScreenCover(isPresented: $visibleFullScreenCover, content: {
                        HomeRecordSheetFullScreenCoverView(
                            fullScreenCoverType: $fullScreenCoverType,
                            selectedImages: $selectedImages,
                            addressList: $addressList,
                            visibleFullScreenCover: $visibleFullScreenCover,
                            routeDetailForm: $routeDetailForm
                        )
                    })
                    .actionSheet(isPresented: $visibleActionSheet) {
                        ActionSheet(
                            title: Text("选择操作"),
                            message: Text("请选择你要执行的操作"),
                            buttons: [
                                .default(Text("重新选择")) {},
                                .default(Text("删除")) {},
                                .cancel(),
                            ]
                        )
                    }

                    // 选择心情颜色
                    HStack {
                        if let moodColorActive = moodColorActive {
                            Button {
                                withAnimation {
                                    self.moodColorActive = nil
                                    self.routeDetailForm.mood_color = ""
                                }
                            } label: {
                                Circle()
                                    .fill(Color(hex: moodColorActive.color))
                                    .frame(width: 37, height: 37)
                                    .overlay(
                                        Circle()
                                            .stroke(Color(hex: moodColorActive.borderColor), lineWidth: 1) // 圆形边框
                                    )

                                Text(moodColorActive.type)
                                    .foregroundStyle(Color(hex: moodColorActive.color))
                                    .font(.system(size: 18))
                                    .bold()
                            }

                        } else {
                            ForEach(moodColorList, id: \.key) { item in
                                Button {
                                    withAnimation {
                                        self.moodColorActive = item
                                        self.routeDetailForm.mood_color = item.key
                                    }
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
                    Button {
                        Task {
                            await self.getAroundAddress()
                        }
                    } label: {
                        Text("\(routeDetailForm.address == "" ? "选择当前位置" : routeDetailForm.address)")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(LinearGradient(gradient: Gradient(
                                    colors: [Color(hex: "#FFF2D1"), Color(hex: "#ffffff")]
                                ),
                                startPoint: .leading, endPoint: .trailing))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.top, 25)
                            .font(.system(size: 16))
                            .foregroundStyle(Color(hex: "#666666"))
                            .shadow(color: Color(hex: "#9F9F9F").opacity(0.4), radius: 4.4, x: 0, y: 1)
                    }

                    // 说点什么
                    VStack {
                        TextField("Comment", text: $routeDetailForm.content, prompt: Text("说点什么？"), axis: .vertical)
                            .lineLimit(4 ... 8)
                            .submitLabel(.done)
                            .autocapitalization(.none) // 禁止任何自动大写
                            .disableAutocorrection(true) // 禁止自动更正
                            .foregroundStyle(Color(hex: "#666666"))
                            .onChange(of: routeDetailForm.content) {
                                // 当内容变化时执行的代码
                                if routeDetailForm.content.contains("\n") {
                                    routeDetailForm.content = routeDetailForm.content.replacingOccurrences(of: "\n", with: "")
                                }
                            }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [Color(hex: "#FFF2D1"), Color(hex: "#ffffff")]
                            ),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: Color(hex: "#9F9F9F").opacity(0.4), radius: 4.4, x: 0, y: 1)
                    .padding(.top, 25)
                    .onTapGesture {
//                        self.hideKeyboard()
                    }

                    // 按钮操作组
                    HStack(spacing: 23) {
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
                    .padding(.top, 34)

                    // 防止键盘挡住输入框
                    Spacer()
                        .frame(height: keyboardHeight)
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            }
            .padding(.horizontal, 16)
            .padding(.top, 61)
            // 点击空白处隐藏输入框
            .onTapGesture {
//                self.hideKeyboard()
            }
                
            // loading 组件
            Loading()
        }
    }
    
    /// 获取周边地址
    private func getAroundAddress() async {
        let longitude = "\(homeData.region.center.longitude)"
        let latitude = "\(homeData.region.center.latitude)"
        
        do {
            let res = try await Api.shared.getAroundAddress(params: [
                "longitude": longitude,
                "latitude": latitude,
                //                "longitude": "120.298501",
                //                "latitude": "30.41875",
                "page_num": 1,
            ])

            print("获取周边地址", res, longitude, latitude)

            guard res.code == 200, let data = res.data else {
                return
            }

            addressList = data
            fullScreenCoverType = .location
            visibleFullScreenCover.toggle()
        } catch {
            print("获取周边地址异常")
        }
    }
}

// 打卡 sheet 对话框内部全屏弹出，用于选择照片和地址
private struct HomeRecordSheetFullScreenCoverView: View {
    @Binding var fullScreenCoverType: FullScreenCoverType
    /// 选择的图片文件列表
    @Binding var selectedImages: [UIImage]
    /// 推荐的地址列表
    @Binding var addressList: [GetAroundAddressType.GetAroundAddressData]
    /// 是否显示全屏对话框
    @Binding var visibleFullScreenCover: Bool
    /// 打卡详情
    @Binding var routeDetailForm: RouteDetailForm
    
    var body: some View {
        if fullScreenCoverType == .picture {
            ImagePicker(selectedImages: $selectedImages, maxCount: pictureMaxCount - selectedImages.count)
        } else if fullScreenCoverType == .location {
            NavigationStack {
                VStack {
                    ScrollView {
                        ForEach(addressList, id: \.name) { item in
                            Button {
                                self.selectAddress(longitude: item.longitude, latitude: item.latitude, address: item.address)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text("\(item.name ?? "")")
                                        .bold()
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color("text-1"))
        
                                    Text("\(item.address ?? "")")
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color("text-2"))
                                        .padding(.top, 2)
        
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 3)
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("所在位置")
                            .font(.headline)
                            .foregroundStyle(Color("text-1"))
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            visibleFullScreenCover.toggle()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color("text-2"))
                        }
                    }
                }
            }
        }
    }
    
    /// 选择地址
    /// - Parameters:
    ///   - longitude: 经度
    ///   - latitude: 纬度
    ///   - address: 地址信息
    private func selectAddress(longitude: Double?, latitude: Double?, address: String?) {
        routeDetailForm.address = address ?? ""
        
        if let longitude = longitude {
            routeDetailForm.longitude = "\(longitude)"
        }
        
        if let latitude = latitude {
            routeDetailForm.longitude = "\(latitude)"
        }
        
        visibleFullScreenCover.toggle()
    }
}

/// 首页头部
private struct HomeHeaderView: View {
    /// 缓存数据
    var storageData: StorageData
    /// 是否显示卫星地图
    @Binding var isSatelliteMap: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            if let userInfo = storageData.userInfo {
                NavigationLink(destination: MainView(user_id: userInfo.user_id)) {
                    if let avatar = userInfo.avatar,
                       let url = URL(string: avatar)
                    {
                        KFImage(url)
                            .placeholder {
                                Circle()
                                    .fill(skeletonBackground)
                                    .frame(width: 53, height: 53)
                                    .shadow(radius: 10)
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 53, height: 53)
                            .clipShape(
                                Circle()
                            )
                            .shadow(radius: 10)
                    } else {
                        Circle()
                            .fill(skeletonBackground)
                            .frame(width: 53, height: 53)
                            .shadow(radius: 10)
                    }
                }
            } else {
                NavigationLink(destination: storageData.token != nil && storageData.token != "" ? LoginView() : LoginView()) {
                    Circle()
                        .fill(skeletonBackground)
                        .frame(width: 48, height: 48)
                        .overlay {
                            Image(systemName: "person")
                                .foregroundStyle(Color(hex: "#333333"))
                                .font(.system(size: 22))
                        }
                }
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
                                .foregroundColor(Color("text-1"))
                        }
                }
                
                VStack(spacing: 0) {
                    // 切换主题按钮
                    Button {
                        self.isSatelliteMap.toggle()
                    } label: {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 42, height: 42)
                            .overlay {
                                Image(systemName: "map")
                                    .resizable()
                                    .foregroundStyle(Color("text-1"))
                                    .frame(width: 23, height: 23)
                            }
                    }
                   
                    // 回到当前位置按钮
                    Button {} label: {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 42, height: 42)
                            .overlay {
                                Image(systemName: "paperplane")
                                    .resizable()
                                    .foregroundStyle(Color("text-1"))
                                    .frame(width: 23, height: 23)
                            }
                    }
                }
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
}

/// 首页底部卡片
private struct HomeBottomCardsView: View {
    /// 点击打卡的回调
    var onRecord: () async -> Void
    
    private let friendsBanner = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-friends.png")
    private let inviteBanner = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-invite.png")
    private let recordBanner = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-record.png")
    private let rankingBanner = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-ranking.png")
    
    var body: some View {
        // 底部功能
        ZStack(alignment: .bottom) {
            VariableBlurView(maxBlurRadius: 12)
                .frame(height: 240)
                .rotationEffect(.degrees(180))
            
            // 底部卡片
            VStack(spacing: 33) {
                // 天气
                HStack {
                    Button {
                        self.openWeatherApp()
                    } label: {
                        VStack(spacing: -13) {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 1.2)
                                        .overlay {
                                            Image(systemName: "sun.max")
                                                .font(.system(size: 18))
                                                .foregroundStyle(Color(hex: "#FE8718"))
                                                .padding(.top, -5)
                                        }
                                )
                        
                            RoundedRectangle(cornerRadius: 18)
                                .frame(width: 55, height: 23)
                                .overlay(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(.white, lineWidth: 2)
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(
                                                        colors: [Color(hex: "#FE8718"), Color(hex: "#FEC43D")]
                                                    ),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .cornerRadius(18)
                                    
                                        Text("26度")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white)
                                    }
                                )
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 19)
                
                // 卡片列表
                HStack(spacing: 12) {
                    VStack(spacing: 16) {
                        // 我的朋友
                        NavigationLink(destination: FriendsView()) {
                            KFImage(friendsBanner)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(skeletonBackground)
                                        .frame(width: 170, height: 98)
                                }
                                .resizable()
                                .frame(width: 170, height: 98)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("我的朋友")
                                                .font(.headline)
                                                .bold()
                                                .foregroundColor(.white)
                             
                                            Text("My Friends")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                             
                                            Spacer()
                                        }
                             
                                        Spacer()
                                    }
                                    .padding(.top, 14)
                                    .padding(.leading, 16)
                                }
                        }
                        
                        // 邀请朋友
                        NavigationLink(destination: InviteView()) {
                            KFImage(inviteBanner)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(skeletonBackground)
                                        .frame(width: 170, height: 98)
                                }
                                .resizable()
//                                            .aspectRatio(contentMode: .fill)
                                .frame(width: 170, height: 98) // 设置按钮的大小
                                .clipShape(RoundedRectangle(cornerRadius: 10)) // 裁剪为圆角矩形
                                .overlay {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("邀请朋友")
                                                .font(.headline)
                                                .bold()
                                                .foregroundColor(.white)
                                            
                                            Text("City Walk Together")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.top, 14)
                                    .padding(.leading, 16)
                                }
                        }
                    }
                    
                    VStack(spacing: 12) {
                        // 地点打卡
                        Button {
                            Task {
                                await self.onRecord()
                            }
                        } label: {
                            KFImage(recordBanner)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(skeletonBackground)
                                        .frame(width: 170, height: 130)
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 170, height: 130)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("打卡")
                                                .font(.headline)
                                                .bold()
                                                .foregroundColor(.white)
                                            
                                            Text("Record location")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.top, 14)
                                    .padding(.leading, 16)
                                }
                        }
                        
                        // 排行榜
                        NavigationLink(destination: RankingView()) {
                            KFImage(rankingBanner)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(skeletonBackground)
                                        .frame(width: 170, height: 76)
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 170, height: 76)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("排行榜")
                                                .font(.headline)
                                                .bold()
                                                .foregroundColor(.white)
                                                    
                                            Text("Ranking")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                                    
                                            Spacer()
                                        }
                                                
                                        Spacer()
                                    }
                                    .padding(.top, 14)
                                    .padding(.leading, 16)
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, bottomSafeAreaInsets)
        }
    }
    
    /// 打开 app 的天气软件
    private func openWeatherApp() {
        if let url = URL(string: "weather://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("无法打开天气应用")
            }
        }
    }
}

/// 完善步行记录详情表单
private struct RouteDetailForm {
    var route_id: String
    var content: String
    var travel_type: String
    var mood_color: String
    var address: String
    var picture: [String]
    var latitude: String?
    var longitude: String?
}

/// FullScreenCover 对话框打开类型
private enum FullScreenCoverType {
    case picture, location
}

#Preview {
    HomeView()
        .environmentObject(FriendsData())
        .environmentObject(RankingData())
        .environmentObject(MainData())
        .environmentObject(LoadingData())
        .environmentObject(HomeData())
        .environmentObject(StorageData())
}
