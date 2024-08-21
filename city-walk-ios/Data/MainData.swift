//
//  MainData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/21.
//

import Foundation
import SwiftUI

class MainData: ObservableObject {
//    @Published var user_id: String
    /// 省份列表
    @Published var provinceList: [GetUserProvinceJigsawType.GetUserProvinceJigsawData] = []
    /// 热力图
    @Published var heatmap: [GetLocationUserHeatmapType.GetLocationUserHeatmapData] = []
    /// 步行记录列表
    @Published var routeList: [GetUserRouteListType.GetUserRouteListData] = []
    /// 步行记录详情列表
    @Published var routeDetailList: [GetLocationUserHeatmapType.GetLocationUserHeatmapDataRoutes]?
    /// 步行记录详情列表是否在加载中
    @Published var isRouteDetailListLoading = true
//
//    /// 获取用户步行记录列表
//    func getUserRouteList() async {
//        do {
//            withAnimation {
//                self.isRouteDetailListLoading = true
//            }
//
//            let res = try await Api.shared.getUserRouteList(params: ["user_id": user_id])
//
//            withAnimation {
//                self.isRouteDetailListLoading = false
//            }
//
//            guard res.code == 200, let data = res.data else {
//                return
//            }
//
//            withAnimation {
//                self.routeList = data
//            }
//        } catch {
//            print("获取用户步行记录列表异常")
//            withAnimation {
//                self.isRouteDetailListLoading = false
//            }
//        }
//    }
//
//    /// 获取用户解锁的省份版图列表
//    func getUserProvinceJigsaw() async {
//        do {
//            let res = try await Api.shared.getUserProvinceJigsaw(params: ["user_id": user_id])
//
//            guard res.code == 200, let data = res.data else {
//                return
//            }
//
//            withAnimation {
//                self.provinceList = data
//            }
//        } catch {
//            print("获取用户解锁的省份版图列表异常")
//        }
//    }
//
//    /// 获取用户信息
//    func getUserInfo() async {
//        do {
//            let res = try await Api.shared.getUserInfo(params: ["user_id": user_id])
//
//            guard res.code == 200, let data = res.data else {
//                return
//            }
//
//            withAnimation {
//                self.userInfo = data
//            }
//        } catch {
//            print("获取用户信息异常")
//        }
//    }
//
//    /// 获取用户指定月份打卡热力图
//    func getLocationUserHeatmap() async {
//        do {
//            let res = try await Api.shared.getLocationUserHeatmap(params: ["user_id": user_id])
//
//            guard res.code == 200, let data = res.data else {
//                return
//            }
//
//            withAnimation {
//                self.heatmap = data
//            }
//        } catch {
//            print("取用户指定月份打卡热力图异常")
//        }
//    }
}
