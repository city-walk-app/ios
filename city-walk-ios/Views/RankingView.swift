//
//  RankingView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import Kingfisher
import SwiftUI

private let ranking1 = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/ranking-1.png")
private let ranking2 = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/ranking-2.png")
private let ranking3 = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/ranking-3.png")
private let rankingCrown = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/ranking-crown.png")

/// 排行榜
struct RankingView: View {
    // 使用 @Environment 属性包装器从环境中获取 presentationMode，这里 presentationMode 是一个 Binding<PresentationMode>
    // PresentationMode 表示视图的显示状态，可以通过它来控制视图的弹出或返回
    // presentationMode.wrappedValue.dismiss() 可以用于关闭当前视图或返回到前一个视图
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @EnvironmentObject private var rankingData: RankingData

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 20) {
                    if rankingData.isRankingListLoading {
                        ForEach(1 ..< 4) { _ in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("skeleton-background"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                        }
                    } else {
                        if !rankingData.rankingList.isEmpty {
                            ForEach(Array(rankingData.rankingList.enumerated()), id: \.element.user_id) { index, item in
                                HStack(spacing: 14) {
                                    if item.experiences != nil && item.experiences ?? 0 > 0 {
                                        if index == 0 {
                                            KFImage(ranking1)
                                                .placeholder {
                                                    Color.clear
                                                        .frame(width: 25, height: 28)
                                                }
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 25, height: 28)
                                        } else if index == 1 {
                                            KFImage(ranking2)
                                                .placeholder {
                                                    Color.clear
                                                        .frame(width: 25, height: 28)
                                                }
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 25, height: 28)
                                        } else if index == 2 {
                                            KFImage(ranking3)
                                                .placeholder {
                                                    Color.clear
                                                        .frame(width: 25, height: 28)
                                                }
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 25, height: 28)
                                        }
                                    } else {
                                        Color.clear
                                            .frame(width: 25, height: 28)
                                            .overlay {
                                                Text("\(index + 1)")
                                                    .font(.system(size: 16))
                                                    .foregroundStyle(Color("text-1"))
                                            }
                                    }

                                    // 头像
                                    NavigationLink(destination: MainView(user_id: item.user_id)) {
                                        KFImage(URL(string: item.avatar ?? defaultAvatar))
                                            .placeholder {
                                                Circle()
                                                    .fill(Color("skeleton-background"))
                                                    .frame(width: 46, height: 46)
                                            }
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 46, height: 46)
                                            .clipShape(Circle())
                                            .overlay {
                                                if index == 0 && item.experiences != nil && item.experiences ?? 0 > 0 {
                                                    // 皇冠
                                                    KFImage(URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/ranking-crown.png"))
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 25, height: 25)
                                                        .offset(x: 15, y: -22)
                                                }
                                            }
                                    }

                                    HStack(alignment: .top) {
                                        // 文案
                                        VStack(alignment: .leading, spacing: 7) {
                                            Text("\(item.nick_name ?? "")")
                                                .foregroundStyle(Color("text-1"))
                                                .font(.system(size: 16))

                                            HStack {
                                                Text("今日共打卡")
                                                Text("\(item.count)")
                                                    .foregroundStyle(Color("theme-1"))
                                                Text("个地点")
                                            }
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color("text-1"))
                                        }

                                        Spacer()

                                        Text("\(item.experiences ?? 0)")
                                            .font(.system(size: 30))
                                            .foregroundStyle(Color(hex: "#F8D035"))
                                    }
                                }
                                .padding(.vertical, 17)
                                .padding(.trailing, 15)
                                .padding(.leading, 16)
                                .background(Color("background-1"))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .visualEffect { content, proxy in
                                    // https://github.com/abdulrahimiliasu/swiftystuff/blob/main/swiftystuff/scrollingstackview/ScollingStackView.swift
                                    let frame = proxy.frame(in: .scrollView(axis: .vertical))
                                    let _ = proxy
                                        .bounds(of: .scrollView(axis: .vertical)) ??
                                        .infinite

                                    // 视图延伸到底部边缘的距离
                                    // 滚动视图
                                    let distance = min(0, frame.minY)

                                    return content
                                        .hueRotation(.degrees(frame.origin.y / 20))
                                        .scaleEffect(1 + distance / 800)
                                        .offset(y: -distance / 1.25)
                                        .brightness(-distance / 400)
                                        .blur(radius: -distance / 50)
                                }
                            }
                        } else {
                            EmptyState(title: "暂无数据")
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
                await rankingData.friendGetExperienceRanking() // 获取朋友经验排行榜
            }
        }
    }
}

#Preview {
    RankingView()
        .environmentObject(RankingData())
}
