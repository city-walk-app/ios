//
//  LayoutView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/20.
//

import SwiftUI

enum LayoutSelection {
    case home
    case ranking
    case route
    case main
}

struct LayoutView: View {
    @State var active: LayoutSelection = .home
    /// 缓存信息
    let cacheInfo = UserCache.shared.getInfo()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if active == .home {
                    HomeView()
                }
                else if active == .ranking {
                    RankingView()
                }
                else if active == .route {
                    RouterView()
                }
                else if active == .main {
                    MainView(userId: cacheInfo!.id)
                }

                // 底部 tab
                TabbarView(active: $active)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
    }
}

#Preview {
    LayoutView()
        .environmentObject(UserInfoData())
}
