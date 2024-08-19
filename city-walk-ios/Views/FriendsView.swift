////
////  FriendsIView.swift
////  city-walk-ios
////
////  Created by Tyh2001 on 2024/7/15.
////
//
//import SwiftUI
//
//struct FriendsView: View {
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//
//    /// 朋友列表
//    @State private var friends: [FriendListType.FriendListData] = []
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack {
//                    if !self.friends.isEmpty {
//                        let columns = [
//                            GridItem(.flexible()),
//                            GridItem(.flexible()),
//                            GridItem(.flexible())
//                        ]
//
//                        LazyVGrid(columns: columns, spacing: 20) {
//                            ForEach(self.friends, id: \.user_id) { item in
//
//                                NavigationLink(destination: MainView(user_id: item.user_id)) {
//                                    VStack(spacing: 12) {
//                                        // 头像
//                                        AsyncImage(url: URL(string: item.avatar ?? defaultAvatar)) { image in
//                                            image
//                                                .resizable()
//                                                .aspectRatio(contentMode: .fill)
//                                                .frame(width: 106, height: 106) // 设置图片的大小
//                                                .clipShape(RoundedRectangle(cornerRadius: 20))
//                                        } placeholder: {
//                                            // 占位符，图片加载时显示的内容
//                                            Rectangle()
//                                                .fill(skeletonBackground)
//                                                .frame(width: 106, height: 106)
//                                                .clipShape(RoundedRectangle(cornerRadius: 20))
//                                        }
//
//                                        // 昵称
//                                        Text("\(item.nick_name ?? "")")
//                                            .foregroundStyle(Color(hex: "#666666"))
//                                    }
//                                }
//                            }
//                        }
//                    } else {
//                        Text("暂无好友")
//                    }
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("我的朋友")
//                    .font(.headline)
//            }
//        }
//        .navigationBarItems(leading: BackButton {
//            self.presentationMode.wrappedValue.dismiss() // 返回上一个视图
//        }) // 自定义返回按钮
//        .background(.gray.opacity(0.1))
//        .onAppear {
//            Task {
//                await self.friendList() // 获取朋友列表
//            }
//        }
//    }
//
//    /// 获取朋友列表
//    private func friendList() async {
//        do {
//            let res = try await Api.shared.friendList(params: [:])
//
//            print("获取朋友列表", res)
//
//            if res.code == 200 && res.data != nil {
//                self.friends = res.data!
//            }
//
//        } catch {
//            print("获取朋友列表异常")
//        }
//    }
//}
//
//#Preview {
//    FriendsView()
//}
