//
//  Loading.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/20.
//

import SwiftUI

/// 加载中
struct Loading: View {
    @EnvironmentObject var loadingData: LoadingData

    var body: some View {
        if loadingData.isLoading {
            ZStack {
                Color.white.opacity(0.01)
                    .ignoresSafeArea() // 忽略安全区域，扩展到整个屏幕

                VStack(spacing: 10) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(.bottom, 10)

                    Text(loadingData.title)
                        .font(.title2)
                        .foregroundStyle(Color(hex: "#333333"))
                }
                .padding(.top, 33)
                .padding(.bottom, 23)
                .padding(.horizontal, 25)
                .background(.thinMaterial)
                .cornerRadius(26)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea(.keyboard) // 忽略键盘的安全区域，以防止加载视图移动
            .zIndex(99999999)
        }
    }
}

#Preview {
    Loading()
        .environmentObject(LoadingData())
}
