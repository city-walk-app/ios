//
//  LoginNameView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/6/11.
//

import SwiftUI

struct LoginNameView: View {
    @Binding var nickName: String

    var setUserInfo: () -> Void

    var body: some View {
        Text("设置你的名字")
        TextField("你的名字", text: $nickName)
            .frame(maxWidth: .infinity, maxHeight: 60)
            .padding(.horizontal)
            .background(.gray.opacity(0.1))
            .foregroundStyle(.black)

        Button {
            self.setUserInfo() // 设置用户信息
        } label: {
            RoundedRectangle(cornerRadius: 13)
                .frame(width: 120, height: 60)
                .overlay {
                    Text("确定")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                }
        }
    }
}
