//
//  TravelType.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/29.
//

import Foundation

/// 出行方式
enum TravelTypeKey: String, CaseIterable {
    // 步行
    case WALKING
    
    // 自行车
    case BICYCLE
    
    // 汽车
    case CAR
    
    // 公交车
    case BUS
    
    // 地铁
    case METRO
    
    // 火车
    case TRAIN
    
    // 飞机
    case AIRPLANE
    
    // 船
    case SHIP
    
    static func getTravelType(from value: String) -> TravelTypeKey? {
        return TravelTypeKey(rawValue: value)
    }
}

struct TravelType {
    var icon: String
    var key: TravelTypeKey
}

/// 出行方式集合
let travelTypes = [
    TravelType(icon: "figure.walk", key: .WALKING),
    TravelType(icon: "bicycle", key: .BICYCLE),
    TravelType(icon: "car.rear", key: .CAR),
    TravelType(icon: "bus.fill", key: .BUS),
    TravelType(icon: "tram.fill.tunnel", key: .METRO), // 地铁
    TravelType(icon: "tram.fill", key: .TRAIN), // 火车
    TravelType(icon: "airplane", key: .AIRPLANE), // 飞机
    TravelType(icon: "ferry", key: .SHIP), // 船
]
