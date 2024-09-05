//
//  LoginView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import Combine
import Foundation
import SwiftUI

/// 卡片数量
private let cardCount: CGFloat = 2
/// 验证码最大输入框
private let maxDigits = 6
/// 验证码获取倒计时秒数
private let countdownSecond = 60
/// 创建一个每秒触发一次的定时器
private let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()

/// 登录
struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    /// 缓存数据
    @EnvironmentObject private var storageData: StorageData
    /// 全球的数据
    @EnvironmentObject private var globalData: GlobalData
    
    /// 输入框是否获取焦点
    @FocusState private var focus: FocusedField?
    
    /// 操作步骤
    @State private var step = 0
    /// 邮箱
    @State private var email = ""
    /// 验证码
    @State private var code = ""
    /// 获取验证码按钮是否禁用
    @State private var isEmailButtonDisabled = false
    /// 登录按钮是否禁用
    @State private var isLoginButtonDisabled = false
    /// 是否跳转到首页
    @State private var isToHomeView = false
    /// 是否在倒计时中
    @State private var isCountingDown = false
    /// 设置倒计时秒数
    @State private var countdownSeconds = countdownSecond
    
    var body: some View {
        NavigationStack {
            // 内容
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // 邮箱步骤
                    VStack {
                        VStack(spacing: 44) {
                            LoginHeaderView(title: "欢迎，请登录")
                                
                            VStack(alignment: .center, spacing: 51) {
                                TextField("请输入邮箱", text: $email)
                                    .frame(height: 58)
                                    .padding(.horizontal, 23)
                                    .background(self.focus == .email ? Color.clear : Color("background-3"))
                                    .keyboardType(.default)
                                    .textContentType(.emailAddress)
                                    .focused($focus, equals: .email)
                                    .submitLabel(.done)
                                    .foregroundStyle(Color("text-1"))
                                    .onReceive(Just(code), perform: { _ in
                                        limitMaxLength(content: &code, maxLength: 50)
                                    })
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(self.focus == .email ? Color("theme-1") : Color.clear, lineWidth: 2)
                                    )
                                    .onSubmit {
                                        self.hideKeyboard() // 隐藏键盘
                                        
                                        Task {
                                            await self.sendEmail()
                                        }
                                    }
                                    .onTapGesture {
                                        self.focus = .email
                                    }
                                        
                                Button {
                                    self.hideKeyboard() // 隐藏键盘
                                    
                                    Task {
                                        await self.sendEmail()
                                    }
                                } label: {
                                    Circle()
                                        .fill(email == "" || isEmailButtonDisabled ? Color("theme-1").opacity(0.5) : Color("theme-1"))
                                        .frame(width: 90, height: 90)
                                        .overlay {
                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(.white)
                                                .font(.system(size: 27))
                                        }
                                }
                                .disabled(email == "" || isEmailButtonDisabled)
                            }
                                    
                            Spacer()
                        }
                        .padding(.horizontal, 26)
                    }
                    .frame(width: geometry.size.width)
                    .padding(.top, 79)
                            
                    // 验证码
                    ZStack(alignment: .topLeading) {
                        VStack {
                            VStack(spacing: 44) {
                                LoginHeaderView(title: "请输入验证码")
                            
                                VStack(alignment: .center, spacing: 51) {
                                    HStack(spacing: 14) {
                                        ForEach(0 ..< maxDigits, id: \.self) { index in
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(index == code.count ? Color("theme-1") : Color.gray.opacity(0.2), lineWidth: 2)
                                                    .frame(width: 44, height: 52)
                                                  
                                                Text(getCharacter(at: index))
                                                    .font(.system(size: 24))
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(Color("text-1"))
                                            }
                                        }
                                    }
                                    .background(Color("background-1").opacity(0.00000001))
                                    .onTapGesture {
                                        self.focus = .code
                                        print("获取焦点")
                                    }
                                    .overlay {
                                        ZStack {
                                            TextField("", text: $code)
                                                .keyboardType(.numberPad)
                                                .textContentType(.oneTimeCode)
                                                .focused($focus, equals: .code)
                                                .onChange(of: code) {
                                                    limitMaxLength(content: &code, maxLength: maxDigits)
                                                }
                                                .opacity(0)
                                        }
                                    }
                              
                                    // 获取验证码按钮
                                    Button {
                                        self.hideKeyboard() // 隐藏键盘
                                    
                                        Task {
                                            await self.userLoginEmail()
                                        }
                                    } label: {
                                        Circle()
                                            .fill(code.count != 6 || isLoginButtonDisabled ? Color("theme-1").opacity(0.5) : Color("theme-1"))
                                            .frame(width: 90, height: 90)
                                            .overlay {
                                                Image(systemName: "chevron.right")
                                                    .foregroundStyle(.white)
                                                    .font(.system(size: 27))
                                            }
                                    }
                                    .disabled(code.count != 6 || isLoginButtonDisabled)
                                
                                    // 倒计时中
                                    Group {
                                        if isCountingDown {
                                            Text("\(countdownSeconds)s后重新获取")
                                        } else {
                                            Button {
                                                Task {
                                                    await self.sendEmail()
                                                }
                                            } label: {
                                                Text("重新获取")
                                            }
                                        }
                                    }
                                    .foregroundStyle(Color("theme-1"))
                                    .font(.system(size: 16))
                                    .padding(.top, 20)
                                }
                                    
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 26)
                        .frame(width: geometry.size.width)
                        .padding(.top, 79)
                        
                        HStack {
                            BackButton {
                                withAnimation {
                                    self.step = 0
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .frame(width: geometry.size.width * cardCount, alignment: .leading)
                .offset(x: -CGFloat(step) * geometry.size.width)
                .animation(.easeInOut, value: step)
            }
            .background(viewBackground)
            .ignoresSafeArea(.keyboard)
           
            NavigationLink(destination: HomeView(), isActive: $isToHomeView) {
                EmptyView()
            }
        }
        .onTapGesture {
            self.hideKeyboard() // 收起键盘
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // 页面展示的时候将验证码输入框聚焦
            // https://fatbobman.com/zh/posts/textfield-event-focus-keyboard/
            // 在视图初始化阶段赋值是无效的。即使在 onAppear 中，也必须要有一定延时才能让 TextField 焦点
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if step == 0 {
                        self.focus = .email
                    } else if step == 1 {
                        self.focus = .code
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            if isCountingDown {
                print("倒计时", countdownSeconds)
                if countdownSeconds > 0 {
                    countdownSeconds -= 1 // 每秒减少一秒
                    
                } else {
                    isCountingDown = false // 倒计时结束后停止倒计时
                    countdownSeconds = countdownSecond // 恢复时间
                }
            }
        }
        // 登录成功之后跳转到首页
//        .navigationDestination(isPresented: $isToHomeView) {
//            HomeView()
//        }
    }
    
    /// 根据索引获取验证码字符串中的单个字符
    /// - Parameter index: 要获取字符的索引
    /// - Returns: 对应索引的字符，如果索引超出范围则返回空字符串
    private func getCharacter(at index: Int) -> String {
        guard index < code.count else { return "" }
        let startIndex = code.index(code.startIndex, offsetBy: index)
        return String(code[startIndex])
    }
     
    /// 限制字符串的最大长度
    /// - Parameters:
    ///   - content: 输入的字符串
    ///   - maxLength: 最大允许的字符数
    private func limitMaxLength(content: inout String, maxLength: Int) {
        if content.count > maxLength {
            content = String(content.prefix(maxLength))
        }
    }
    
    /// 检测是否为邮箱格式
    /// - Parameter email: 邮箱
    /// - Returns: 是否为正确的邮箱
    private func isValidEmail(email: String) -> Bool {
        // 使用正则表达式验证邮箱格式
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    /// 收起键盘
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// 获取验证码
    private func sendEmail() async {
        if email == "" || !isValidEmail(email: email) {
            globalData.showToast(title: "请输入邮箱")
            return
        }
        
        do {
            isCountingDown = true // 开启倒计时
            isEmailButtonDisabled = true
         
            globalData.showLoading(title: "获取中...")
            
            let res = try await Api.shared.emailSend(params: ["email": email])
        
            globalData.hiddenLoading()
            
            print("获取邮箱验证码结果", res)
            
            if res.code == 200 {
                hideKeyboard()
                
                withAnimation {
                    step = 1
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.focus = .code
                    }
                }
                
                isEmailButtonDisabled = false
            }
        } catch {
            print("获取验证码错误")
            globalData.hiddenLoading()
            isEmailButtonDisabled = false
        }
    }
    
    /// 邮箱验证码登录
    private func userLoginEmail() async {
        if code == "" || code.count != 6 {
            globalData.showToast(title: "请输入正确的验证码")
            return
        }
        
        do {
            isLoginButtonDisabled = true
            globalData.showLoading(title: "登录中...")
            
            let res = try await Api.shared.userLoginEmail(params: ["email": email, "code": code])
            
            globalData.hiddenLoading()
            
            print("登录结果", res)
            
            guard res.code == 200, let data = res.data else {
                return
            }
            
            storageData.saveUserInfo(info: data.user_info)
            storageData.saveToken(token: data.token)
            isToHomeView = true
            isLoginButtonDisabled = false
        } catch {
            print("邮箱登录错误")
            globalData.hiddenLoading()
            isLoginButtonDisabled = false
        }
    }
}

/// 登录头部
private struct LoginHeaderView: View {
    /// 标题
    var title: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
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

/// 聚焦的输入框枚举
private enum FocusedField: Hashable {
    case email, code
}

#Preview {
    LoginView()
        .environmentObject(StorageData())
        .environmentObject(HomeData())
        .environmentObject(GlobalData())
}
