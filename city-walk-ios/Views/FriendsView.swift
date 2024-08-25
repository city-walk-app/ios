//
//  FriendsIView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/7/15.
//

import Kingfisher
import SwiftUI

struct FriendsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// 朋友数据
    @EnvironmentObject private var friendsData: FriendsData

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // 加载中
                    if friendsData.isFriendsLoading {
                        let columns = [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ]

                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(0 ..< 4) { _ in
                                Rectangle()
                                    .fill(skeletonBackground)
                                    .frame(width: 106, height: 106)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                    } else {
                        if !friendsData.friends.isEmpty {
                            let columns = [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                            ]

                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(friendsData.friends, id: \.user_id) { item in

                                    NavigationLink(destination: MainView(user_id: item.user_id)) {
                                        VStack(spacing: 12) {
                                            // 头像
                                            KFImage(URL(string: item.avatar ?? defaultAvatar))
                                                .placeholder {
                                                    Rectangle()
                                                        .fill(skeletonBackground)
                                                        .frame(width: 106, height: 106)
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                }
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 106, height: 106)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))

                                            // 昵称
                                            Text("\(item.nick_name ?? "")")
                                                .foregroundStyle(Color(hex: "#666666"))
                                        }
                                    }
                                }
                            }
                        } else {
                            EmptyState(title: "暂无朋友")
                                .padding(.top, 100)
                        }
                    }
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
                Text("我的朋友")
                    .font(.headline)
            }
        }
        .navigationBarItems(leading: BackButton(action: {
            self.presentationMode.wrappedValue.dismiss() // 返回上一个视图
        })) // 自定义返回按钮
        .onAppear {
            Task {
                await friendsData.friendList() // 获取朋友列表
            }
        }
    }
}

#Preview {
    FriendsView()
        .environmentObject(FriendsData())
}
