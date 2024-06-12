//
//  LoginView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import Combine
import Foundation
import SwiftUI

struct LoginView: View {
    let API = ApiBasic()
    
    /// 聚焦的输入框枚举
    enum FocusedField: Hashable {
        case email, code, name
    }

    /// 步骤枚举
    enum LoginState {
        case login, name, avatar
    }

    /// 缓存的用户信息
    private let sharedInfo = UserCache.shared.getInfo()
    /// 当前登录页的状态
    @State var loginState: LoginState = .login
    /// 邮箱
    @State private var email = ""
    /// 验证码
    @State private var code = ""
    /// 名字
    @State private var nickName = ""
    /// 当前登录的用户 id，只在新用户注册时使用
    @State private var userId = 0
    /// 登录按钮是否禁用
    @State private var isLoginButtonDisabled = false
    /// 是否跳转到首页
    @State private var isToHomeView = false
    /// 输入框是否获取焦点
    @FocusState var focus: FocusedField?
    /// 是否在倒计时中
    @State private var isCountingDown = false
    /// 设置倒计时秒数
    @State private var countdownSeconds = 10
    /// 创建一个每秒触发一次的定时器
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect() // 创建一个每秒触发一次的定时器
    /// 选择的头像图片
    @State private var selectAvatarImage: UIImage?
    /// 是否显示选择头像的对话框
    @State private var isShowAvatarSelectSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景图
                Image("background-1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                // 登录操作
                ScrollView {
                    VStack(spacing: 20) {
                        // 登录状态
                        if loginState == .login {
                            LoginFormView(
                                email: $email,
                                countdownSeconds: $countdownSeconds,
                                isCountingDown: $isCountingDown,
                                code: $code,
                                focus: $focus,
                                isLoginButtonDisabled: $isLoginButtonDisabled,
                                validateEmail: validateEmail,
                                userLoginEmail: userLoginEmail
                            )
                        }
                        // 设置名字步骤
                        else if loginState == .name {
                            LoginNameView(
                                nickName: $nickName,
                                setUserInfo: setUserInfo
                            )
                        }
                        // 设置头像步骤
                        else if loginState == .avatar {
                            LoginAvatarView(
                                selectAvatarImage: $selectAvatarImage,
                                isShowAvatarSelectSheet: $isShowAvatarSelectSheet,
                                uploadImageToBackend: uploadImageToBackend
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                    .padding(.top, 80)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            // 点击空白处隐藏输入框
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                // 页面展示的时候将验证码输入框聚焦
                // https://fatbobman.com/zh/posts/textfield-event-focus-keyboard/
                // 在视图初始化阶段赋值是无效的。即使在 onAppear 中，也必须要有一定延时才能让 TextField 焦点
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.focus = .email
                }
            }
            .onReceive(timer) { _ in
                if isCountingDown {
                    if countdownSeconds > 0 {
                        countdownSeconds -= 1 // 每秒减少一秒
                    } else {
                        isCountingDown = false // 倒计时结束后停止倒计时
                    }
                }
            }
        }
        // 登录成功之后跳转到首页
        .navigationDestination(isPresented: $isToHomeView) {
            HomeView()
        }
    }
    
    /// 检测是否为邮箱格式
    private func isValidEmail(_ email: String) -> Bool {
        // 使用正则表达式验证邮箱格式
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    /// 获取邮箱验证码
    private func emailSend() {
        isCountingDown = true // 开启倒计时
        countdownSeconds = 10 // 恢复时间
        
        API.emailSend(params: ["email": email]) { result in
            switch result {
            case .success(let data):
                if data.code == 200 {
                    // 改变文本框聚焦状态
                    self.focus = .code
                }
            case .failure:
                print("获取邮箱验证码失败")
            }
        }
    }
    
    /// 验证邮箱
    private func validateEmail() {
        // 邮箱格式验证
        if email != "" && isValidEmail(email) {
            print("获取验证码")
            emailSend() // 获取邮箱验证码
            
        } else {
            print("邮箱格式错误")
        }
    }
    
    /// 邮箱验证码登录
    private func userLoginEmail() {
        isLoginButtonDisabled = true
        
        API.userLoginEmail(params: ["email": email, "code": code]) { result in
            
            self.isLoginButtonDisabled = false
            
            switch result {
            case .success(let data):
                if data.code == 200 && data.data != nil {
                    // 如果是新用户，继续完善信息
                    if data.data!.is_new_user {
                        self.userId = data.data!.id
                        
                        withAnimation {
                            self.loginState = .name
                            self.focus = .name
                        }
                    }
                    // 否则跳转到首页
                    else {
                        UserCache.shared.saveInfo(info: data.data!)
                        self.isToHomeView = true // 跳转到首页
                    }
                }
            case .failure:
                print("邮箱验证登录失败")
            }
        }
    }
    
    /// 检测输入框最大长度
    /// - Parameters:
    ///   - content: 输入框的内容
    ///   - maxLength: 最大长度
    private func limitMaxLength(content: inout String, maxLength: Int) {
        if content.count > maxLength {
            content = String(content.prefix(maxLength))
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
        request.setValue(sharedInfo!.token, forHTTPHeaderField: "token") // 添加 token
        
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
                self.isToHomeView.toggle()
            } else {
                print("失败 to upload image")
            }
        }
        
        task.resume()
    }
    
    /// 创建请求体参数
    /// - Parameters:
    ///   - imageData:
    ///   - boundary:
    ///   - fieldName:
    ///   - fileName:
    /// - Returns:
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
    
    /// 设置用户信息
    private func setUserInfo() {
        print("nick", nickName)
        API.setUserInfo(params: ["nick_name": nickName]) { result in
            print(result)
            switch result {
            case .success(let data):
                if data.code == 200 {
                    print("设置成功")
                    withAnimation {
                        self.loginState = .avatar
                    }
                }
            case .failure:
                print("设置失败")
            }
        }
    }
}

#Preview {
    LoginView()
}
