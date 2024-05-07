//
//  TabbarView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/20.
//

import SwiftUI

/// 取消 Button 点击的闪烁效果
/// https://zhuanlan.zhihu.com/p/398268809
struct StaticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct TabbarView: View {
    /// 选中的索引
    @Binding var active: LayoutSelection
    
    var body: some View {
        HStack {
            Spacer()
                    
            Button {
                active = .home
            } label: {
                Image(systemName: "house")
                    .font(.system(size: 22))
                    .foregroundStyle(active == .home ? .white : .black)
                    .padding(12)
                    .background(.red.opacity(active == .home ? 1 : 0))
            }
            .buttonStyle(StaticButtonStyle())
          
            Spacer()
                    
            Button {
                active = .ranking
            } label: {
                Image(systemName: "trophy")
                    .font(.system(size: 22))
                    .foregroundStyle(active == .ranking ? .white : .black)
                    .padding(12)
                    .background(.red.opacity(active == .ranking ? 1 : 0))
            }
            .buttonStyle(StaticButtonStyle())
                 
            Spacer()
                    
            Button {
                active = .route
            } label: {
                Image(systemName: "figure.run.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(active == .route ? .white : .black)
                    .padding(12)
                    .background(.red.opacity(active == .route ? 1 : 0))
            }
            .buttonStyle(StaticButtonStyle())
                 
            Spacer()
                    
            Button {
                active = .main
            } label: {
                Image(systemName: "person")
                    .font(.system(size: 22))
                    .foregroundStyle(active == .main ? .white : .black)
                    .padding(12)
                    .background(.red.opacity(active == .main ? 1 : 0))
            }
            .buttonStyle(StaticButtonStyle())
            
            Spacer()
        }
        .padding(.vertical, 15)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25))
        .padding(.horizontal, 28)
    }
}

#Preview {
    TabbarView(active: .constant(.home))
}
