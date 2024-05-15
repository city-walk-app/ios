//
//  ApiResultType.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import Foundation

// 获取用户信息
struct UserInfo: Decodable {
    struct UserInfoData: Codable {
        var id: Int
        var nick_name: String?
        var email: String
        var mobile: String?
        var avatar: String?
        var signature: String?
        var province: String?
        var city: String?
        var created_at: String?
        var birthday: String?
        var gender: String?
        var ip_address: String?
        var ip_info: String?
    }

    var message: String
    var code: Int
    var data: UserInfoData?
}

// 获取邮箱验证码
struct EmailSend: Decodable {
    var message: String
    var code: Int
}

// 邮箱验证码登录
struct UserLoginEmail: Decodable {
    struct UserLoginEmailData: Codable {
        var token: String
        var is_new_user: Bool
        var id: Int
        var email: String
        var avatar: String
    }

    var message: String
    var code: Int
    var data: UserLoginEmailData?
}

// 获取用户的动态发布日历热力图
struct UserGetCalendarHeatmap: Decodable {
    struct UserGetCalendarHeatmapDataItem: Codable, Hashable {
        struct UserGetCalendarHeatmapDataItemCount: Codable, Hashable {
            var id: Int
            var user_id: Int
            var create_at: String
            var route_detail: Int
            var city: String
            var province: String
            var type: String
        }

        var date: String
        var opacity: Double
        var count: [UserGetCalendarHeatmapDataItemCount]
    }

    var message: String
    var code: Int
    var data: [[UserGetCalendarHeatmapDataItem]]?
}

// 获取指定用户去过的省份
struct GetUserProvince: Decodable {
    struct GetUserProvinceData: Codable {
        var id: Int
        var province_code: String
        var user_id: Int
        var province_name: String
        var experience_value: Int
    }

    var message: String
    var code: Int
    var data: [GetUserProvinceData]?
}

// 获取用户步行记录
struct GetRouteList: Decodable {
    struct GetRouteListData: Codable {
        var route_detail: Int
        var city: String
        var province: String
        var id: Int
        var user_id: Int
        var create_at: String
    }

    var message: String
    var code: Int
    var data: [GetRouteListData]?
}

// 获取经验排行榜
struct ExperienceRanking: Decodable {
    struct ExperienceRankingData: Codable {
        struct UserInfo: Codable {
            var avatar: String?
            var nick_name: String?
            var gender: String?
        }

        var user_info: UserInfo
        var id: Int
        var province_code: String
        var user_id: Int
        var province_name: String
        var experience_value: Int
    }

    var message: String
    var code: Int
    var data: [ExperienceRankingData]?
}

/// 获取指定步行记录历史打卡记录列表
struct GpsGetRouteHistory: Decodable {
    struct GpsGetRouteHistoryData: Codable {
        var id: Int
        var list_id: Int
        var user_id: Int
        var create_at: String
        var city: String
        var province: String
        var address: String
        var latitude: String
        var longitude: String
        var name: String
        var province_code: String
    }

    var message: String
    var code: Int
    var data: [GpsGetRouteHistoryData]?
}

/// 创建当前位置记录
struct CreatePositionRecord: Decodable {
    /// 创建当前位置记录 - 新地点的信息
    struct CreatePositionRecordDataMewProvince: Codable {
        var id: Int
        var province_code: String
        var user_id: Int
        var province_name: String
        var experience_value: String
    }

    /// 创建当前位置记录 - Data
    struct CreatePositionRecordData: Codable {
        var id: Int
        var list_id: Int
        var user_id: Int
        var create_at: String
        var city: String
        var province: String
        var address: String
        var latitude: String
        var longitude: String
        var name: String
        var province_code: String
        var new_province: CreatePositionRecordDataMewProvince?
    }

    var message: String
    var code: Int
    var data: CreatePositionRecordData?
}

/// 基本的返回数据
struct BasicResult: Decodable {
    var message: String
    var code: Int
}
