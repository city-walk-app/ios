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
                .frame(maxWidth: .infinity)
            }
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
        .background(.gray.opacity(0.1))
    }
}

#Preview {
    InviteView()
}
