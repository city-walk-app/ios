//
//  Window.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/21.
//

import SwiftUI

/// 获取顶部安全距离
/// - Returns: 安全尺寸
func getTopSafeAreaInsets() -> CGFloat {
    let window = UIApplication.shared.windows.first
    return window?.safeAreaInsets.top ?? 0
}

/// 顶部安全距离
let topSafeAreaInsets = getTopSafeAreaInsets()
