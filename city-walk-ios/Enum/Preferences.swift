//
//  Preferences.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/15.
//

import Foundation

enum PreferenceKey {
    case ENTERTAINMENT,
         SPORTS_RECREATION,
         SHOPPING_SERVICE,
         FOOD_DINING,
         EDUCATION_CULTURE,
         PARK_SQUARE,
         SCENIC_SPOT,
         CAFE,
         DEFAULT
}

struct Preference {
    var key: PreferenceKey
    var title: String
    var active: Bool
}

var preferences = [
    Preference(key: .ENTERTAINMENT, title: "娱乐场所", active: false),
    Preference(key: .SPORTS_RECREATION, title: "体育休闲", active: false),
    Preference(key: .SHOPPING_SERVICE, title: "购物服务", active: false),
    Preference(key: .FOOD_DINING, title: "餐饮美食", active: false),
    Preference(key: .EDUCATION_CULTURE, title: "科教文化", active: false),
    Preference(key: .PARK_SQUARE, title: "公园广场", active: false),
    Preference(key: .SCENIC_SPOT, title: "风景名胜", active: false),
    Preference(key: .CAFE, title: "咖啡厅", active: false),
    Preference(key: .DEFAULT, title: "默认的", active: false),
]
