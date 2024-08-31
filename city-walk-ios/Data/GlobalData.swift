//
//  GlobalData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/30.
//

import Foundation

enum ToastType {
    case toast, loading
}

/// 全球的数据
class GlobalData: ObservableObject {
    /// 是否显示 toast
    @Published var isShowToast = false
    /// toast 提示文案
    @Published var toastMessage = ""
    /// 提示类型
    @Published var toastType: ToastType = .toast

    /// 显示 toast
    /// - Parameter title: 标题
    func showToast(title: String) {
        self.toastMessage = title
        self.toastType = .toast
        self.isShowToast.toggle()
    }

    func showLoading(title: String?) {
        self.toastMessage = title ?? "加载中..."
        self.toastType = .loading
        self.isShowToast = true
    }

    func hiddenLoading() {
        self.isShowToast = false
    }
}
