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
    func getUserInfo(params: [String: Any]) async throws -> UserInfo {
        print("获取用户信息", params)
        return try await Request.shared.request(
            url: "/user/get/user_info",
            params: params,
            method: .post,
            type: UserInfo.self
        )
    }
    
    func userLoginEmail(params: [String: Any]) async throws -> UserLoginEmail {
        return try await Request.shared.request(
            url: "/user/login/email",
            params: params,
            method: .post,
            type: UserLoginEmail.self
        )
    }
    
    func setUserInfo(params: [String: Any]) async throws -> UserLoginEmail {
        return try await Request.shared.request(
            url: "/user/set/user_info",
            params: params,
            method: .post,
            type: UserLoginEmail.self
        )
    }
    
    /// 获取邮箱验证码
    func emailSend(params: [String: Any]) async throws -> EmailSend {
        print("请求参数", params)
        return try await Request.shared.request(
            url: "/email/send",
            params: params,
            method: .post,
            type: EmailSend.self
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
