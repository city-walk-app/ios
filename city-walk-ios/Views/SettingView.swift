//
//  SettingView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/20.
//

import SwiftUI

struct SettingView: View {
    /// 用户信息编辑键
    enum SheetKey {
        case avatar, nick_name, gender, mobile, preference_type, signature
    }
    
    /// 信息每一项度菜单
    struct InfoItemBar {
        var icon: String
        var key: SheetKey
        var title: String
        var color: String
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
                                    // 占位符，图片加载时显示的内容
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60) // 占位符的大小与图片一致
                                        .overlay(Text("加载失败").foregroundColor(.white))
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
            }
            .navigationTitle("设置")
        }
        // 跳转到登录页面
        .navigationDestination(isPresented: $isGoLoginView, destination: {
            LoginView()
        })
        // 选择头像的弹出层
        .sheet(isPresented: $visibleSheet) {
            NavigationStack {
                VStack(alignment: .center) {
                    // 头像设置
                    if sheetKey == .avatar {
                        ImagePicker(selectedImage: $selectAvatarImage, visible: $visibleSheet) {
                            if let image = selectAvatarImage {
                                self.uploadImageToBackend(image: image)
                            }
                        }
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
                    
                    Button {} label: {
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
        .onAppear {
            self.loadCacheInfo() // 获取缓存的用户信息
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
            userInfo.preference_type = info.preference_type ?? []
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
    
    /// 头像上传
    /// - Parameter image: 图片对象
    private func uploadImageToBackend(image: UIImage) {
        print("avatar", image)
        
        guard let url = URL(string: BASE_URL + "/user/info/up_avatar") else {
            print("Invalid URL")
            return
        }
        
        print("url", url)
            
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
            
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "token") // 添加 token
        
        let imageData = image.jpegData(compressionQuality: 1.0)
        let body = createBody(with: imageData, boundary: boundary, fieldName: "image", fileName: "image")
            
        request.httpBody = body
            
        let session = URLSession.shared
        let task = session.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error uploading image: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("成功", httpResponse)
            }
            else {
                print("失败 to upload image")
            }
        }
            
        task.resume()
    }
    
    /// 创建请求体
    private func createBody(with imageData: Data?, boundary: String, fieldName: String, fileName: String) -> Data {
        var body = Data()
            
        if let imageData = imageData {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
            body.appendString("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.appendString("\r\n")
        }
            
        body.appendString("--\(boundary)--\r\n")
            
        return body
    }
}

extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

#Preview {
    SettingView()
//        .environmentObject(UserInfoData())
}
