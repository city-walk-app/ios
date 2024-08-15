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
    
    struct InfoItemBar {
        var icon: String
        var key: SheetKey
        var title: String
        var color: String
    }

    /// 控制弹窗内容的 key
    @State private var sheetKey: SheetKey?
    /// 是否显示编辑信息的弹窗
    @State private var isShowSetInfo = false
    /// token
    private let token = UserCache.shared.getToken()
    private let userInfo = UserCache.shared.getInfo()
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
                                AsyncImage(url: URL(string: self.userInfo?.avatar ?? defaultAvatar)) { image in
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
                                    .foregroundStyle(.gray)
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
                                        .foregroundColor(Color(hex: item.color)) // 修改为指定的颜色
                                        .overlay {
                                            Image(systemName: item.icon)
                                                .foregroundColor(.white)
                                        }
                                 
                                    Text(item.title)
                                        .foregroundStyle(.black)
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    
                    // 赞助
                    Section {
                        Button {} label: {
                            Text("赞助")
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
                                    .foregroundColor(.gray)
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
                                    .foregroundColor(.gray)
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
                                    .foregroundColor(.gray)
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
                Text("名字")
            }
            // 性别
            else if sheetKey == .gender {
                Text("性别")
            }
            // 手机
            else if sheetKey == .mobile {
                Text("手机")
            }
            // 偏好
            else if sheetKey == .preference_type {
                Text("偏好")
            }
            // 签名
            else if sheetKey == .signature {
                Text("签名")
            }
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
