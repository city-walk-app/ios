//
//  SettingView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/20.
//

import Combine
import Kingfisher
import SwiftUI

/// 个性签名最大输入长度
private let signatureMaxLength = 255
/// 手机最大输入长度
private let mobileMaxLength = 11
/// 昵称最大输入长度
private let nickNameMaxLength = 12
/// 信息设置的每一项
private let infoItems = [
    InfoItemBar(icon: "person", key: .nick_name, title: "名字", color: "#EF7708"),
    InfoItemBar(icon: "circlebadge.2", key: .gender, title: "性别", color: "#0043E6"),
    InfoItemBar(icon: "smartphone", key: .mobile, title: "手机", color: "#FF323E"),
    InfoItemBar(icon: "lightbulb", key: .signature, title: "签名", color: "#0348F2"),
]

/// 设置
struct SettingView: View {
    /// 进入需要激活的弹窗类型
    var acitveKey: SettingSheetKey? = nil
    
    /// 缓存数据
    @EnvironmentObject private var storageData: StorageData
    /// 全球的数据
    @EnvironmentObject private var globalData: GlobalData
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    /// 控制弹窗内容的 key
    @State private var sheetKey: SettingSheetKey = .nick_name
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
                            self.visibleSheet.toggle()
                        } label: {
                            HStack {
                                // 头像
                                KFImage(URL(string: userInfo.avatar))
                                    .placeholder {
                                        Circle()
                                            .fill(Color("skeleton-background"))
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
                    
                    // 作者
                    Section(header: Text("作者")) {
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
            
            /// 如果点击进入需要直接修改信息
            if let acitveKey = acitveKey {
                self.sheetKey = acitveKey
                self.visibleSheet.toggle()
            }
        }
        // 修改信息的弹出层
        .sheet(isPresented: $visibleSheet, onDismiss: {
            self.loadCacheInfo() // 获取缓存的用户信息
        }) {
            SettingSheetView(
                storageData: storageData,
                globalData: globalData,
                sheetKey: $sheetKey,
                userInfo: $userInfo,
                visibleSheet: $visibleSheet
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
    /// 全球的数据
    let globalData: GlobalData
    
    /// 最多选择的照片数量
    private let pictureMaxCount = 1
    
    /// 显示的内容 key
    @Binding var sheetKey: SettingSheetKey
    /// 用户信息
    @Binding var userInfo: UserInfo
    /// 是否显示
    @Binding var visibleSheet: Bool
    
    /// 是否显示全屏对话框
    @State private var visibleFullScreenCover = false
    /// 选择的图片文件列表
    @State private var selectedImages: [UIImage] = []
    /// 提交信息按钮是否禁用
    @State private var isSubmitInfoButtonDisabled = false
    /// 输入框是否获取焦点
    @FocusState private var focus: SettingSheetKey?
    
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
                                            .fill(Color("skeleton-background"))
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
                    ZStack(alignment: .trailing) {
                        TextField("请输入名字", text: $userInfo.nick_name)
                            .frame(height: 58)
                            .padding(.horizontal, 23)
                            .background(self.focus == .nick_name ? Color.clear : Color("background-3"))
                            .keyboardType(.default)
                            .focused($focus, equals: .nick_name)
                            .submitLabel(.done)
                            .foregroundStyle(Color("text-1"))
                            .onReceive(Just(userInfo.nick_name), perform: { _ in
                                limitMaxLength(content: &userInfo.nick_name, maxLength: nickNameMaxLength)
                            })
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(self.focus == .nick_name ? Color("theme-1") : Color.clear, lineWidth: 2)
                            )
                            .onChange(of: userInfo.nick_name) {
                                getSubmitInfoButtonDisabled() // 提交信息按钮是否禁用
                            }

                        Button {
                            self.focus = .nick_name
                            userInfo.nick_name = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color("text-3").opacity(0.8))
                                .padding(.trailing, 23)
                        }
                    }
                    HStack {
                        Spacer()
                        
                        Text("\(userInfo.nick_name.count)/\(nickNameMaxLength)")
                            .font(.system(size: 14))
                            .foregroundStyle(Color("text-2"))
                    }
                    .padding(.horizontal, 2)
                    .padding(.top, 6)
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
                        .frame(height: 58)
                        .padding(.horizontal, 23)
                        .background(self.focus == .mobile ? Color.clear : Color("background-3"))
                        .keyboardType(.numberPad)
                        .focused($focus, equals: .mobile)
                        .foregroundStyle(Color("text-1"))
                        .onReceive(Just(userInfo.mobile), perform: { _ in
                            limitMaxLength(content: &userInfo.mobile, maxLength: mobileMaxLength)
                        })
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(self.focus == .mobile ? Color("theme-1") : Color.clear, lineWidth: 2)
                        )
                        .onChange(of: userInfo.mobile) {
                            getSubmitInfoButtonDisabled() // 提交信息按钮是否禁用
                        }
                }
                // 签名
                else if sheetKey == .signature {
                    TextField("Comment", text: $userInfo.signature, prompt: Text("请输入签名"), axis: .vertical)
                        .lineLimit(4 ... 10)
                        .padding(23)
                        .background(self.focus == .signature ? Color.clear : Color("background-3"))
                        .keyboardType(.numberPad)
                        .focused($focus, equals: .signature)
                        .foregroundStyle(Color("text-1"))
                        .onReceive(Just(userInfo.signature), perform: { _ in
                            limitMaxLength(content: &userInfo.signature, maxLength: signatureMaxLength)
                        })
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(self.focus == .signature ? Color("theme-1") : Color.clear, lineWidth: 2)
                        )
                      
                    HStack {
                        Spacer()
                        
                        Text("\(userInfo.signature.count)/\(signatureMaxLength)")
                            .font(.system(size: 14))
                            .foregroundStyle(Color("text-2"))
                    }
                    .padding(.horizontal, 2)
                    .padding(.top, 6)
                }
                
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 30)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.visibleSheet.toggle()
                    } label: {
                        Image(systemName: "chevron.left")
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color("text-2"))
                            .bold()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(self.getSheetTitle(key: self.sheetKey))
                        .font(.headline)
                        .foregroundStyle(Color("text-1"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await self.submitUserInfo() // 提交用户信息
                        }
                    } label: {
                        Text("就这样")
                            .frame(width: 70, height: 38)
                            .font(.system(size: 13))
                            .foregroundStyle(.white)
                            .background(isSubmitInfoButtonDisabled ? Color("theme-1").opacity(0.5) : Color("theme-1"))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .disabled(isSubmitInfoButtonDisabled)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                getSubmitInfoButtonDisabled() // 提交信息按钮是否禁用
                
                withAnimation {
                    self.focus = self.sheetKey
                }
            }
        }
    }
    
    /// 提交信息按钮是否禁用
    /// - Returns: 是否禁用
    private func getSubmitInfoButtonDisabled() {
        if sheetKey == .mobile {
            if userInfo.mobile.count == 0 {
                isSubmitInfoButtonDisabled = false
                return
            }

            isSubmitInfoButtonDisabled = userInfo.mobile.count != mobileMaxLength
            return
        }
        else if sheetKey == .nick_name {
            isSubmitInfoButtonDisabled = userInfo.nick_name == ""
            return
        }
        else if sheetKey == .signature {
            isSubmitInfoButtonDisabled = userInfo.signature == ""
            return
        }
        
        isSubmitInfoButtonDisabled = false
    }
    
    /// 设置当前标题
    /// - Parameter key: key
    /// - Returns: 标题
    private func getSheetTitle(key: SettingSheetKey) -> String {
        switch key {
        case .avatar:
            return "头像"
        case .gender:
            return "性别"
        case .mobile:
            return "手机"
        case .nick_name:
            return "名字"
        case .signature:
            return "签名"
        }
    }
    
    /// 提交用户信息
    private func submitUserInfo() async {
        if sheetKey == .avatar {
            // 有选择照片
            if !selectedImages.isEmpty {
                isSubmitInfoButtonDisabled = true
                let uploadedImageURLs = await uploadImages(images: selectedImages)
                
                userInfo.avatar = uploadedImageURLs[0]
                
                print("上传图片的结果", uploadedImageURLs)
            }
        }
        
        do {
            isSubmitInfoButtonDisabled = true
            
            let res = try await Api.shared.setUserInfo(params: [
                "nick_name": userInfo.nick_name,
                "avatar": userInfo.avatar,
                "gender": userInfo.gender.rawValue,
                "mobile": userInfo.mobile,
                "signature": userInfo.signature,
            ])
            
            print("设置结果", res)
            
            guard res.code == 200, let data = res.data else {
                globalData.showToast(title: "提交异常")
                isSubmitInfoButtonDisabled = false
                return
            }
            
            storageData.saveUserInfo(info: data)
                
            visibleSheet.toggle()
            globalData.showToast(title: "修改成功")
            isSubmitInfoButtonDisabled = false
        }
        catch {
            print("设置用户信息异常")
            globalData.showToast(title: "提交异常")
            isSubmitInfoButtonDisabled = false
        }
    }
}

/// 用户信息编辑键
enum SettingSheetKey {
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
    var key: SettingSheetKey
    var title: String
    var color: String
}

#Preview {
    SettingView()
        .environmentObject(StorageData())
        .environmentObject(GlobalData())
}
