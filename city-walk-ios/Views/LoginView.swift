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

/// 登录
struct LoginView: View {
    /// 创建一个每秒触发一次的定时器
    private let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
  
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
    /// 当前登录的用户 id，只在新用户注册时使用
    @State private var userId = 0
    /// 登录按钮是否禁用
    @State private var isLoginButtonDisabled = false
    /// 是否跳转到首页
    @State private var isToHomeView = false
    /// 是否在倒计时中
    @State private var isCountingDown = false
    /// 设置倒计时秒数
    @State private var countdownSeconds = 10
    
    let maxDigits: Int = 6
  
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
                                    .background(self.focus == .email ? Color.clear : Color(hex: "#ECECEC"))
                                    .keyboardType(.default)
                                    .textContentType(.emailAddress)
                                    .focused($focus, equals: .email)
                                    .submitLabel(.next)
                                    .onReceive(Just(code), perform: { _ in
                                        limitMaxLength(content: &code, maxLength: 50)
                                    })
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(self.focus == .email ? Color("theme-1") : Color.clear, lineWidth: 2)
                                    )
                                    .onSubmit { // 监听提交事件
                                        Task {
                                            await self.sendEmail()
                                        }
                                    }
                                    .onTapGesture {
                                        self.focus = .email
                                    }
                                        
                                Button {
                                    Task {
                                        await self.sendEmail()
                                    }
                                } label: {
                                    Circle()
                                        .fill(Color("theme-1"))
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
//                    .frame(maxHeight: .infinity)
                    .padding(.top, 79)
                            
                    // 验证码
                    VStack {
                        VStack(spacing: 44) {
                            LoginHeaderView(title: "请输入验证码")
                            
                            VStack(alignment: .center, spacing: 51) {
                                HStack(spacing: 10) {
                                    ForEach(0 ..< maxDigits, id: \.self) { index in
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                                .frame(width: 50, height: 58)
                                                  
                                            Text(getCharacter(at: index))
                                                .font(.system(size: 24))
                                                .fontWeight(.bold)
                                        }
                                    }
                                }
                                .background(
                                    TextField("", text: $code)
                                        .frame(width: 0, height: 0)
                                        .keyboardType(.numberPad)
                                        .textContentType(.oneTimeCode)
                                        .focused($focus, equals: .code)
                                        .onChange(of: code) { _ in
                                            limitMaxLength(content: &code, maxLength: maxDigits)
                                        }
                                        .onAppear {
                                            self.focus = .code
                                        }
                                )
                                .onTapGesture {
                                    self.focus = .code
                                    print("获取焦点")
                                }
                                
//                                TextField("请输入验证码", text: $code)
//                                    .frame(height: 58)
//                                    .padding(.horizontal, 23)
//                                    .keyboardType(.numberPad) // 设置键盘类型为数字键盘
//                                    .textContentType(.oneTimeCode) // 设置内容类型为一次性代码，以便系统知道右下角按钮应该显示为“确认”
//                                    .background(Color(hex: "#ECECEC"))
//                                    .keyboardType(.default)
//                                    .textContentType(.emailAddress)
//                                    .focused($focus, equals: .code)
//                                    .submitLabel(.return)
//                                    .onReceive(Just(code), perform: { _ in
//                                        limitMaxLength(content: &code, maxLength: 6)
//                                    }) // 最大长度为 6 位
//                                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                                    .onSubmit { // 监听提交事件
//                                        Task {
//                                            await self.userLoginEmail()
//                                        }
//                                    }
                                    
                                // 获取验证码按钮
                                Button {
                                    Task {
                                        await self.userLoginEmail()
                                    }
                                } label: {
                                    Circle()
                                        .fill(Color("theme-1"))
                                        .frame(width: 90, height: 90)
                                        .overlay {
                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(.white)
                                                .font(.system(size: 27))
                                        }
                                }
                                    
                                Button {
                                    withAnimation {
                                        step = 0
                                    }
                                } label: {
                                    Text("重新输入")
                                        .foregroundStyle(Color("theme-1"))
                                        .font(.system(size: 16))
                                        .padding(.top, 20)
                                }
                            }
                                    
                            Spacer()
                        }
                        .padding(.horizontal, 26)
                    }
                    .frame(width: geometry.size.width)
//                    .frame(maxHeight: .infinity)
                    .padding(.top, 79)
                }
                .frame(width: geometry.size.width * cardCount, alignment: .leading)
                .offset(x: -CGFloat(step) * geometry.size.width)
                .animation(.easeInOut, value: step)
            }
            .background(viewBackground)
            .ignoresSafeArea(.keyboard)
           
            // 返回首页
            NavigationLink(destination: HomeView(), isActive: $isToHomeView) {
                EmptyView()
            }
        }
       
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
//        .navigationDestination(isPresented: $isToHomeView) {
//            HomeView()
//        }
    }
    
    private func getCharacter(at index: Int) -> String {
        guard index < code.count else { return "" }
        let startIndex = code.index(code.startIndex, offsetBy: index)
        return String(code[startIndex])
    }
     
    private func limitMaxLength(content: inout String, maxLength: Int) {
        if content.count > maxLength {
            content = String(content.prefix(maxLength))
        }
    }
    
    /// 检测是否为邮箱格式
    private func isValidEmail(_ email: String) -> Bool {
        // 使用正则表达式验证邮箱格式
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    /// 收起键盘
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

//    /// 获取邮箱验证码
//    private func emailSend() async {
//        isCountingDown = true // 开启倒计时
//        countdownSeconds = 10 // 恢复时间
//    }
    
    /// 获取验证码
    private func sendEmail() async {
        if email == "" || !isValidEmail(email) {
            globalData.showToast(title: "请输入邮箱")
            return
        }
        
        do {
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
            }
        } catch {
            print("获取验证码错误")
            globalData.hiddenLoading()
        }
    }
    
    /// 邮箱验证码登录
    private func userLoginEmail() async {
        if code == "" || code.count != 6 {
            globalData.showToast(title: "请输入正确的验证码")
            return
        }
        
        do {
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
        } catch {
            print("邮箱登录错误")
            globalData.hiddenLoading()
        }
    }
    
    /// 检测输入框最大长度
    /// - Parameters:
    ///   - content: 输入框的内容
    ///   - maxLength: 最大长度
//    private func limitMaxLength(content: inout String, maxLength: Int) {
//        if content.count > maxLength {
//            content = String(content.prefix(maxLength))
//        }
//    }
}

/// 登录头部
private struct LoginHeaderView: View {
    /// 标题
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
