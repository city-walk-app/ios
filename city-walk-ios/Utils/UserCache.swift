//
//  UserCache.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import Foundation

/// 用户身份信息缓存
class UserCache {
    static let shared = UserCache() // 创建单例模式

    private let USER_INFO = "USER_INFO"
    private let userDefaults = UserDefaults.standard

    /// 存储信息
    func saveInfo(info: UserLoginEmail.UserLoginEmailData) {
        do {
            let codeData = try JSONEncoder().encode(info)
            userDefaults.set(codeData, forKey: USER_INFO)
        } catch {
            print("格式转换错误")
        }
    }

    /// 获取信息
    func getInfo() -> UserLoginEmail.UserLoginEmailData? {
        if let data = userDefaults.data(forKey: USER_INFO),
           let userData = try? JSONDecoder().decode(UserLoginEmail.UserLoginEmailData.self, from: data)
        {
            return userData
        }

        return nil
    }

    /// 删除信息
    func deleteInfo() {
        userDefaults.removeObject(forKey: USER_INFO)
    }
}
