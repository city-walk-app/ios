//
//  LoadingData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/22.
//

import Foundation
import SwiftUI

struct LoadingParams {
    var title: String?
}

/// 加载中数据
class LoadingData: ObservableObject {
    @Published var isLoading = false
    @Published var title = "加载中..."

    /// 显示 loading
    /// - Parameter options: 配置参数
    func showLoading(options: LoadingParams) {
        if let optionsTitle = options.title {
            self.title = optionsTitle
        }

        withAnimation {
            self.isLoading = true
        }

        print("点击了开始 loading", self.isLoading)
    }

    /// 隐藏 loading
    func hiddenLoading() {
        withAnimation {
            self.isLoading = false
        }
    }
}
