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
    @Published var data: UserInfo.UserInfoData?

    /// 设置方法，用于更新用户信息并发布通知
    func set(_ newData: UserInfo.UserInfoData) {
        data = newData
    }
}
