//
//  Gender.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/27.
//

import Foundation

/// 性别
enum Genders: String, CaseIterable {
    case male = "1"
    case female = "2"
    case privacy = "3"

    init(value: String) {
        switch value {
        case "1":
            self = .male
        case "2":
            self = .female
        case "3":
            self = .privacy
        default:
            self = .male
        }
    }

    var sex: String {
        switch self {
        case .male:
            return "男"
        case .female:
            return "女"
        case .privacy:
            return "不愿透露"
        }
    }

    /// 根据字符串获取对应的枚举值
    static func from(value: String) -> Genders {
        return Genders(value: value)
    }
}
