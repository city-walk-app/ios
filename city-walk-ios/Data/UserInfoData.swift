//
//  UserInfoData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/3.
//

import Foundation

class UserInfoData: ObservableObject {
    /// 用户信息
    /// 使用 @Published 修饰符确保在更改时发送通知
    @Published var data: UserInfoType?
    /// 缓存信息
    let cacheInfo = UserCache.shared.getInfo()

    /// 设置方法，用于更新用户信息并发布通知
    func set(_ newData: UserInfoType) {
        // 设置值的时候使用 DispatchQueue.main.async
        // 避免报错：Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates.
        DispatchQueue.main.async {
            self.data = newData
        }
    }
}
