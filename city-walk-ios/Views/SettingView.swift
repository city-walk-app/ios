//
//  SettingView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/20.
//

import SwiftUI

struct SettingView: View {
    @State private var isGoLoginView = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    NavigationLink(
                        destination: LoginView(),
                        isActive: $isGoLoginView,
                        label: {
                            Button(action: {
                                UserCache.shared.deleteInfo()
                                isGoLoginView = true
                            }, label: {
                                Text("退出登录")
                            })
                        }
                    )
                }
            }
            .navigationTitle("设置")
        }
    }
}

#Preview {
    SettingView()
}
