//
//  TabbarData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/4.
//

import Foundation

class TabbarData: ObservableObject {
    /// 排行榜数据
    @Published var rankingData: [ExperienceRanking.ExperienceRankingData] = []

    /// 步行记录数据
    @Published var routerData: [GetRouteList.GetRouteListData] = []

    /// 设置排行榜数据
    /// - Parameter data: 数据
    func setRankingData(_ data: [ExperienceRanking.ExperienceRankingData]) {
        self.rankingData = data
    }

    /// 设置步行记录数据
    /// - Parameter data: 数据
    func setRouterData(_ data: [GetRouteList.GetRouteListData]) {
        self.routerData = data
    }
}
