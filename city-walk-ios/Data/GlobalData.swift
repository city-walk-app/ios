//
//  GlobalData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/30.
//

import Foundation

/// 全球的数据
class GlobalData: ObservableObject {
    /// 是否显示 toast
    @Published var isShowToast = false
    /// toast 提示文案
    @Published var toastMessage = ""

    /// 显示 toast
    /// - Parameter title: 标题
    func showToast(title: String) {
        self.toastMessage = title
        self.isShowToast.toggle()
    }
}
