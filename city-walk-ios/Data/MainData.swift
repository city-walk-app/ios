//
//  MainData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/21.
//

import Foundation
import SwiftUI

class MainData: ObservableObject {
    /// 选中的热力图元素索引
    @Published var routeDetailActiveIndex: Int?
    /// 用户的身份信息
    @Published var userInfo: UserInfoType?
    /// 省份列表
    @Published var provinceList: [GetUserProvinceJigsawType.GetUserProvinceJigsawData] = []
    /// 热力图
    @Published var heatmap: [GetUserRouteHistoryType.GetUserRouteHistoryDataHeatmap] = []
    /// 步行记录列表
    @Published var routeList: [GetUserRouteHistoryType.GetUserRouteHistoryRoute] = []
    /// 步行记录详情列表
    @Published var routeDetailList: [GetUserRouteHistoryType.GetUserRouteHistoryDataHeatmapRoute]?
    /// 步行记录详情列表是否在加载中
    @Published var isRouteHistoryLoading = true
    /// 省份版图是否在加载中
    @Published var isProvinceListLoading = true
    /// 用户 id
    @Published var user_id: String = ""
    /// 当前的年份
    @Published var year = Calendar.current.component(.year, from: Date())
    /// 当前的月份
    @Published var month = Calendar.current.component(.month, from: Date())

    /// 设置当前用户 id
    /// - Parameter user_id: 用户 id
    func setUserId(user_id: String) {
        // 和上一次访问的用户不一致
        if self.user_id != "" && self.user_id != user_id {
            userInfo = nil
            provinceList = []
            heatmap = []
            routeList = []
            routeDetailList = nil
            isRouteHistoryLoading = true
        }

        self.user_id = user_id
    }

    /// 获取用户步行历史记录
    func getUserRouteHistory() async {
        print("获取历史记录")
        do {
            if routeList.isEmpty {
                withAnimation {
                    isRouteHistoryLoading = true
                }
            }

            let res = try await Api.shared.getUserRouteHistory(params: [
                "user_id": user_id,
                "year": year,
                "month": month,
            ])

            print("获取用户步行历史记录", res)

            withAnimation {
                isRouteHistoryLoading = false
            }

            guard res.code == 200, let data = res.data else {
                return
            }

            withAnimation {
                routeList = data.routes
                heatmap = data.heatmaps
            }
        } catch {
            print("获取用户步行历史记录异常")
            withAnimation {
                isRouteHistoryLoading = false
            }
        }
    }

    /// 获取用户解锁的省份版图列表
    func getUserProvinceJigsaw() async {
        do {
            if provinceList.isEmpty {
                withAnimation {
                    isProvinceListLoading = true
                }
            }

            let res = try await Api.shared.getUserProvinceJigsaw(params: ["user_id": user_id])

            withAnimation {
                isProvinceListLoading = false
            }

            guard res.code == 200, let data = res.data else {
                return
            }

            withAnimation {
                self.provinceList = data
            }
        } catch {
            print("获取用户解锁的省份版图列表异常")
            isProvinceListLoading = false
        }
    }

    /// 获取用户信息
    func getUserInfo() async {
        do {
            let res = try await Api.shared.getUserInfo(params: ["user_id": user_id])

            guard res.code == 200, let data = res.data else {
                return
            }

            withAnimation {
                self.userInfo = data
            }
        } catch {
            print("获取用户信息异常")
        }
    }

    /// 页面隐藏
    func onDisappear() {
        routeDetailList = nil
        routeDetailActiveIndex = nil
        year = Calendar.current.component(.year, from: Date())
        month = Calendar.current.component(.month, from: Date())
    }
}
