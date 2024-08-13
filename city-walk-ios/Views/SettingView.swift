//
//  SettingView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/20.
//

import SwiftUI

struct SettingView: View {
//    let API = Api()
    
    /// 用户信息编辑键
    enum UserInfoKey {
        case nick_name, gender, city, email, mobel, signature
    }
    
    /// 创建用户信息设置项
//    struct UserInfoDataModel {
//        let title: String
//        let key: UserInfoKey
//        let icon: String
//        let color: Color
//    }

    /// 新的名字
    @State private var newNickName = ""
    /// 编辑用户信息的弹窗内部的编辑状态
    @State private var setUserInfoSheetState: UserInfoKey = .nick_name
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
                        } label: {
                            HStack {
//                                   // 头像
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
                        Button {
                            self.visibleSheet.toggle()
                        } label: {
                            HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.blue) // 修改为指定的颜色
                                    .overlay {
                                        Image(systemName: "swift")
                                            .foregroundColor(.white)
                                    }
                             
                                Text("名字")
                                    .foregroundStyle(.black)
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button {
                            self.visibleSheet.toggle()
                        } label: {
                            HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.blue) // 修改为指定的颜色
                                    .overlay {
                                        Image(systemName: "swift")
                                            .foregroundColor(.white)
                                    }
                             
                                Text("名字")
                                    .foregroundStyle(.black)
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button {
                            self.visibleSheet.toggle()
                        } label: {
                            HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.blue) // 修改为指定的颜色
                                    .overlay {
                                        Image(systemName: "swift")
                                            .foregroundColor(.white)
                                    }
                             
                                Text("名字")
                                    .foregroundStyle(.black)
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button {
                            self.visibleSheet.toggle()
                        } label: {
                            HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.blue) // 修改为指定的颜色
                                    .overlay {
                                        Image(systemName: "swift")
                                            .foregroundColor(.white)
                                    }
                             
                                Text("名字")
                                    .foregroundStyle(.black)
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button {
                            self.visibleSheet.toggle()
                        } label: {
                            HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.blue) // 修改为指定的颜色
                                    .overlay {
                                        Image(systemName: "swift")
                                            .foregroundColor(.white)
                                    }
                             
                                Text("名字")
                                    .foregroundStyle(.black)
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
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
                            if let url = URL(string: "https://twitter.com/tyh20011") {
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
            ImagePicker(selectedImage: $selectAvatarImage, visible: $visibleSheet) {
                if let image = selectAvatarImage {
                    self.uploadImageToBackend(image: image)
                }
            }
        }
        // 设置信息
//        .sheet(isPresented: $isShowSetInfo) {
//            NavigationStack {
//                VStack {
//                    // 名字
//                    if self.setUserInfoSheetState == .nick_name {
//                        HStack {
//                            Text("名字")
//                            TextField("请输入名字", text: $newNickName)
//                        }
//                    }
//                    // 邮箱
//                    else if self.setUserInfoSheetState == .email {
//                        HStack {
//                            Text("邮箱")
//                            TextField("请输入邮箱", text: $newNickName)
//                        }
//                    }
//
//                    Spacer()
//                }
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button {} label: {
//                            Text("保存")
//                        }
//                    }
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        Button {
//                            self.isShowAvatarSelectSheet.toggle()
//                        } label: {
//                            Text("取消")
//                        }
//                    }
//                }
//            }
//        }
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
            } else {
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
