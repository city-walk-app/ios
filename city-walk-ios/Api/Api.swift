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
    func userLoginEmail(params: [String: Any]) async throws -> UserLoginEmailType {
        return try await Request.shared.request(
            url: "/user/login/email",
            params: params,
            method: .post,
            type: UserLoginEmailType.self
        )
    }

    /// 获取邮箱验证码
    func emailSend(params: [String: Any]) async throws -> EmailSendType {
        return try await Request.shared.request(
            url: "/email/send",
            params: params,
            method: .post,
            type: EmailSendType.self
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
    
    /// 上传公开文件
    func universalContentUpload(params: [String: Any]) async throws -> UniversalContentUploadType {
        return try await Request.shared.request(
            url: "/universal/content/upload",
            params: params,
            method: .post,
            type: UniversalContentUploadType.self
        )
    }
    
    /// 获取周边地址
    func getAroundAddress(params: [String: Any]) async throws -> GetAroundAddressType {
        return try await Request.shared.request(
            url: "/location/get/around/address",
            params: params,
            method: .post,
            type: GetAroundAddressType.self
        )
    }
    
    /// 获取今天的打卡记录
    func getTodayRecord(params: [String: Any]) async throws -> GetTodayRecordType {
        return try await Request.shared.request(
            url: "/location/get/today/record",
            params: params,
            method: .post,
            type: GetTodayRecordType.self
        )
    }
    
    /// 邀请朋友
    func friendInvite(params: [String: Any]) async throws -> FriendInviteType {
        return try await Request.shared.request(
            url: "/friend/invite",
            params: params,
            method: .post,
            type: FriendInviteType.self
        )
    }
    
    /// 获取邀请详情
    func getFriendInviteInfo(params: [String: Any]) async throws -> GetFriendInviteInfoType {
        return try await Request.shared.request(
            url: "/friend/get/invite/info",
            params: params,
            method: .post,
            type: GetFriendInviteInfoType.self
        )
    }
    
    /// 同意好友申请
    func friendConfirmInvite(params: [String: Any]) async throws -> FriendConfirmInviteType {
        return try await Request.shared.request(
            url: "/friend/confirm/invite",
            params: params,
            method: .post,
            type: FriendConfirmInviteType.self
        )
    }
    
    /// 获取用户步行历史记录
    func getUserRouteHistory(params: [String: Any]) async throws -> GetUserRouteHistoryType {
        return try await Request.shared.request(
            url: "/location/get/user/route/history",
            params: params,
            method: .post,
            type: GetUserRouteHistoryType.self
        )
    }
}
