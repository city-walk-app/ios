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
    
    func experienceRanking(params: [String: Any]) async throws -> ExperienceRanking {
        return try await Request.shared.request(
            url: "/experience/ranking",
            params: params,
            method: .post,
            type: ExperienceRanking.self
        )
    }
}
