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
    private let USER_TOKEN = "USER_TOKEN"

    private let userDefaults = UserDefaults.standard

    /// 存储信息
    func saveInfo(info: UserInfoType) {
        do {
            let codeData = try JSONEncoder().encode(info)
            userDefaults.set(codeData, forKey: USER_INFO)
        } catch {
            print("格式转换错误")
        }
    }

    /// 获取信息
    func getInfo() -> UserInfoType? {
        if let data = userDefaults.data(forKey: USER_INFO),
           let userData = try? JSONDecoder().decode(UserInfoType.self, from: data)
        {
            return userData
        }

        return nil
    }

    /// 删除信息
    func clearAll() {
        userDefaults.removeObject(forKey: USER_INFO)
        userDefaults.removeObject(forKey: USER_TOKEN)
    }

    /// 设置 token
    func saveToken(token: String) {
        userDefaults.set(token, forKey: USER_TOKEN)
    }

    func getToken() -> String {
        if let token = userDefaults.string(forKey: USER_TOKEN) {
            return token
        }

        return ""
    }
}
