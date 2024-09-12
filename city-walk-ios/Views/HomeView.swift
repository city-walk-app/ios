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
import ToastUI

/// 心情颜色
private let moodColorList = moodColors
/// 出行方式
private let travelTypeList = travelTypes
/// 最多选择的照片数量
private let pictureMaxCount = 2
/// 经度偏移量
private let longitudeOffset = 0.00428
/// 纬度偏移量
private let latitudeOffset = -0.00294
/// 定位服务管理对象
private var locationManager = CLLocationManager()

private let friendsBanner = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-friends.png")
private let inviteBanner = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-invite.png")
private let recordBanner = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-record.png")
private let rankingBanner = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-ranking.png")

/// 首页
struct HomeView: View {
    /// 首页数据
    @EnvironmentObject private var homeData: HomeData
    /// 缓存数据
    @EnvironmentObject private var storageData: StorageData
    /// 全球的数据
    @EnvironmentObject private var globalData: GlobalData
    
    /// 定位数据管理对象
    @StateObject private var locationData = LocationData()
   
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
        travel_type: nil,
        mood_color: "",
        address: "",
        picture: []
    )
    /// 心情颜色选中的配置
    @State private var moodColorActive: MoodColor?
    /// 选择的出行方式
    @State private var travelTypeActive: TravelType?
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
    /// 是否显示预览的图片
    @State private var isPreviewing = false
    /// 预览的图片列表
    @State private var previewImages: [String] = []
    /// 预览的图片索引
    @State private var previewSelectedIndex = 0
    /// 打卡按钮是否禁用
    @State private var isRecordButtonDisabled = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 地图
                Map(coordinateRegion: $homeData.region, showsUserLocation: true, annotationItems: homeData.landmarks ?? []) { landmark in
                    MapAnnotation(coordinate: landmark.coordinate) {
                        Landmark(landmark: landmark, pictureClick: pictureClick)
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
                            withAnimation {
                                homeData.region = MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude),
                                    span: MKCoordinateSpan(latitudeDelta: defaultDelta, longitudeDelta: defaultDelta)
                                )
                                
                                // homeData.region.center = currentLocation
                                homeData.userLocation = currentLocation // 更新 location 为当前用户位置
                            }
                        }
                    }
                }
               
                // 头部和底部操作视图
                VStack {
                    // 头部操作栏
                    HomeHeaderView(
                        storageData: storageData,
                        homeData: homeData,
                        globalData: globalData,
                        isSatelliteMap: $isSatelliteMap
                    )

                    Spacer()
                    
                    // 底部卡片
                    HomeBottomCardsView(
                        isRecordButtonDisabled: $isRecordButtonDisabled,
                        onRecord: onRecord
                    )
                }
                .ignoresSafeArea(.all, edges: .bottom)
                
                // 预览图片
                if isPreviewing {
                    ImagePreviewView(images: previewImages, selectedIndex: $previewSelectedIndex, isPresented: $isPreviewing)
                }
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
                travelTypeActive: $travelTypeActive,
                keyboardHeight: $keyboardHeight,
                globalData: globalData,
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
                        await self.friendConfirmInvite() // 同意好友申请
                    }
                }),
                secondaryButton: .cancel(Text("取消"))
            )
        }
        .toast(isPresented: $globalData.isShowToast, dismissAfter: globalData.toastType == .toast ? 1.25 : nil) {
            // 加载中
            if globalData.toastType == .loading {
                ToastView(globalData.toastMessage)
                    .toastViewStyle(.indeterminate)
            }
            // 提示信息
            else if globalData.toastType == .toast {
                Button {
                    globalData.isShowToast = false
                } label: {
                    VStack {
                        Text(globalData.toastMessage)
                            .foregroundColor(.white)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("theme-1"))
                            .cornerRadius(8.0)
                            .shadow(radius: 4.0)

                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .toastDimmedBackground(false)
        .onAppear {
            self.getLoginState() // 获取登录状态
        }
        // 退出到桌面返回执行
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            self.getLoginState() // 获取登录状态
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
        .fullScreenCover(isPresented: $globalData.isShowLoginFullScreen, content: {
            LoginView(storageData: storageData, globalData: globalData) {
                homeLoad() // 首页加载
            }
        })
    }
    
    /// 照片点击的回调
    private func pictureClick(picture: [String]) {
        previewImages = picture
        
        withAnimation {
            self.isPreviewing.toggle()
        }
    }
    
    /// 获取登录状态
    private func getLoginState() {
        let isNeedLogin = storageData.token == nil || storageData.token == ""
        
        globalData.isShowLoginFullScreen = isNeedLogin
        
        if globalData.isShowLoginFullScreen {
            globalData.isShowLoginFullScreen = true
        } else {
            homeLoad() // 首页加载
        }
    }
    
    /// 首页加载
    private func homeLoad() {
        print("首页加载")
        Task {
            await self.getUserInfo() // 获取用户信息
            
            await homeData.getTodayRecord() // 获取今天的打卡记录
        }

        readClipboard() // 读取剪贴板
        addObserverKeyboardHeight() // 监听键盘的高度
    }
    
    /// 监听键盘的高度
    private func addObserverKeyboardHeight() {
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
        do {
            // 读取剪贴板中的文本内容
            if let clipboardText = UIPasteboard.general.string {
                print("剪贴板内容: \(clipboardText)")
            
                let decryptedString = try decrypt(base64String: clipboardText, usingKey: crytpoKey)

                if decryptedString.hasPrefix("city-walk:IN") {
                    print("解密结果", decryptedString)

                    invite_id = decryptedString.replacingOccurrences(of: "city-walk:", with: "")
                
                    Task {
                        await getFriendInviteInfo() // 获取邀请详情
                    }
                }
            } else {
                print("剪贴板中没有文本内容")
            }
        } catch {
            print("读取异常")
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
                globalData.showToast(title: res.message)
                return
            }
            
            friendInviteDetail = data
            isShowFriendInviteAlert.toggle()
        } catch {
            globalData.showToast(title: "获取邀请详情异常")
            print("获取邀请详情异常")
        }
    }
    
    /// 清除打卡对话框内容
    private func clearStepFormData() {
        routeDetailForm = RouteDetailForm(
            route_id: "",
            content: "",
            travel_type: nil,
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
//            globalData.showLoading(title: "提交中...")
           
            // 有选择照片
            if !selectedImages.isEmpty {
                let uploadedImageURLs = await uploadImages(images: selectedImages)
                
                print("上传图片的结果", uploadedImageURLs)
                
                routeDetailForm.picture = uploadedImageURLs
            }
            
            let res = try await Api.shared.updateRouteDetail(params: [
                "route_id": routeDetailForm.route_id,
                "content": routeDetailForm.content,
                "travel_type": routeDetailForm.travel_type?.rawValue ?? "",
                "mood_color": routeDetailForm.mood_color,
                "address": routeDetailForm.address,
                "picture": routeDetailForm.picture,
                "longitude": routeDetailForm.longitude ?? "",
                "latitude": routeDetailForm.latitude ?? "",
            ])

//            globalData.hiddenLoading()
            
            print("完善记录详情", res)
            
            guard res.code == 200, let data = res.data else {
                globalData.showToast(title: res.message)
                return
            }
            
            let resLatitude = Double(data.latitude) ?? 0
            let resLongitude = Double(data.longitude) ?? 0
            
            homeData.landmarks.append(
                LandmarkItem(
                    coordinate: CLLocationCoordinate2D(
                        latitude: resLatitude,
                        longitude: resLongitude
                    ),
                    picure: data.picture
                )
            )

            withAnimation {
                homeData.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: resLatitude, longitude: resLongitude),
                    span: MKCoordinateSpan(latitudeDelta: uploadDelta, longitudeDelta: uploadDelta)
                )
            }
         
            clearStepFormData() // 清空表单
            visibleSheet.toggle()
            globalData.showToast(title: "提交成功")
        } catch {
            print("完善步行打卡记录详情异常")
            globalData.showToast(title: "提交异常")
            globalData.hiddenLoading()
        }
    }
    
    /// 获取用户信息
    private func getUserInfo() async {
        guard storageData.userInfo != nil else {
            return
        }
        
        do {
            let res = try await Api.shared.getUserInfo(params: ["user_id": storageData.userInfo!.user_id])

            guard res.code == 200, let data = res.data else {
                return
            }

            userInfo = data
            storageData.saveUserInfo(info: data)
            updateUserInfo() // 获取缓存的用户信息
        } catch {
            print("获取用户信息异常")
        }
    }
    
    /// 获取缓存的用户信息
    private func updateUserInfo() {
        guard let info = storageData.userInfo,
              var userInfo = userInfo
        else {
            return
        }
        
        userInfo.avatar = info.avatar ?? defaultAvatar
        userInfo.gender = info.gender
        userInfo.nick_name = info.nick_name
        userInfo.signature = info.signature ?? ""
        userInfo.mobile = info.mobile ?? ""
    }

    /// 打卡当前地点
    private func locationCreateRecord(longitude: String, latitude: String) async {
        do {
            globalData.showLoading(title: "打卡中...")
            
            let res = try await Api.shared.locationCreateRecord(params: [
                "longitude": longitude,
                "latitude": latitude,
//                "longitude": 112.455646,
//                "latitude": 30.709778,
            ])
            
            globalData.hiddenLoading()
            
            print("打卡结果", res)

            guard res.code == 200, let data = res.data else {
                isRecordButtonDisabled = false
                globalData.showToast(title: res.message)
                return
            }
            
            recordDetail = data
                
            recordDetail!.province_url = data.province_code != nil
                ? "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/provinces/\(data.province_code!).png"
                : nil
                
            routeDetailForm.route_id = data.route_id
                
            visibleSheet.toggle() // 打开对话框
            isRecordButtonDisabled = false
        } catch {
            print("打卡当前地点异常")
            globalData.showToast(title: "打卡当前地点异常")
            globalData.hiddenLoading()
            isRecordButtonDisabled = false
        }
    }
    
    /// 获取当前位置并打卡
    private func onRecord() async {
        isRecordButtonDisabled = true
        locationData.checkLocationAuthorization()
        
        // 获取经纬度的字符串描述
        if let location = locationData.locationManager.location {
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
                globalData.showToast(title: "打卡异常")
                isRecordButtonDisabled = false
                print("经度或纬度转换失败")
            }
        } else {
            globalData.showToast(title: "打卡异常")
            isRecordButtonDisabled = false
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
    /// 选择的出行方式
    @Binding var travelTypeActive: TravelType?
    /// 键盘高度
    @Binding var keyboardHeight: CGFloat
    /// 全局数据
    var globalData: GlobalData
    /// 首页数据
    var homeData: HomeData
    /// 完善步行打卡记录详情
    var updateRouteDetail: () async -> Void

    /// 推荐的地址列表
    @State private var addressList: [GetAroundAddressType.GetAroundAddressData] = []
    /// 全屏弹窗显示的类型
    @State private var fullScreenCoverType: FullScreenCoverType = .picture
    /// 获取地址到页码
    @State private var getAroundAddressPageNum = 1
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    // 省份图
                    if let recordDetail = self.recordDetail {
                        // 省份图
                        if let province_url = recordDetail.province_url {
                            // 省份图
                            Color.clear
                                .frame(width: 154, height: 154) // 保持原有的尺寸但设置为透明
                                .background(
                                    Group {
                                        recordDetail.background_color != nil
                                            ? Color(hex: recordDetail.background_color!)
                                            : Color("theme-1")
                                    }
                                    .mask {
                                        KFImage(URL(string: province_url))
                                            .placeholder {
                                                Color.clear
                                            }
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .shadow(
                                                color: recordDetail.background_color != nil
                                                    ? Color(hex: recordDetail.background_color!).opacity(0.6)
                                                    : Color("theme-1").opacity(0.6),
                                                radius: 12
                                            )
                                    }
                                )
                            
                            // 文案
                            Text("\(recordDetail.content ?? "当前地点打卡成功")")
                                .foregroundStyle(
                                    recordDetail.background_color != nil
                                        ? Color(hex: recordDetail.background_color!)
                                        : Color("theme-1")
                                )
                                .font(.system(size: 17))
                                .bold()
                        }
                    }
                   
                    // 说点什么
                    VStack {
                        TextField("Comment", text: $routeDetailForm.content, prompt: Text("说点什么？"), axis: .vertical)
                            .lineLimit(3 ... 6)
                            .padding(23)
                            .submitLabel(.done)
                            //                            .background(self.focus == .signature ? Color.clear : Color("background-3"))
                            //                            .focused($focus, equals: .signature)
                            .foregroundStyle(Color("text-1"))
                            //                            .onReceive(Just(routeDetailForm.content), perform: { _ in
                            //                                limitMaxLength(content: &routeDetailForm.content, maxLength: signatureMaxLength)
                            //                            })
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("theme-1"), lineWidth: 2)
                            )
                            .onChange(of: routeDetailForm.content) {
                                // 当内容变化时执行的代码
                                if routeDetailForm.content.contains("\n") {
                                    routeDetailForm.content = routeDetailForm.content.replacingOccurrences(of: "\n", with: "")
                                }
                            }
                    }
                    .padding(.top, 6)
                    .padding(.horizontal, 16)
                    
                    // 选择当前位置
                    //                    Button {
                    //                        Task {
                    //                            await self.getAroundAddress()
                    //                        }
                    //                    } label: {
                    //                        Text("\(routeDetailForm.address == "" ? "选择当前位置" : routeDetailForm.address)")
                    //                            .frame(maxWidth: .infinity)
                    //                            .padding(.vertical, 13)
                    //                            .background(LinearGradient(gradient: Gradient(
                    //                                    colors: [Color(hex: "#FFF2D1"), Color(hex: "#ffffff")]
                    //                                ),
                    //                                startPoint: .leading, endPoint: .trailing)
                    //                            )
                    //                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    //                            .padding(.top, 25)
                    //                            .font(.system(size: 16))
                    //                            .foregroundStyle(Color(hex: "#666666"))
                    //                            .shadow(color: Color(hex: "#9F9F9F").opacity(0.4), radius: 4.4, x: 0, y: 1)
                    //                    }
                    
                    // 选择心情颜色
                    VStack {
                        if let moodColorActive = moodColorActive {
                            HStack {
                                Button {
                                    withAnimation {
                                        self.moodColorActive = nil
                                        self.routeDetailForm.mood_color = ""
                                    }
                                } label: {
                                    Circle()
                                        .fill(Color(hex: moodColorActive.color))
                                        .frame(width: 47, height: 47)
                                        .overlay(
                                            Circle()
                                                .stroke(Color(hex: moodColorActive.borderColor), lineWidth: 1)
                                        )
                                    
                                    Text(moodColorActive.type)
                                        .foregroundStyle(Color(hex: moodColorActive.color))
                                        .font(.system(size: 16))
                                        .bold()
                                }
                            }
                            .padding(.horizontal, 16)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(moodColorList, id: \.key) { item in
                                        Button {
                                            withAnimation {
                                                self.moodColorActive = item
                                                self.routeDetailForm.mood_color = item.key
                                            }
                                        } label: {
                                            Circle()
                                                .fill(Color(hex: item.color))
                                                .frame(width: 47, height: 47)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color(hex: item.borderColor), lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.top, 10)

                    // 选择出行方式
                    VStack {
                        if let travelTypeActive = travelTypeActive {
                            HStack {
                                Button {
                                    withAnimation {
                                        self.travelTypeActive = nil
                                        self.routeDetailForm.travel_type = nil
                                    }
                                } label: {
                                    Circle()
                                        .fill(.gray)
                                        .frame(width: 47, height: 47)
                                        .frame(width: 47, height: 47)
                                        .overlay {
                                            Image(systemName: travelTypeActive.icon)
                                                .frame(width: 41, height: 41)
                                                .foregroundStyle(.white)
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(travelTypeList, id: \.key) { item in
                                        Button {
                                            withAnimation {
                                                self.routeDetailForm.travel_type = item.key
                                                self.travelTypeActive = item
                                            }
                                        } label: {
                                            let isActive = self.routeDetailForm.travel_type == item.key
                                        
                                            Circle()
                                                .fill(isActive ? Color("theme-1") : Color(hex: "#eeeeee"))
                                                .frame(width: 47, height: 47)
                                                .overlay {
                                                    Image(systemName: item.icon)
                                                        .frame(width: 41, height: 41)
                                                        .foregroundStyle(isActive ? .white : .blue)
                                                }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    // 选择照片
                    HStack {
                        // 一张照片都没选择
                        if selectedImages.count == 0 || selectedImages.isEmpty {
                            // 发布瞬间
                            Menu {
                                Section {
                                    Button {
                                        self.fullScreenCoverType = .camera
                                        self.visibleFullScreenCover.toggle()
                                    } label: {
                                        Label("拍照", systemImage: "camera")
                                    }
                                        
                                    Button {
                                        self.fullScreenCoverType = .picture
                                        self.visibleFullScreenCover.toggle()
                                    } label: {
                                        Label("相册选择", systemImage: "photo")
                                    }
                                }
                            } label: {
                                HStack {
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
                        // 选择了一张照片
                        else if selectedImages.count == 1 {
                            let columns = [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                            ]
                                
                            LazyVGrid(columns: columns) {
                                Image(uiImage: selectedImages[0])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 134)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .onLongPressGesture {
                                        visibleActionSheet.toggle()
                                    }
                                    
                                Menu {
                                    Button {
                                        self.fullScreenCoverType = .camera
                                        self.visibleFullScreenCover.toggle()
                                    } label: {
                                        Label("拍照", systemImage: "camera")
                                    }
                                        
                                    Button {
                                        self.fullScreenCoverType = .picture
                                        self.visibleFullScreenCover.toggle()
                                    } label: {
                                        Label("相册选择", systemImage: "photo")
                                    }
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
                    .padding(.top, 23)
                    .frame(maxWidth: .infinity)
                    // 选择照片的全屏弹出对话框
                    .fullScreenCover(isPresented: $visibleFullScreenCover, content: {
                        HomeRecordSheetFullScreenCoverView(
                            fullScreenCoverType: $fullScreenCoverType,
                            selectedImages: $selectedImages,
                            addressList: $addressList,
                            visibleFullScreenCover: $visibleFullScreenCover,
                            routeDetailForm: $routeDetailForm,
                            getAroundAddressPageNum: $getAroundAddressPageNum
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
                        
                    // 防止键盘挡住输入框
                    // Spacer()
                    // .frame(height: keyboardHeight)
                }
            }
            
            Button {
                Task {
                    await self.updateRouteDetail() // 完善步行打卡记录详情
                }
            } label: {
                Label("就这样", systemImage: "globe.asia.australia")
                    .frame(width: 180, height: 62)
                    .font(.system(size: 19))
                    .foregroundStyle(.white)
                    .bold()
                    .background(Color("theme-1"))
                    .border(Color("theme-1"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
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
//                "longitude": 112.455646,
//                "latitude": 30.709778,
                "page_num": getAroundAddressPageNum,
            ])
            
            print("获取周边地址", res, longitude, latitude)

            guard res.code == 200, let data = res.data else {
                globalData.showToast(title: "暂无可选周边地址")
                return
            }

            addressList = data
          
            fullScreenCoverType = .location
            visibleFullScreenCover.toggle()
        } catch {
            globalData.showToast(title: "获取周边地址异常")
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
    /// 获取地址到页码
    @Binding var getAroundAddressPageNum: Int
    
    var body: some View {
        // 选择照片
        if fullScreenCoverType == .picture {
            ImagePicker(selectedImages: $selectedImages, maxCount: pictureMaxCount - selectedImages.count)
                .ignoresSafeArea()
        }
        // 打开相机
        else if fullScreenCoverType == .camera {
            CameraView(isPresented: $visibleFullScreenCover, selectedImage: $selectedImages)
                .ignoresSafeArea()
        }
        // 选择位置
        else if fullScreenCoverType == .location {
            NavigationStack {
                VStack {
                    ScrollView {
                        if addressList.isEmpty {
                            EmptyState(title: "暂无可选地点")
                        } else {
                            ForEach(addressList, id: \.name) { item in
                                Button {
                                    self.selectAddress(longitude: Double(item.longitude ?? "0"), latitude: Double(item.latitude ?? "0"), address: item.address)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(item.name ?? "")")
                                            .bold()
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color("text-1"))
        
                                        Text("\(item.address ?? "")")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color("text-2"))
                                            .padding(.top, 2)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 10)
                                    .background(
                                        Rectangle()
                                            .frame(height: 0.6) // 下边框的高度
                                            .foregroundColor(.gray.opacity(0.2)), // 边框的颜色
                                        alignment: .bottom
                                    )
                                    .padding(.horizontal, 16)
                                }
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
    /// 用户信息
    var storageData: StorageData
    /// 首页数据
    var homeData: HomeData
    /// 全局数据
    var globalData: GlobalData
    /// 是否显示卫星地图
    @Binding var isSatelliteMap: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            if let userInfo = storageData.userInfo {
                NavigationLink(destination: MainView(user_id: userInfo.user_id)) {
                    // 头像存在
                    if let avatar = userInfo.avatar, let url = URL(string: avatar) {
                        KFImage(url)
                            .placeholder {
                                Circle()
                                    .fill(Color("skeleton-background"))
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
                    }
                    // 头像不存在
                    else {
                        Circle()
                            .fill(Color("skeleton-background"))
                            .frame(width: 53, height: 53)
                            .shadow(radius: 10)
                    }
                }
            }
            // 没有缓存信息
            else {
                Button {
                    globalData.isShowLoginFullScreen.toggle()
                } label: {
                    Circle()
                        .fill(Color("skeleton-background"))
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
                    Button {
                        withAnimation(Animation.easeInOut(duration: 1.0)) {
                            homeData.region = MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: homeData.userLocation.latitude, longitude: homeData.userLocation.longitude),
                                span: MKCoordinateSpan(latitudeDelta: defaultDelta, longitudeDelta: defaultDelta)
                            )
                        }
                    } label: {
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
    /// 打卡按钮是否禁用
    @Binding var isRecordButtonDisabled: Bool
    /// 点击打卡的回调
    var onRecord: () async -> Void
 
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
                        self.openWeatherApp() // 打开天气 app
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
                                        .fill(Color("skeleton-background"))
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
                                .shadow(color: .gray, radius: 8)
                        }
                        
                        // 邀请朋友
                        NavigationLink(destination: InviteView()) {
                            KFImage(inviteBanner)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("skeleton-background"))
                                        .frame(width: 170, height: 98)
                                }
                                .resizable()
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
                                .shadow(color: .gray, radius: 8)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        // 地点打卡
                        Button {
                            Task {
                                await self.onRecord() // 获取当前位置并打卡
                            }
                        } label: {
                            KFImage(recordBanner)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("skeleton-background"))
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
                                .shadow(color: .gray, radius: 8)
                        }
                        .opacity(isRecordButtonDisabled ? 0.5 : 1)
                        .disabled(isRecordButtonDisabled)
                        
                        // 排行榜
                        NavigationLink(destination: RankingView()) {
                            KFImage(rankingBanner)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("skeleton-background"))
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
                        .shadow(color: .gray, radius: 8)
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
    var travel_type: TravelTypeKey?
    var mood_color: String
    var address: String
    var picture: [String]
    var latitude: String?
    var longitude: String?
}

/// FullScreenCover 对话框打开类型
private enum FullScreenCoverType {
    case picture, location, camera
}

#Preview {
    HomeView()
        .environmentObject(FriendsData())
        .environmentObject(RankingData())
        .environmentObject(MainData())
        .environmentObject(HomeData())
        .environmentObject(StorageData())
        .environmentObject(GlobalData())
}
