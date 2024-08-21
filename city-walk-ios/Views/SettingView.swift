//
//  SettingView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/20.
//

import SwiftUI

/// 用户信息编辑键
enum SheetKey {
    case avatar, nick_name, gender, mobile, preference_type, signature
}

/// 用户信息
struct UserInfo {
    var avatar: String
    var nick_name: String
    var gender: String
    var mobile: String
    var signature: String
    var preference_type: [String]
}

struct SettingView: View {
    /// 信息每一项度菜单
    struct InfoItemBar {
        var icon: String
        var key: SheetKey
        var title: String
        var color: String
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    /// 控制弹窗内容的 key
    @State private var sheetKey: SheetKey = .nick_name
    /// 是否显示编辑信息的弹窗
    @State private var isShowSetInfo = false
    /// token
    private let token = UserCache.shared.getToken()
    /// 是否跳转到登录页面
    @State private var isGoLoginView = false
    /// 是否显示退出登录的按钮确认框
    @State private var showingLogoutAlert = false
    /// 选择的头像图片
    @State private var selectAvatarImage: UIImage?
    /// 是否显示选择头像的对话框
    @State private var visibleSheet = false
    /// 信息设置的每一项
    private let infoItems = [
        InfoItemBar(icon: "person", key: .nick_name, title: "名字", color: "#EF7708"),
        InfoItemBar(icon: "circlebadge.2", key: .gender, title: "性别", color: "#0043E6"),
        InfoItemBar(icon: "smartphone", key: .mobile, title: "手机", color: "#FF323E"),
        InfoItemBar(icon: "hand.thumbsup", key: .preference_type, title: "偏好", color: "#EF7606"),
        InfoItemBar(icon: "lightbulb", key: .signature, title: "签名", color: "#0348F2"),
    ]
    /// 用户信息配置对象
    @State private var userInfo = UserInfo(
        avatar: "",
        nick_name: "",
        gender: "",
        mobile: "",
        signature: "",
        preference_type: []
    )
    /// 偏好列表
    @State private var preferenceList = preferences
  
    var body: some View {
        NavigationView {
            // 选项列表
            VStack {
                List {
                    // 基本信息
                    Section {
                        // 头像设置
                        Button {
                            self.visibleSheet.toggle()
                            self.sheetKey = .avatar
                        } label: {
                            HStack {
                                // 头像
                                AsyncImage(url: URL(string: userInfo.avatar)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60) // 设置图片的大小
                                        .clipShape(Circle()) // 将图片裁剪为圆形
                                } placeholder: {
                                    Circle()
                                        .fill(skeletonBackground)
                                        .frame(width: 60, height: 60)
                                }
                                
                                Text("我的头像")
                                    .foregroundStyle(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(hex: "#B5B5B5"))
                            }
                        }
                    }
            
                    // 信息
                    Section {
                        ForEach(infoItems, id: \.key) { item in
                            Button {
                                self.visibleSheet.toggle()
                                self.sheetKey = item.key
                            } label: {
                                HStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 36, height: 36)
                                        .foregroundColor(Color(hex: item.color)) // 修改为指定的颜色
                                        .overlay {
                                            Image(systemName: item.icon)
                                                .foregroundColor(.white)
                                        }
                                 
                                    Text(item.title)
                                        .foregroundStyle(.black)
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(hex: "#B5B5B5"))
                                }
                            }
                        }
                    }
                    
                    // 赞助
                    Section {
                        HStack {
                            Button {} label: {
                                Text("赞助")
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(hex: "#B5B5B5"))
                        }
                    }
                    
                    // 作者
                    Section(header: Text("作者")) {
                        Button {
                            if let url = URL(string: "https://github.com/Tyh2001/images/blob/master/my/we-chat.jpg") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Text("微信")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(hex: "#B5B5B5"))
                            }
                        }
                        
                        Button {
                            if let url = URL(string: "https://x.com/tyh20011") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Text("𝕏")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(hex: "#B5B5B5"))
                            }
                        }
                        
                        Button {
                            if let url = URL(string: "https://github.com/Tyh2001") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Text("Github")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(hex: "#B5B5B5"))
                            }
                        }
                    }
                    
                    // 应用服务
                    Section {
                        Button {} label: {
                            Text("给个好评")
                        }
                        
                        Button {} label: {
                            Text("分享给好友")
                        }
                        
                        Button {} label: {
                            Text("加入CityWalk开发者")
                        }
                    }
                    
                    // 退出登录
                    Section {
                        Button {
                            self.showingLogoutAlert.toggle()
                        } label: {
                            HStack {
                                Spacer()
                                Text("退出登录")
                                    .foregroundStyle(.red)
                                Spacer()
                            }
                        }
                        .alert(isPresented: $showingLogoutAlert) {
                            // 当 showingLogoutAlert 为 true 时，显示确认框
                            Alert(
                                title: Text("提示"),
                                message: Text("确定退出当前账号吗?"),
                                primaryButton: .destructive(Text("确定"), action: {
                                    UserCache.shared.clearAll()
                                    isGoLoginView = true
                                }),
                                secondaryButton: .cancel(Text("取消"))
                            )
                        }
                    }
                }
                .overlay(alignment: .top) {
                    VariableBlurView(maxBlurRadius: 12)
                        .frame(height: topSafeAreaInsets + globalNavigationBarHeight)
                        .ignoresSafeArea()
                }
                
                // 跳转到首页
                NavigationLink(destination: LoginView(), isActive: $isGoLoginView) {
                    EmptyView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("设置")
                    .font(.headline)
            }
        }
        .navigationBarItems(leading: BackButton(action: {
            self.presentationMode.wrappedValue.dismiss() // 返回上一个视图
        })) // 自定义返回按钮
        .background(.gray.opacity(0.1))
        // 登录成功之后跳转到首页
//        .navigationDestination(isPresented: $isGoLoginView) {
//            LoginView()
//        }
        .onAppear {
            self.loadCacheInfo() // 获取缓存的用户信息
        }
        // 修改信息的弹出层
        .sheet(isPresented: $visibleSheet) {
            SettingSheetView(
                sheetKey: $sheetKey,
                userInfo: $userInfo,
                preferenceList: $preferenceList,
                visibleSheet: $visibleSheet
            )
        }
    }
    
    /// 获取缓存的用户信息
    private func loadCacheInfo() {
        let cacheInfo = UserCache.shared.getInfo()
        
        if let info = cacheInfo, cacheInfo != nil {
            userInfo.avatar = info.avatar ?? defaultAvatar
            userInfo.gender = info.gender ?? ""
            userInfo.nick_name = info.nick_name
            userInfo.signature = info.signature ?? ""
//            userInfo.preference_type = info.preference_type ?? []
            userInfo.mobile = info.mobile ?? ""
        }
    }
    
    /// 设置用户信息
    private func setUserInfo() async {
        do {
            let res = try await Api.shared.setUserInfo(params: [
                "avatar": userInfo.avatar,
                "nick_name": userInfo.nick_name,
                "gender": userInfo.gender,
                "mobile": userInfo.mobile,
                "signature": userInfo.signature,
                "preference_type": userInfo.preference_type,
            ])
            
            print("设置用户信息结果", res)
            
            if let data = res.data, res.code == 200 {
                print("设置成功", data)
            }
        }
        catch {
            print("设置用户信息异常")
        }
    }
}

/// 设置 sheet 弹窗内容
struct SettingSheetView: View {
    /// 显示的内容 key
    @Binding var sheetKey: SheetKey
    /// 用户信息
    @Binding var userInfo: UserInfo
    /// 偏好列表
    @Binding var preferenceList: [Preference]
    /// 是否显示
    @Binding var visibleSheet: Bool
    
    /// 是否显示全屏对话框
    @State private var visibleFullScreenCover = false
    /// 选择的图片文件列表
    @State private var selectedImages: [UIImage] = []
    /// 最多选择的照片数量
    private let pictureMaxCount = 1
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                // 头像设置
                if sheetKey == .avatar {
                    Button {
                        self.visibleFullScreenCover.toggle()
                    } label: {
                        VStack {
                            if self.selectedImages.isEmpty {
                                AsyncImage(url: URL(string: userInfo.avatar)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 160, height: 160) // 设置图片的大小
                                        .clipShape(Circle()) // 将图片裁剪为圆形
                                } placeholder: {
                                    Circle()
                                        .fill(skeletonBackground)
                                        .frame(width: 160, height: 160)
                                }
                            }
                            else {
                                Image(uiImage: self.selectedImages[self.selectedImages.count - 1])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 160, height: 160)
                                    .clipShape(Circle())
                            }
                                
                            Text("上传头像")
                                .font(.system(size: 17))
                                .foregroundStyle(Color(hex: "#333333"))
                        }
                    }
                    // 选择照片的全屏弹出对话框
                    .fullScreenCover(isPresented: $visibleFullScreenCover, content: {
                        ImagePicker(selectedImages: $selectedImages, maxCount: pictureMaxCount)
                    })
                }
                // 名字
                else if sheetKey == .nick_name {
                    TextField("请输入名字", text: $userInfo.nick_name)
                        .padding(12)
                        .frame(height: 50)
                        .background(Color(hex: "#F0F0F0"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#D1D1D1"), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        .font(.system(size: 16))
                }
                // 性别
                else if sheetKey == .gender {
                    Text("性别")
                }
                // 手机
                else if sheetKey == .mobile {
                    TextField("请输入手机", text: $userInfo.mobile)
                        .padding(12)
                        .frame(height: 50)
                        .background(Color(hex: "#F0F0F0"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#D1D1D1"), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        .font(.system(size: 16))
                }
                // 偏好
                else if sheetKey == .preference_type {
                    Text("偏好")
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ]
                    
                    LazyVGrid(columns: columns) {
                        ForEach($preferenceList, id: \.key) { $item in
                            Button {
                                item.active.toggle()
                            } label: {
                                Text(item.title)
                                    .frame(height: 80)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: item.active ? "#F3943F" : "#ECECEC"))
                            }
                        }
                    }
                }
                // 签名
                else if sheetKey == .signature {
                    TextField("请输入签名", text: $userInfo.signature)
                        .padding(12)
                        .frame(height: 50)
                        .background(Color(hex: "#F0F0F0"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#D1D1D1"), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        .font(.system(size: 16))
                }
                
                Spacer()
                
                Button {
                    Task {
                        await self.submitUserInfo()
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
            .padding(.top, 30)
            .padding(.horizontal, 12)
        }
    }
    
    /// 提交用户信息
    private func submitUserInfo() async {
//        var params = [:]
        
        if sheetKey == .avatar {
            // 有选择照片
            if !selectedImages.isEmpty {
                let uploadedImageURLs = await uploadImages(images: selectedImages)
                
                userInfo.avatar = uploadedImageURLs[0]
                
                print("上传图片的结果", uploadedImageURLs)
            }
        }
        
        do {
            let res = try await Api.shared.setUserInfo(params: [
                "nick_name": userInfo.nick_name,
                "avatar": userInfo.avatar,
                "gender": userInfo.gender,
                "mobile": userInfo.mobile,
                "preference_type": userInfo.preference_type,
                "signature": userInfo.signature,
              
            ])
            
            print("设置结果", res)
            
            if let data = res.data, res.code == 200 {
                print(data)
                
                UserCache.shared.saveInfo(info: data)
                
                visibleSheet.toggle()
                
                if let avatar = data.avatar {
                    userInfo.avatar = avatar
                }
            }
        }
        catch {
            print("设置用户信息异常")
        }
    }
}

#Preview {
    SettingView()
//        .environmentObject(UserInfoData())
}
