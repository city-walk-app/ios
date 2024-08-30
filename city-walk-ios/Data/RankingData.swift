//
//  RankingData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/21.
//

import Foundation
import SwiftUI

/// 排行榜数据
class RankingData: ObservableObject {
    /// 排名列表
    @Published var rankingList: [FriendGetExperienceRankingType.FriendGetExperienceRankingData] = []
    /// 排名列表是否加载中
    @Published var isRankingListLoading = true

    /// 获取朋友经验排行榜
    func friendGetExperienceRanking() async {
        do {
            if self.rankingList.isEmpty {
                withAnimation {
                    self.isRankingListLoading = true
                }
            }

            let res = try await Api.shared.friendGetExperienceRanking(params: [:])

            withAnimation {
                self.isRankingListLoading = false
            }

            guard res.code == 200, let data = res.data else {
                return
            }

            withAnimation {
                self.rankingList = data
            }
        } catch {
            withAnimation {
                self.isRankingListLoading = false
            }
            print("获取朋友经验排行异常")
        }
    }
}
