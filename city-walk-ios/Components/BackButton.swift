//
//  BackButton.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/16.
//

import SwiftUI

struct BackButton: View {
    // 用于触发返回操作的闭包
    var action: () -> Void

    var body: some View {
        Button {
            action() // 执行传入的返回操作
        } label: {
            Circle()
                .fill(Color.white)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color(hex: "#666666"))
                        .font(.system(size: 16))
                }
                .shadow(color: Color(hex: "#656565").opacity(0.1), radius: 5.4, x: 0, y: 1)
        }
    }
}

#Preview {
    BackButton(action: {})
}
