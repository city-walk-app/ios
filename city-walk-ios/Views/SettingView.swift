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
    struct UserInfoDataModel {
        let title: String
        let key: UserInfoKey
        let icon: String
        let color: Color
    }

    /// 新的名字
    @State private var newNickName = ""
    /// 编辑用户信息的弹窗内部的编辑状态
    @State private var setUserInfoSheetState: UserInfoKey = .nick_name
    /// 是否显示编辑信息的弹窗
    @State private var isShowSetInfo = false
    /// token
    private let token = UserCache.shared.getInfo()?.token
    /// 是否跳转到登录页面
    @State private var isGoLoginView = false
    /// 是否显示退出登录的按钮确认框
    @State private var showingLogoutAlert = false
    /// 选择的头像图片
    @State private var selectAvatarImage: UIImage?
    /// 是否显示选择头像的对话框
    @State private var isShowAvatarSelectSheet = false
    /// 用户信息
    @EnvironmentObject var userInfoDataModel: UserInfoData
    /// 用户信息列表选项
    let userInfoItems: [UserInfoDataModel] = [
        UserInfoDataModel(title: "名字", key: .nick_name, icon: "person.fill", color: .blue),
        UserInfoDataModel(title: "性别", key: .gender, icon: "mic.square.fill", color: .red),
        UserInfoDataModel(title: "邮箱", key: .email, icon: "person.fill", color: .blue),
        UserInfoDataModel(title: "手机", key: .mobel, icon: "circle.square", color: .orange),
        UserInfoDataModel(title: "签名", key: .signature, icon: "house", color: .green)
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
                            self.isShowAvatarSelectSheet.toggle()
                        } label: {
                            HStack {
                                if let image = selectAvatarImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                } else {
                                    URLImage(url: URL(string: "\(BASE_URL)/\(userInfoDataModel.data!.avatar ?? "")")!)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 70, height: 70)
                                        .mask(Circle())
                                }
                                
                                Text("欢迎使用 City Walk!")
                                    .foregroundStyle(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                            }
                        }
                        // 选择头像的弹出层
                        .sheet(isPresented: $isShowAvatarSelectSheet) {
                            ImagePicker(selectedImage: $selectAvatarImage, isImagePickerPresented: $isShowAvatarSelectSheet) {
                                if let image = selectAvatarImage {
                                    self.uploadImageToBackend(image: image)
                                }
                            }
                        }
                    }
                    
                    // 信息
                    Section {
                        ForEach(userInfoItems.indices, id: \.self) { index in
                            Button {
                                self.isShowSetInfo = true
                                self.setUserInfoSheetState = userInfoItems[index].key
                                
                            } label: {
                                HStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 36, height: 36)
                                        .foregroundColor(userInfoItems[index].color) // 修改为指定的颜色
                                        .overlay {
                                            Image(systemName: userInfoItems[index].icon)
                                                .foregroundColor(.white)
                                        }
                                    
                                    Text(userInfoItems[index].title)
                                        .foregroundStyle(.black)
                                    
                                    Spacer()
                                    
                                    // 使用 userInfoDataModel.data 字典中对应 key 的值作为文本
                                    //                                if let value = userInfoDataModel.data?[userInfoItems[index].key] {
                                    //                                    Text(value)
                                    //                                }
                                    
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
                                    UserCache.shared.deleteInfo()
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
        // 设置信息
        .sheet(isPresented: $isShowSetInfo) {
            NavigationStack {
                VStack {
                    // 名字
                    if self.setUserInfoSheetState == .nick_name {
                        HStack {
                            Text("名字")
                            TextField("请输入名字", text: $newNickName)
                        }
                    }
                    // 邮箱
                    else if self.setUserInfoSheetState == .email {
                        HStack {
                            Text("邮箱")
                            TextField("请输入邮箱", text: $newNickName)
                        }
                    }
                    
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {} label: {
                            Text("保存")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self.isShowAvatarSelectSheet.toggle()
                        } label: {
                            Text("取消")
                        }
                    }
                }
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
        .environmentObject(UserInfoData())
}
