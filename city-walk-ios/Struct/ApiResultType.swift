//
//  ApiResultType.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import Foundation

// 用户信息
struct UserInfoType: Codable {
    var user_id: String
    var nick_name: String
    var email: String
    var mobile: String?
    var avatar: String?
    var signature: String?
    var birthday: String?
    var gender: String?
}

/// 获取用户解锁的省份版图列表
struct GetUserProvinceJigsawType: Decodable {
    struct GetUserProvinceJigsawData: Codable, Hashable {
        var background_color: String
        var experience_value: Int
        var province_code: String
        var province_name: String
        var vis_id: String
    }

    var message: String
    var code: Int
    var data: [GetUserProvinceJigsawData]?
}

/// 获取用户信息
struct GetUserInfoType: Decodable {
    var message: String
    var code: Int
    var data: UserInfoType?
}

/// 获取邮箱验证码
struct EmailSendType: Decodable {
    var message: String
    var code: Int
}

/// 邮箱验证码登录
struct UserLoginEmailType: Decodable {
    struct UserLoginEmailData: Codable {
        var token: String
        var is_new_user: Bool
        var user_info: UserInfoType
    }

    var message: String
    var code: Int
    var data: UserLoginEmailData?
}

/// 获取用户的动态发布日历热力图
struct UserGetCalendarHeatmap: Decodable {
    struct UserGetCalendarHeatmapDataItemCount: Codable, Hashable {
        var id: Int
        var user_id: Int
        var create_at: String
        var route_detail: Int
        var city: String
        var province: String
        var type: String
    }

    struct UserGetCalendarHeatmapDataItem: Codable, Hashable {
        var date: String
        var opacity: Double
        var count: [UserGetCalendarHeatmapDataItemCount]
    }

    var message: String
    var code: Int
    var data: [[UserGetCalendarHeatmapDataItem]]?
}

/// 获取指定用户去过的省份
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

/// 获取用户步行记录
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

/// 获取朋友经验排行榜
struct FriendGetExperienceRankingType: Decodable {
    struct FriendGetExperienceRankingData: Codable {
        var avatar: String?
        var count: Int
        var experiences: Int?
        var nick_name: String?
        var user_id: String
    }

    var message: String
    var code: Int
    var data: [FriendGetExperienceRankingData]?
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

/// 获取周边热门地点
struct GetPopularLocations: Decodable {
    struct GetPopularLocationsData: Codable {
        var longitude: Double
        var latitude: Double
        var name: String
        var province: String
        var city: String
    }

    var message: String
    var code: Int
    var data: [GetPopularLocationsData]?
}

/// 获取朋友列表
struct FriendListType: Decodable {
    struct FriendListData: Codable, Hashable {
        var user_id: String
        var nick_name: String?
        var avatar: String?
    }

    var message: String
    var code: Int
    var data: [FriendListData]?
}

/// 获取用户步行记录详情
struct GetUserRouteDetailType: Decodable {
    struct GetUserRouteDetailData: Codable {
        var address: String?
        var city: String?
        var content: String?
        var create_at: String
        var experience_value: Int?
        var id: Int
        var latitude: String
        var list_id: String
        var longitude: String
        var mood_color: String?
        var picture: [String]?
        var province: String?
        var province_code: String?
        var route_id: String
        var travel_type: String?
        var user_id: String
    }

    var message: String
    var code: Int
    var data: [GetUserRouteDetailData]?
}

/// 创建当前位置信息
struct LocationCreateRecordType: Decodable {
    struct LocationCreateRecordData: Codable {
        var background_color: String?
        var city: String?
        var content: String?
        var experience: Int
        var is_in_china: Bool
        var is_new_province: Bool?
        var province: String?
        var province_code: String?
        var route_id: String
        var province_url: String?
    }

    var message: String
    var code: Int
    var data: LocationCreateRecordData?
}

/// 完善步行打卡记录详情
struct UpdateRouteDetailType: Decodable {
    var message: String
    var code: Int
    var data: String?
}

/// 获取周边热门地点
struct GetLocationPopularRecommendType: Decodable {
    struct GetLocationPopularRecommendData: Codable {
        var city: String?
        var latitude: Double?
        var longitude: Double?
        var name: String?
        var province: String?
    }

    var message: String
    var code: Int
    var data: [GetLocationPopularRecommendData]?
}

/// 获取周边地址
struct GetAroundAddressType: Decodable {
    struct GetAroundAddressData: Codable {
        var city: String?
        var latitude: Double?
        var longitude: Double?
        var name: String?
        var province: String?
        var address: String?
    }

    var message: String
    var code: Int
    var data: [GetAroundAddressData]?
}

/// 设置用户信息
struct SetUserInfoType: Decodable {
    var message: String
    var code: Int
    var data: UserInfoType?
}

/// 上传公开文件
struct UniversalContentUploadType: Decodable {
    struct UniversalContentUploadData: Codable {
        var host: String
        var policy: String
        var OSSAccessKeyId: String
        var signature: String
        var key: String
    }

    var message: String
    var code: Int
    var data: UniversalContentUploadData?
}

/// 获取今天的打卡记录
struct GetTodayRecordType: Decodable {
    struct GetTodayRecordData: Codable {
        var latitude: String
        var longitude: String
        var content: String?
        var create_at: String
        var travel_type: String?
        var province_code: String?
        var picture: [String]?
        var list_id: String
    }

    var message: String
    var code: Int
    var data: [GetTodayRecordData]?
}

/// 邀请朋友
struct FriendInviteType: Decodable {
    var message: String
    var code: Int
    var data: String?
}

/// 获取邀请详情
struct GetFriendInviteInfoType: Decodable {
    struct GetFriendInviteInfoData: Codable {
        var name: String?
        var nick_name: String?
    }

    var message: String
    var code: Int
    var data: GetFriendInviteInfoData?
}

/// 同意好友申请
struct FriendConfirmInviteType: Decodable {
    var message: String
    var code: Int
}

/// 获取用户步行历史记录
struct GetUserRouteHistoryType: Decodable {
    /// 获取用户步行历史记录-热力图-步行记录
    struct GetUserRouteHistoryDataHeatmapRoute: Codable {
        var create_at: String?
        var city: String?
        var province: String?
        var content: String?
        var address: String?
        var picture: [String]?
        var travel_type: String?
        var mood_color: String?
    }

    /// 获取用户步行历史记录-热力图
    struct GetUserRouteHistoryDataHeatmap: Codable {
        var date: String
        var background_color: String?
        var list_id: String?
        var route_count: Int?
        var routes: [GetUserRouteHistoryDataHeatmapRoute]
    }

    /// 获取用户步行历史记录-步行记录
    struct GetUserRouteHistoryRoute: Codable {
        var list_id: String
        var create_at: String
        var mood_color: String?
        var travel_type: String?
        var count: Int
    }

    /// 获取用户步行历史记录-数据
    struct GetUserRouteHistoryData: Codable {
        var routes: [GetUserRouteHistoryRoute]
        var heatmaps: [GetUserRouteHistoryDataHeatmap]
    }

    var message: String
    var code: Int
    var data: GetUserRouteHistoryData?
}
