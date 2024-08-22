//
//  HomeView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/18.
//

import Combine
import CoreLocation
import MapKit
import SwiftUI

struct AutoSizingTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        // Adjust height dynamically
        DispatchQueue.main.async {
            self.height = uiView.contentSize.height
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AutoSizingTextEditor

        init(_ parent: AutoSizingTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.height = textView.contentSize.height
        }
    }
}

/// 主视图，用于显示地图和操作选项
struct HomeView: View {
    /// 完善步行记录详情表单
    struct RouteDetailForm {
        var route_id: String
        var content: String
        var travel_type: String
        var mood_color: String
        var address: String
        var picture: [String]
    }

    /// 缓存信息
    private let cacheInfo = UserCache.shared.getInfo()
    /// 心情颜色
    private let moodColorList = moodColors
    /// 最多选择的照片数量
    private let pictureMaxCount = 2
    
    /// loading 数据
    @EnvironmentObject private var loadingData: LoadingData
    
    /// 定位数据管理对象
    @StateObject private var locationDataManager = LocationDataManager()
    
    /// 打卡弹窗是否显示
    @State private var visibleSheet = false
    /// 是否显示选择的菜单
    @State private var visibleActionSheet = false
    /// 定位服务管理对象
    @State private var locationManager = CLLocationManager()
    /// 位置权限状态
    @State private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    /// 地图区域
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30, longitude: 120),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
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
    /// 输入框改读
    @State private var textEditorHeight: CGFloat = UIFont.systemFont(ofSize: 17).lineHeight + 10
    /// 是否显示全屏对话框
    @State private var visibleFullScreenCover = false
    /// 选择的图片文件列表
    @State private var selectedImages: [UIImage] = []
    // 标注列表
    @State private var landmarks: [Landmark] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 地图
//                Map(initialPosition: .region(region))
                // 地图
                Map(coordinateRegion: self.$region, annotationItems: self.landmarks) { landmark in
                    MapAnnotation(coordinate: landmark.coordinate) {
                        VStack {
                            AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-markers.png")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 64)
                            } placeholder: {}

                            Text("地点")
                                .font(.system(size: 20))
                        }
                    }
                }
                .ignoresSafeArea(.all) // 忽略安全区域边缘
             
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
                                            .frame(width: 53, height: 53)
                                            .clipShape(
                                                Circle()
                                            )
                                            .shadow(radius: 10)
                                    } placeholder: {
                                        Circle()
                                            .fill(skeletonBackground)
                                            .frame(width: 53, height: 53)
                                            .shadow(radius: 10)
                                    }
                                } else {
                                    Circle()
                                        .fill(skeletonBackground)
                                        .frame(width: 53, height: 53)
                                        .shadow(radius: 10)
                                }
                            }
                        } else {
                            NavigationLink(destination: LoginView()) {
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
                        
                        /// https://stackoverflow.com/questions/64551580/swiftui-sheet-doesnt-access-the-latest-value-of-state-variables-on-first-appear
                        Text("\(String(describing: recordDetail))")
                            .font(.system(size: 0))
                            .foregroundStyle(Color.clear)
                            
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
                            
                            VStack(spacing: 0) {
                                // 切换主题按钮
                                Button {} label: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 42, height: 42)
                                        .overlay {
                                            Image(systemName: "map")
                                                .resizable()
                                                .foregroundStyle(Color(hex: "#333333"))
                                                .frame(width: 23, height: 23)
                                        }
                                }
                               
                                // 回到当前位置按钮
                                Button {} label: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 42, height: 42)
                                        .overlay {
                                            Image(systemName: "paperplane")
                                                .resizable()
                                                .foregroundStyle(Color(hex: "#333333"))
                                                .frame(width: 23, height: 23)
                                        }
                                }
                            }
                            .background(.ultraThinMaterial)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                  
                    Spacer()
                    
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
                                        // 背景图片
                                        AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-friends.png")) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
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
                                        } placeholder: {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(skeletonBackground)
                                                .frame(width: 170, height: 98)
                                        }
                                    }
                                    
                                    // 邀请朋友
                                    NavigationLink(destination: InviteView()) {
                                        // 背景图片
                                        AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-invite.png")) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
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
                                        } placeholder: {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(skeletonBackground)
                                                .frame(width: 170, height: 98)
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
                                        AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-record.png")) { image in
                                            image
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
                                        } placeholder: {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(skeletonBackground)
                                                .frame(width: 170, height: 130)
                                        }
                                    }
                                    
                                    // 排行榜
                                    NavigationLink(destination: RankingView()) {
                                        AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-ranking.png")) { image in
                                            image
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
                                        } placeholder: {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(skeletonBackground)
                                                .frame(width: 170, height: 76)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.bottom, bottomSafeAreaInsets)
                    }
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
        .sheet(isPresented: $visibleSheet, onDismiss: {
            recordDetail = nil
            print("关闭执行")
        }) {
            ScrollView {
                ZStack {
                    VStack {
                        if let recordDetail = self.recordDetail {
                            // 省份图
                            if let province_url = recordDetail.province_url {
                                // 省份图
                                Color.clear
                                    .frame(width: 154, height: 154) // 保持原有的尺寸但设置为透明
                                    .background(
                                        AsyncImage(url: URL(string: province_url)) { phase in
                                            if let image = phase.image {
                                                Color(hex: recordDetail.background_color ?? "#F3943F")
                                                    .mask {
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                    }
                                            } else {
                                                Color.clear
                                            }
                                        }
                                    )
                            }
                        
                            // 文案
                            Text("\(recordDetail.content ?? "当前地点打卡成功")")
                                .foregroundStyle(Color(hex: recordDetail.background_color ?? "#F3943F"))
                                .padding(.top, 9)
                                .font(.system(size: 16))
                                .bold()
                        } else {
                            // 省份图
                            Color.clear
                                .frame(width: 154, height: 154) // 保持原有的尺寸但设置为透明
                                .background(
                                    AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/provinces/330000.png")) { phase in
                                        if let image = phase.image {
                                            Color(hex: "#F3943F")
                                                .mask {
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 154, height: 154)
                                                }
                                        
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                        
                            // 文案
                            Text("当前地点打卡成功")
                                .foregroundStyle(Color(hex: "#F3943F"))
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
                                        self.visibleFullScreenCover.toggle()
                                    } label: {
                                        VStack {
                                            AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/record-succese-camera.png")) { image in
                                                image
                                                    .resizable()
                                                    .frame(width: 69, height: 64)
                                            } placeholder: {
                                                Color.clear
                                                    .frame(width: 69, height: 64)
                                            }
                                    
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
                                            self.visibleFullScreenCover.toggle()
                                        } label: {
                                            AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/record-succese-camera.png")) { image in
                                                image
                                                    .resizable()
                                                    .frame(width: 69, height: 64)
                                            } placeholder: {
                                                Color.clear
                                                    .frame(width: 69, height: 64)
                                            }
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
                                ImagePicker(selectedImages: $selectedImages, maxCount: pictureMaxCount - selectedImages.count)
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
                                    ForEach(self.moodColorList, id: \.key) { item in
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
                            Button {} label: {
                                Text("选择当前位置")
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
                            //                    VStack {
                            //                        AutoSizingTextEditor(text: $routeDetailForm.content, height: $textEditorHeight)
                            //                            .frame(height: textEditorHeight)
                            //                            .background(Color.clear) // Ensure background is clear
                            //                            .submitLabel(.done)
                            //                            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
                            //                            .onSubmit {
                            //                                self.hideKeyboard()
                            //                            }
                            ////                        TextEditor(text: $routeDetailForm.content)
                            ////                            .submitLabel(.done)
                            ////                            .onReceive(Publishers.keyboardHeight) {
                            ////                                self.keyboardHeight = $0
                            ////                            }
                            ////                            .onSubmit {
                            ////                                self.hideKeyboard()
                            ////                            }
                            //                    }
                            //                    .padding(16)
                            //                    .frame(maxWidth: .infinity)
                            //                    .frame(minHeight: 62)
                            //                    .background(
                            //                        LinearGradient(
                            //                            gradient: Gradient(
                            //                                colors: [Color(hex: "#FFF2D1"), Color(hex: "#ffffff")]
                            //                            ),
                            //                            startPoint: .leading,
                            //                            endPoint: .trailing
                            //                        )
                            //                    )
                            //                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            //                    .shadow(color: Color(hex: "#9F9F9F").opacity(0.4), radius: 4.4, x: 0, y: 1)
                            //                    .padding(.top, 25)
                            VStack {
                                AutoSizingTextEditor(text: $routeDetailForm.content, height: $textEditorHeight)
                                    .frame(height: textEditorHeight)
                                    .background(Color.clear) // Ensure background is clear
                                    .submitLabel(.done)
                                    .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
                                    .onSubmit {
                                        self.hideKeyboard()
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
                            .padding(.bottom, keyboardHeight) // Adjust padding for keyboard
                            .onTapGesture {
                                self.hideKeyboard()
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
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .padding(.bottom, keyboardHeight) // 防止键盘挡住输入框
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 61)
                    // 点击空白处隐藏输入框
                    .onTapGesture {
                        self.hideKeyboard()
                    }
                    
                    // loading 组件
                    Loading()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .onAppear {
            Task {
                await self.getLocationPopularRecommend() // 获取周边热门地点
            }
        }
    }
    
    /// 隐藏键盘
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
    
    /// 获取周边热门地点
    private func getLocationPopularRecommend() async {
        let longitude = "\(region.center.longitude)"
        let latitude = "\(region.center.latitude)"
        
        do {
            let res = try await Api.shared.getLocationPopularRecommend(params: [
                //                "longitude": longitude,
//                "latitude": latitude,
                "longitude": "120.298501",
                "latitude": "30.41875",
            ])
            
            print("获取周边热门地点", res)
            
            guard res.code == 200, let data = res.data else {
                return
            }
            
            withAnimation {
                region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: data[0].latitude ?? 0, longitude: data[0].longitude ?? 0),
                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                )
                landmarks = data.map { item in
                    Landmark(coordinate: CLLocationCoordinate2D(latitude: item.latitude ?? 0, longitude: item.longitude ?? 0), name: item.name ?? "")
                }
            }
        } catch {
            print("获取周边热门地点异常")
        }
    }
  
    /// 完善步行打卡记录详情
    private func updateRouteDetail() async {
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
            ])
            
            loadingData.hiddenLoading()
            
            print("完善记录详情", res)
            
            if res.code == 200 {
                visibleSheet.toggle()
                
                moodColorActive = nil
                routeDetailForm.route_id = ""
                routeDetailForm.mood_color = ""
                routeDetailForm.address = ""
                routeDetailForm.address = ""
                routeDetailForm.content = ""
                routeDetailForm.travel_type = ""
                routeDetailForm.picture = []
            }
            
        } catch {
            print("完善步行打卡记录详情异常")
            loadingData.hiddenLoading()
        }
    }
    
    /// 获取用户信息
    private func getUserInfo() async {
        guard cacheInfo != nil else {
            return
        }
        
        do {
            let res = try await Api.shared.getUserInfo(params: ["user_id": cacheInfo!.user_id])

            print("我的页面获取的用户信息", res)
            
            guard res.code == 200, let data = res.data else {
                return
            }

            userInfo = data
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
    
    /// 请求获取位置权限
    private func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 获取当前位置并打卡
    private func onRecord() async {
        requestLocationAuthorization() // 请求获取位置权限

        switch locationDataManager.locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            let longitude = "\(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "")"
            let latitude = "\(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "")"

            print("当前经纬度", longitude, latitude)

            // await locationCreateRecord(longitude: longitude, latitude: latitude)
            await locationCreateRecord(longitude: "82.455646", latitude: "30.709778")
      
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
        .environmentObject(FriendsData())
        .environmentObject(RankingData())
        .environmentObject(MainData())
        .environmentObject(LoadingData())
}
