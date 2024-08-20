//
//  Loading.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/20.
//

import SwiftUI

struct Loading: View {
    var title: String

    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .ignoresSafeArea() // 忽略安全区域，扩展到整个屏幕

            VStack(spacing: 10) {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding(.bottom, 10)

                Text(title)
                    .font(.title2)
                    .foregroundStyle(Color(hex: "#F3943F"))
            }
            .padding(.top, 33)
            .padding(.bottom, 23)
            .padding(.horizontal, 25)
            .background(Color.white)
            .cornerRadius(11)
        }
    }
}

#Preview {
    Loading(title: "加载中...")
}
