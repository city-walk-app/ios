//
//  FriendsIView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/7/15.
//

import SwiftUI

struct FriendsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    /// 朋友列表
    @State private var friends: [FriendListType.FriendListData] = []
    /// 朋友列表是否在加载中
    @State private var isFriendsLoading = true

    var body: some View {
        ScrollView {
            VStack {
                // 加载中
                if isFriendsLoading {
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
                    if !self.friends.isEmpty {
                        let columns = [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ]

                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(self.friends, id: \.user_id) { item in

                                NavigationLink(destination: MainView(user_id: item.user_id)) {
                                    VStack(spacing: 12) {
                                        // 头像
                                        AsyncImage(url: URL(string: item.avatar ?? defaultAvatar)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 106, height: 106)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                        } placeholder: {
                                            Rectangle()
                                                .fill(skeletonBackground)
                                                .frame(width: 106, height: 106)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                        }

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
        }
        .frame(maxWidth: .infinity)
        .padding(.top, viewPaddingTop)
        .overlay(alignment: .top) {
            VariableBlurView(maxBlurRadius: 12)
                .frame(height: topSafeAreaInsets + globalNavigationBarHeight)
                .ignoresSafeArea()
        }
        .background(viewBackground)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("我的朋友")
                    .font(.headline)
            }
        }
        .navigationBarItems(leading: BackButton {
            self.presentationMode.wrappedValue.dismiss() // 返回上一个视图
        }) // 自定义返回按钮
        .onAppear {
            Task {
                await self.friendList() // 获取朋友列表
            }
        }
    }

    /// 获取朋友列表
    private func friendList() async {
        do {
            isFriendsLoading = true

            let res = try await Api.shared.friendList(params: [:])

            print("获取朋友列表", res)

            withAnimation {
                isFriendsLoading = false
            }

            guard res.code == 200, let data = res.data else {
                return
            }

            withAnimation {
                friends = data
            }
        } catch {
            print("获取朋友列表异常")
            withAnimation {
                isFriendsLoading = false
            }
        }
    }
}

#Preview {
    FriendsView()
}
