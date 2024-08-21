//
//  RankingView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

struct RankingView: View {
    // 使用 @Environment 属性包装器从环境中获取 presentationMode，这里 presentationMode 是一个 Binding<PresentationMode>
    // PresentationMode 表示视图的显示状态，可以通过它来控制视图的弹出或返回
    // presentationMode.wrappedValue.dismiss() 可以用于关闭当前视图或返回到前一个视图
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    /// 排名列表
    @State private var rankingList: [FriendGetExperienceRankingType.FriendGetExperienceRankingData] = []

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if !self.rankingList.isEmpty {
                        ForEach(self.rankingList, id: \.user_id) { item in
                            HStack(spacing: 14) {
                                // 头像
                                NavigationLink(destination: MainView(user_id: item.user_id)) {
                                    AsyncImage(url: URL(string: item.avatar ?? defaultAvatar)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 46, height: 46) // 设置图片的大小
                                            .clipShape(Circle()) // 将图片裁剪为圆形
                                    } placeholder: {
                                        Circle()
                                            .fill(skeletonBackground)
                                            .frame(width: 46, height: 46)
                                    }
                                }

                                HStack(alignment: .top) {
                                    // 文案
                                    VStack(alignment: .leading, spacing: 7) {
                                        Text("\(item.nick_name ?? "")")
                                            .foregroundStyle(Color(hex: "#333333"))
                                            .font(.system(size: 16))

                                        HStack {
                                            Text("今日共打卡")
                                            Text("\(item.count)")
                                                .foregroundStyle(Color(hex: "#F3943F"))
                                            Text("个地点")
                                        }
                                        .font(.system(size: 14))
                                    }

                                    Spacer()

                                    Text("\(item.experiences)")
                                        .font(.system(size: 30))
                                        .foregroundStyle(Color(hex: "#F8D035"))
                                }
                            }
                            .padding(.vertical, 17)
                            .padding(.trailing, 15)
                            .padding(.leading, 16)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    } else {
                        ForEach(1 ..< 4) { _ in
                            Rectangle()
                                .fill(Color(hex: "#f4f4f4"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 200)
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
                Text("排行榜")
                    .font(.headline)
            }
        }
        .navigationBarItems(leading: BackButton(action: {
            self.presentationMode.wrappedValue.dismiss() // 返回上一个视图
        })) // 自定义返回按钮
        .background(.gray.opacity(0.1))
        .onAppear {
            Task {
                await self.friendGetExperienceRanking() // 获取朋友经验排行榜
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
