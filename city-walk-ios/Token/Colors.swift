//
//  Colors.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/17.
//

import SwiftUI

/// 骨架图背景色
let skeletonBackground = Color("skeleton-background")

/// 页面渐变背景色
let viewBackground = LinearGradient(
    gradient: Gradient(stops: [
        .init(color: Color(hex: "#F8D035").opacity(0.4), location: 0.0),
        .init(color: Color(hex: "#FFDC97").opacity(0.12), location: 0.15),
        .init(color: Color(hex: "#FFFFFF").opacity(0.0), location: 0.35),
    ]),
    startPoint: .init(x: 0.98, y: 0.03),
    endPoint: .init(x: 0.4, y: 0.97)
)
