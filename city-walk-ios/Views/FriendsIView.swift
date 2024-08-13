//
//  FriendsIView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/7/15.
//

import SwiftUI

struct FriendsIView: View {
    /// 朋友列表
    @State private var friends: [FriendListType.FriendListData] = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if !self.friends.isEmpty {
                        ForEach(self.friends, id: \.user_id) { item in
                            NavigationLink(destination: MainView(user_id: item.user_id)) {
                                VStack {
                                    // 头像
                                    AsyncImage(url: URL(string: item.avatar ?? defaultAvatar)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 106, height: 106) // 设置图片的大小
                                            .clipShape(Circle()) // 将图片裁剪为圆形
                                    } placeholder: {
                                        // 占位符，图片加载时显示的内容
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 106, height: 106) // 占位符的大小与图片一致
                                            .overlay(Text("加载失败").foregroundColor(.white))
                                    }
                                }

                                // 昵称
                                Text("\(item.nick_name ?? "")")
                            }
                        }
                    } else {
                        Text("暂无好友")
                    }
                }
            }
            .navigationTitle("朋友列表")
        }
        .onAppear {
            Task {
                await self.friendList() // 获取朋友列表
            }
        }
    }

    /// 获取朋友列表
    private func friendList() async {
        do {
            let res = try await Api.shared.friendList(params: [:])

            print("获取朋友列表", res)

            if res.code == 200 && res.data != nil {
                self.friends = res.data!
            }

        } catch {
            print("获取朋友列表异常")
        }
    }
}

#Preview {
    FriendsIView()
}
