//
//  LoginFormView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/6/6.
//

import Combine
import SwiftUI

struct LoginFormView: View {
    @Binding var email: String
    @Binding var countdownSeconds: Int
    @Binding var isCountingDown: Bool
    @Binding var code: String
//    @Binding var focus: FocusState<LoginView.FocusedField>.Binding
    @FocusState.Binding var focus: LoginView.FocusedField?
    @Binding var isLoginButtonDisabled: Bool
    
    var validateEmail: () -> Void
    var userLoginEmail: () -> Void
    
    var body: some View {
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
                .foregroundStyle(.black)
            
            Spacer()
        }
        
        /// 邮箱
        HStack {
            TextField("请输入邮箱", text: $email)
                .padding(.vertical, 20)
                .keyboardType(.default)
                .focused($focus, equals: .email)
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
                    self.validateEmail()
                    print("获取验证码")
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
            print("点击登录")
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

// #Preview {
//    LoginFormView()
// }
