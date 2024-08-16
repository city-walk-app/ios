//
//  Api.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/7/15.
//

import Foundation

/// API 类
class Api {
    static let shared = Api()
    
    /// 获取用户信息
    func getUserInfo(params: [String: String]) async throws -> GetUserInfoType {
        return try await Request.shared.request(
            url: "/user/get/user_info",
            params: params,
            method: .post,
            type: GetUserInfoType.self
        )
    }
    
    /// 邮箱验证码登录
    func userLoginEmail(params: [String: Any]) async throws -> UserLoginEmail {
        return try await Request.shared.request(
            url: "/user/login/email",
            params: params,
            method: .post,
            type: UserLoginEmail.self
        )
    }
    
    /// 获取用户指定月份打卡热力图
    func getLocationUserHeatmap(params: [String: Any]) async throws -> GetLocationUserHeatmapType {
        return try await Request.shared.request(
            url: "/location/get/user/heatmap",
            params: params,
            method: .post,
            type: GetLocationUserHeatmapType.self
        )
    }
    
    /// 获取邮箱验证码
    func emailSend(params: [String: Any]) async throws -> EmailSend {
        return try await Request.shared.request(
            url: "/email/send",
            params: params,
            method: .post,
            type: EmailSend.self
        )
    }
    
    /// 获取用户解锁的省份版图列表
    func getUserProvinceJigsaw(params: [String: Any]) async throws -> GetUserProvinceJigsawType {
        return try await Request.shared.request(
            url: "/location/get/user/province/jigsaw",
            params: params,
            method: .post,
            type: GetUserProvinceJigsawType.self
        )
    }
    
    /// 获取用户步行记录列表
    func getUserRouteList(params: [String: Any]) async throws -> GetUserRouteListType {
        return try await Request.shared.request(
            url: "/location/get/user/route/list",
            params: params,
            method: .post,
            type: GetUserRouteListType.self
        )
    }
    
    /// 获取朋友列表
    func friendList(params: [String: Any]) async throws -> FriendListType {
        return try await Request.shared.request(
            url: "/friend/list",
            params: params,
            method: .post,
            type: FriendListType.self
        )
    }
    
    /// 获取朋友经验排行榜
    func friendGetExperienceRanking(params: [String: Any]) async throws -> FriendGetExperienceRankingType {
        return try await Request.shared.request(
            url: "/friend/get/experience/ranking",
            params: params,
            method: .post,
            type: FriendGetExperienceRankingType.self
        )
    }
    
    /// 获取用户步行记录详情
    func getUserRouteDetail(params: [String: Any]) async throws -> GetUserRouteDetailType {
        return try await Request.shared.request(
            url: "/location/get/user/route/detail",
            params: params,
            method: .post,
            type: GetUserRouteDetailType.self
        )
    }
    
    /// 获取用户步行记录详情
    func locationCreateRecord(params: [String: Any]) async throws -> LocationCreateRecordType {
        return try await Request.shared.request(
            url: "/location/create/record",
            params: params,
            method: .post,
            type: LocationCreateRecordType.self
        )
    }
    
    /// 完善步行打卡记录详情
    func updateRouteDetail(params: [String: Any]) async throws -> UpdateRouteDetailType {
        return try await Request.shared.request(
            url: "/location/update/user/route/detail",
            params: params,
            method: .post,
            type: UpdateRouteDetailType.self
        )
    }
    
    /// 获取周边热门地点
    func getLocationPopularRecommend(params: [String: Any]) async throws -> GetLocationPopularRecommendType {
        return try await Request.shared.request(
            url: "/location/get/popular/recommend",
            params: params,
            method: .post,
            type: GetLocationPopularRecommendType.self
        )
    }
    
    /// 设置用户信息
    func setUserInfo(params: [String: Any]) async throws -> SetUserInfoType {
        return try await Request.shared.request(
            url: "/user/set/user_info",
            params: params,
            method: .post,
            type: SetUserInfoType.self
        )
    }
}
