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

    /// 当前登录页的状态
    @State var loginState: LoginState = .avatar
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
            VStack(spacing: 20) {
                // 登录状态
                if loginState == .login {
                    // 标题
                    HStack {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .mask(Circle())

                        Text("Welcome")
                            .font(.title)
                            .bold()

                        Spacer()
                    }

                    /// 邮箱
                    HStack {
                        TextField("请输入邮箱", text: $email)
                            .padding(.vertical, 20)
                            .keyboardType(.URL)
                            .focused($focus, equals: .email)
                            .textContentType(.emailAddress)
                            .submitLabel(.next)
                            .onReceive(Just(code), perform: { _ in
                                limitMaxLength(content: &code, maxLength: 50)
                            })
                            .onSubmit { // 监听提交事件
                                self.validateEmail()
                            }

                        // 获取验证码按钮
                        if isCountingDown {
                            Text("\(countdownSeconds)s后再试")
                                .foregroundStyle(.gray)
                        } else {
                            Button {
                                validateEmail()
                            } label: {
                                Text("获取验证码")
                            }
                        }
                    }
                    .padding(.horizontal, 23)
                    .background(.white, in: RoundedRectangle(cornerRadius: 35))
                    .padding(.top, 20)

                    /// 验证码
                    HStack {
                        TextField("邮箱验证码", text: $code)
                            .keyboardType(.numberPad) // 设置键盘类型为数字键盘
                            .textContentType(.oneTimeCode) // 设置内容类型为一次性代码，以便系统知道右下角按钮应该显示为“确认”
                            .padding(.vertical, 20)
                            .focused($focus, equals: .code)
                            .submitLabel(.return)
                            .onReceive(Just(code), perform: { _ in
                                limitMaxLength(content: &code, maxLength: 6)
                            }) // 最大长度为 6 位
                    }
                    .padding(.horizontal, 23)
                    .background(.white, in: RoundedRectangle(cornerRadius: 35))

                    /// 登录按钮
                    Button {
                        self.userLoginEmail()
                    } label: {
                        Circle()
                            .frame(width: 80, height: 80)
                            .overlay {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20))
                            }
                    }
                    .disabled(isLoginButtonDisabled)
                }
                // 设置名字步骤
                else if loginState == .name {
                    Text("设置你的名字")
                    TextField("你的名字", text: $nickName)

                    Button {
                        withAnimation {
                            self.loginState = .avatar
                        }
                    } label: {
                        Text("确定")
                    }
                }
                // 设置头像步骤
                else if loginState == .avatar {
                    VStack {
                        // 点击选择头像
                        Button {
                            self.isShowAvatarSelectSheet.toggle()
                        } label: {
                            VStack {
                                if let image = selectAvatarImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .frame(width: 100, height: 100)
                                        .foregroundStyle(.gray.opacity(0.3))
                                        .overlay {
                                            Image(systemName: "person")
                                                .foregroundStyle(.white)
                                                .font(.system(size: 44))
                                        }
                                }

                                HStack {
                                    Spacer()
                                    Text("设置你的头像")
                                    Spacer()
                                }
                            }
                        }
                        // 选择头像的弹出层
                        .sheet(isPresented: $isShowAvatarSelectSheet) {
//                            Text("123")
                            ImagePicker(selectedImage: $selectAvatarImage, isImagePickerPresented: $isShowAvatarSelectSheet)
                        }

                        Button {} label: {
                            Text("确定")
                        }
                        .padding(.top, 50)
                    }
                }

                // 跳转首页
                NavigationLink(destination: HomeView(), isActive: $isToHomeView) {
                    EmptyView()
                }
//                .isDetailLink(false)
//                NavigationLink(value: LayoutView()) {
//                    EmptyView()
//                }

                Spacer()
            }
            .padding(20)
            .padding(.top, 80)
            .background(.gray.opacity(0.08))
            // 点击空白处隐藏输入框
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
//            .navigationDestination(isPresented: $isGoLayoutView) {
//                EmptyView()
//            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // 页面展示的时候将验证码输入框聚焦
            // https://fatbobman.com/zh/posts/textfield-event-focus-keyboard/
            // 在视图初始化阶段赋值是无效的。即使在 onAppear 中，也必须要有一定延时才能让 TextField 焦点
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focus = .email
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
}

#Preview {
    LoginView()
}
