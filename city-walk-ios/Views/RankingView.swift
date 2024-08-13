//
//  RankingView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

struct RankingView: View {
    /// tab 切换数据
//    @EnvironmentObject var globalDataModel: GlobalData

    /// 排名列表
    @State private var rankingList: [FriendGetExperienceRankingType.FriendGetExperienceRankingData] = []

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    if !self.rankingList.isEmpty {
                        ForEach(self.rankingList, id: \.user_id) { item in
                            HStack {
                                // 头像
                                NavigationLink(destination: MainView(user_id: item.user_id)) {
                                    AsyncImage(url: URL(string: item.avatar ?? defaultAvatar)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 46, height: 46) // 设置图片的大小
                                            .clipShape(Circle()) // 将图片裁剪为圆形
                                    } placeholder: {
                                        // 占位符，图片加载时显示的内容
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 46, height: 46) // 占位符的大小与图片一致
                                            .overlay(Text("加载失败").foregroundColor(.white))
                                    }
                                }

                                Text("\(item.nick_name ?? "")")
                            }
                        }
                    } else {
                        Text("暂无排行榜")
                    }
                }
                .padding(20)
                .padding(.bottom, 200)
            }
            .navigationTitle("经验排名")
            .onAppear {
                Task {
                    await self.friendGetExperienceRanking() // 获取朋友经验排行榜
                }
            }
        }
    }

    /// 获取朋友经验排行榜
    private func friendGetExperienceRanking() async {
        do {
            let res = try await Api.shared.friendGetExperienceRanking(params: [:])

            print("获取朋友排行榜信息", res)

            if res.code == 200 && res.data != nil {
                self.rankingList = res.data!
            }
        } catch {
            print("获取朋友经验排行异常")
        }
    }
}

#Preview {
    RankingView()
//        .environmentObject(GlobalData())
}
