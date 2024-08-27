//
//  LoginView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import Combine
import Foundation
import SwiftUI

struct LoginHeaderView: View {
    var title: String
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 20) {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 56, height: 56)
                .mask(Circle())
        
            Text(title)
                .font(.system(size: 28))
                .bold()
                .foregroundStyle(Color("text-1"))
        
            Spacer()
        }
    }
}

struct LoginView: View {
    /// 聚焦的输入框枚举
    enum FocusedField: Hashable {
        case email, code
    }

    /// 创建一个每秒触发一次的定时器
    private let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    /// 卡片数量
    private let cardCount: CGFloat = 2
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    /// loading 数据
    @EnvironmentObject private var loadingData: LoadingData
    /// 缓存数据
    @EnvironmentObject private var storageData: StorageData
    
    /// 操作步骤
    @State private var step = 0
    /// 邮箱
    @State private var email = ""
    /// 验证码
    @State private var code = ""
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
  
    var body: some View {
        NavigationView {
            VStack {
                // 内容
                GeometryReader { geometry in
                    ZStack {
                        HStack(spacing: 0) {
                            // 邮箱步骤
                            VStack {
                                VStack(spacing: 44) {
                                    LoginHeaderView(title: "欢迎，请登录")
                                    
                                    VStack(alignment: .center, spacing: 51) {
                                        TextField("请输入邮箱", text: $email)
                                            .frame(height: 58)
                                            .padding(.horizontal, 23)
                                            .background(Color(hex: "#ECECEC"))
                                            .keyboardType(.default)
                                            .textContentType(.emailAddress)
                                            .focused($focus, equals: .email)
                                            .submitLabel(.next)
                                            .onReceive(Just(code), perform: { _ in
                                                limitMaxLength(content: &code, maxLength: 50)
                                            })
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .onSubmit { // 监听提交事件
                                                Task {
                                                    await self.sendEmail()
                                                }
                                            }
                                        
                                        Button {
                                            Task {
                                                await self.sendEmail()
                                            }
                                        } label: {
                                            Circle()
                                                .fill(Color(hex: "#F3943F"))
                                                .frame(width: 90, height: 90)
                                                .overlay {
                                                    Image(systemName: "chevron.right")
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 27))
                                                }
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 26)
                            }
                            .frame(width: geometry.size.width)
                            .frame(maxHeight: .infinity)
                            .padding(.top, 79)
                            
                            // 验证码
                            VStack {
                                VStack(spacing: 44) {
                                    LoginHeaderView(title: "请输入验证码")
                                    
                                    VStack(alignment: .center, spacing: 51) {
                                        TextField("请输入验证码", text: $code)
                                            .frame(height: 58)
                                            .padding(.horizontal, 23)
                                            .keyboardType(.numberPad) // 设置键盘类型为数字键盘
                                            .textContentType(.oneTimeCode) // 设置内容类型为一次性代码，以便系统知道右下角按钮应该显示为“确认”
                                            .background(Color(hex: "#ECECEC"))
                                            .keyboardType(.default)
                                            .textContentType(.emailAddress)
                                            .focused($focus, equals: .code)
                                            .submitLabel(.return)
                                            .onReceive(Just(code), perform: { _ in
                                                limitMaxLength(content: &code, maxLength: 6)
                                            }) // 最大长度为 6 位
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .onSubmit { // 监听提交事件
                                                Task {
                                                    await self.userLoginEmail()
                                                }
                                            }
                                        Button {
                                            Task {
                                                await self.userLoginEmail()
                                            }
                                        } label: {
                                            Circle()
                                                .fill(Color(hex: "#F3943F"))
                                                .frame(width: 90, height: 90)
                                                .overlay {
                                                    Image(systemName: "chevron.right")
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 27))
                                                }
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 26)
                            }
                            .frame(width: geometry.size.width)
                            .frame(maxHeight: .infinity)
                            .padding(.top, 79)
                        }
                        .frame(width: geometry.size.width * cardCount, alignment: .leading)
                        .offset(x: -CGFloat(step) * geometry.size.width)
                        .animation(.easeInOut, value: step)
                    
                        // loading 元素
                        Loading()
                    }
                }
                .background(viewBackground)
                
                NavigationLink(destination: HomeView(), isActive: $isToHomeView) {
                    EmptyView()
                }
            }
            // 点击空白处隐藏输入框
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
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
//        .onReceive(timer) { _ in
//            if isCountingDown {
//                if countdownSeconds > 0 {
//                    countdownSeconds -= 1 // 每秒减少一秒
//                } else {
//                    isCountingDown = false // 倒计时结束后停止倒计时
//                }
//            }
//        }
        // 登录成功之后跳转到首页
//        .navigationDestination(isPresented: $isToHomeView) {
//            HomeView()
//        }
    }
    
    /// 检测是否为邮箱格式
    private func isValidEmail(_ email: String) -> Bool {
        // 使用正则表达式验证邮箱格式
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

//    /// 获取邮箱验证码
//    private func emailSend() async {
//        isCountingDown = true // 开启倒计时
//        countdownSeconds = 10 // 恢复时间
//    }
    
    /// 获取验证码
    private func sendEmail() async {
        if email == "" || !isValidEmail(email) {
            return
        }
        
        do {
            loadingData.showLoading(options: LoadingParams(title: "获取中..."))
            
            let res = try await Api.shared.emailSend(params: ["email": email])
        
            loadingData.hiddenLoading()
            
            print("获取邮箱验证码结果", res)
            
            if res.code == 200 {
                withAnimation {
                    step = 1
                }
            }
        } catch {
            print("获取验证码错误")
            loadingData.hiddenLoading()
        }
    }
    
    /// 邮箱验证码登录
    private func userLoginEmail() async {
        do {
            loadingData.showLoading(options: LoadingParams(title: "登录中..."))
            
            let res = try await Api.shared.userLoginEmail(params: ["email": email, "code": code])
            
            loadingData.hiddenLoading()
            
            print("登录结果", res)
            
            guard res.code == 200, let data = res.data else {
                return
            }
            
            storageData.saveUserInfo(info: data.user_info)
            storageData.saveToken(token: data.token)
            isToHomeView = true
        } catch {
            print("邮箱登录错误")
            loadingData.hiddenLoading()
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
        .environmentObject(LoadingData())
        .environmentObject(StorageData())
        .environmentObject(HomeData())
}
