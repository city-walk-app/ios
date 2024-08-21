//
//  InviteView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/7/15.
//

import SwiftUI

struct InviteView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("邀请")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 200)
                .padding(.top, viewPaddingTop)
                .frame(maxWidth: .infinity)
            }
            .overlay(alignment: .top) {
                VariableBlurView(maxBlurRadius: 12)
                    .frame(height: topSafeAreaInsets + globalNavigationBarHeight)
                    .ignoresSafeArea()
            }
            .background(viewBackground)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("邀请朋友")
                    .font(.headline)
            }
        }
        .navigationBarItems(leading: BackButton(action: {
            self.presentationMode.wrappedValue.dismiss() // 返回上一个视图
        })) // 自定义返回按钮
    }
}

#Preview {
    InviteView()
}
