//
//  SettingView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/20.
//

import Kingfisher
import SwiftUI

/// 信息设置的每一项
private let infoItems = [
    InfoItemBar(icon: "person", key: .nick_name, title: "名字", color: "#EF7708"),
    InfoItemBar(icon: "circlebadge.2", key: .gender, title: "性别", color: "#0043E6"),
    InfoItemBar(icon: "smartphone", key: .mobile, title: "手机", color: "#FF323E"),
    InfoItemBar(icon: "lightbulb", key: .signature, title: "签名", color: "#0348F2"),
]

struct SettingView: View {
    /// 缓存数据
    @EnvironmentObject private var storageData: StorageData

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    /// 控制弹窗内容的 key
    @State private var sheetKey: SheetKey = .nick_name
    /// 是否显示编辑信息的弹窗
    @State private var isShowSetInfo = false
    /// 是否跳转到登录页面
    @State private var isGoLoginView = false
    /// 是否显示退出登录的按钮确认框
    @State private var showingLogoutAlert = false
    /// 选择的头像图片
    @State private var selectAvatarImage: UIImage?
    /// 是否显示选择头像的对话框
    @State private var visibleSheet = false
    /// 用户信息配置对象
    @State private var userInfo = UserInfo(
        avatar: "",
        nick_name: "",
        gender: .male,
        mobile: "",
        signature: ""
    )
    /// 设置标题
    @State private var title = "设置"
  
    var body: some View {
        NavigationView {
            // 选项列表
            VStack {
                List {
                    // 基本信息
                    Section {
                        // 头像设置
                        Button {
                            self.sheetKey = .avatar
                            self.title = "头像"
                            self.visibleSheet.toggle()
                        } label: {
                            HStack {
                                // 头像
                                KFImage(URL(string: userInfo.avatar))
                                    .placeholder {
                                        Circle()
                                            .fill(skeletonBackground)
                                            .frame(width: 60, height: 60)
                                    }
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                             
                                Text("我的头像")
                                    .foregroundColor(Color("text-1"))
                                    .padding(.leading, 10)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("text-1"))
                            }
                        }
                    }
            
                    // 信息
                    Section {
                        ForEach(infoItems, id: \.key) { item in
                            Button {
                                self.title = item.title
                                self.sheetKey = item.key
                                self.visibleSheet.toggle()
                            } label: {
                                HStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 36, height: 36)
                                        .foregroundColor(Color(hex: item.color))
                                        .overlay {
                                            Image(systemName: item.icon)
                                                .foregroundColor(.white)
                                        }
                                 
                                    Text(item.title)
                                        .foregroundColor(Color("text-1"))
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(hex: "#B5B5B5"))
                                }
                            }
                        }
                    }
                    
                    // 赞助
//                    Section {
//                        HStack {
//                            Button {} label: {
//                                Text("赞助")
//                            }
//
//                            Spacer()
//
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(Color(hex: "#B5B5B5"))
//                        }
//                    }
                    
                    // 作者
                    Section(header: Text("作者")) {
//                        Button {} label: {
//                            HStack {
//                                Text("微信")
//
//                                Spacer()
//
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(Color(hex: "#B5B5B5"))
//                            }
//                        }
                        
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
//                        Button {} label: {
//                            Text("给个好评")
//                        }
//
//                        Button {} label: {
//                            Text("分享给好友")
//                        }
                        
                        Button {
                            if let url = URL(string: "https://github.com/city-walk-app") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Text("加入CityWalk开发者")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(hex: "#B5B5B5"))
                            }
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
                            Alert(
                                title: Text("提示"),
                                message: Text("确定退出当前账号吗?"),
                                primaryButton: .destructive(Text("确定"), action: {
                                    storageData.clearCache()
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
        .sheet(isPresented: $visibleSheet, onDismiss: {
            self.loadCacheInfo() // 获取缓存的用户信息
        }) {
            SettingSheetView(
                storageData: storageData,
                sheetKey: $sheetKey,
                userInfo: $userInfo,
                visibleSheet: $visibleSheet,
                title: $title
            )
        }
    }
    
    /// 获取缓存的用户信息
    private func loadCacheInfo() {
        guard let info = storageData.userInfo else {
            isGoLoginView = true
            return
        }
        
        userInfo.avatar = info.avatar ?? defaultAvatar
        userInfo.gender = Genders.from(value: info.gender ?? "")
        userInfo.nick_name = info.nick_name
        userInfo.signature = info.signature ?? ""
        userInfo.mobile = info.mobile ?? ""
    }
}

/// 设置 sheet 弹窗内容
private struct SettingSheetView: View {
    /// 缓存数据
    let storageData: StorageData
    
    /// 最多选择的照片数量
    private let pictureMaxCount = 1
    
    /// 显示的内容 key
    @Binding var sheetKey: SheetKey
    /// 用户信息
    @Binding var userInfo: UserInfo
    /// 是否显示
    @Binding var visibleSheet: Bool
    /// 标题
    @Binding var title: String
    
    /// 是否显示全屏对话框
    @State private var visibleFullScreenCover = false
    /// 选择的图片文件列表
    @State private var selectedImages: [UIImage] = []
    
    /// 性别列表
    private let genders: [Genders] = Genders.allCases
   
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
                                KFImage(URL(string: userInfo.avatar))
                                    .placeholder {
                                        Circle()
                                            .fill(skeletonBackground)
                                            .frame(width: 160, height: 160)
                                    }
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 160, height: 160)
                                    .clipShape(Circle())
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
                                .foregroundStyle(Color("text-1"))
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
                        .font(.system(size: 16))
                }
                // 性别
                else if sheetKey == .gender {
                    VStack {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ]) {
                            Button {
                                withAnimation {
                                    self.userInfo.gender = .male
                                }
                            } label: {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(userInfo.gender == .male ? Color("theme-1") : Color(hex: "#eeeeee"))
                                    .frame(height: 160)
                                    .overlay(alignment: .bottomTrailing) {
                                        Text("\(genders[0].sex)")
                                            .padding(20)
                                            .font(.system(size: 21))
                                            .bold()
                                            .foregroundStyle(userInfo.gender == .male ? Color.white : Color(hex: "#333333"))
                                    }
                            }
                                
                            Button {
                                withAnimation {
                                    self.userInfo.gender = .female
                                }
                            } label: {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(userInfo.gender == .female ? Color("theme-1") : Color(hex: "#eeeeee"))
                                    .frame(height: 160)
                                    .overlay(alignment: .bottomTrailing) {
                                        Text("\(genders[1].sex)")
                                            .padding(20)
                                            .font(.system(size: 21))
                                            .bold()
                                            .foregroundStyle(userInfo.gender == .female ? Color.white : Color(hex: "#333333"))
                                    }
                            }
                        }
                        
                        Button {
                            withAnimation {
                                self.userInfo.gender = .privacy
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(userInfo.gender == .privacy ? Color("theme-1") : Color(hex: "#eeeeee"))
                                .frame(width: .infinity, height: 90)
                                .overlay(alignment: .center) {
                                    Text("\(genders[2].sex)")
                                        .padding()
                                        .font(.system(size: 21))
                                        .bold()
                                        .foregroundStyle(userInfo.gender == .privacy ? Color.white : Color(hex: "#333333"))
                                }
                        }
                    }
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
                        .font(.system(size: 16))
                }
                // 签名
                else if sheetKey == .signature {
                    TextField("Comment", text: $userInfo.signature, prompt: Text("请输入签名"), axis: .vertical)
                        .lineLimit(4 ... 8)
                        .submitLabel(.done)
                        .autocapitalization(.none) // 禁止任何自动大写
                        .disableAutocorrection(true) // 禁止自动更正
                        .foregroundStyle(Color(hex: "#333333"))
                        .border(Color(hex: "#eeeeee"), width: 2)
                        .onChange(of: userInfo.signature) {
                            // 当内容变化时执行的代码
                            if userInfo.signature.contains("\n") {
                                userInfo.signature = userInfo.signature.replacingOccurrences(of: "\n", with: "")
                            }
                        }
                }
                
                Spacer()
                
                Button {
                    Task {
                        await self.submitUserInfo() // 提交用户信息
                    }
                } label: {
                    Text("就这样")
                        .frame(width: 160, height: 48)
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .background(Color("theme-1"))
                        .border(Color("theme-1"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color("theme-1"), lineWidth: 1) // 使用 overlay 添加圆角边框
                        )
                }
            }
            .padding(.horizontal, 18)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color("text-1"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.visibleSheet.toggle()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color("text-2"))
                    }
                }
            }
        }
    }
    
    /// 提交用户信息
    private func submitUserInfo() async {
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
                "gender": userInfo.gender.rawValue,
                "mobile": userInfo.mobile,
                "signature": userInfo.signature,
            ])
            
            print("设置结果", res)
            
            guard res.code == 200, let data = res.data else {
                return
            }
            
            storageData.saveUserInfo(info: data)
                
            visibleSheet.toggle()
        }
        catch {
            print("设置用户信息异常")
        }
    }
}

/// 用户信息编辑键
private enum SheetKey {
    case avatar, nick_name, gender, mobile, signature
}

/// 用户信息
private struct UserInfo {
    var avatar: String
    var nick_name: String
    var gender: Genders
    var mobile: String
    var signature: String
}

/// 信息每一项度菜单
private struct InfoItemBar {
    var icon: String
    var key: SheetKey
    var title: String
    var color: String
}

#Preview {
    SettingView()
        .environmentObject(StorageData())
}
