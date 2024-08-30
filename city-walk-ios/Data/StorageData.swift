//
//  UserInfoData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/3.
//
import Foundation

/// 缓存数据
class StorageData: ObservableObject {
    /// 用户信息
    @Published var userInfo: UserInfoType? {
        didSet {
            do {
                let codeData = try JSONEncoder().encode(userInfo)
                UserDefaults.standard.set(codeData, forKey: "USER_INFO")
            } catch {
                print("信息格式转换错误", error)
            }
        }
    }

    /// token
    @Published var token: String? {
        didSet {
            UserDefaults.standard.set(token, forKey: "USER_TOKEN")
        }
    }

    init() {
        self.token = StorageData.getToken()
        self.userInfo = StorageData.getUserInfo()
    }

    func clearCache() {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }

    /// 获取 token
    static func getToken() -> String {
        if let token = UserDefaults.standard.string(forKey: "USER_TOKEN") {
            return token
        }

        return ""
    }

    /// 获取信息
    static func getUserInfo() -> UserInfoType? {
        if let data = UserDefaults.standard.data(forKey: "USER_INFO"),
           let userData = try? JSONDecoder().decode(UserInfoType.self, from: data)
        {
            return userData
        }

        return nil
    }

    /// 设置 token
    /// - Parameter token: token
    func saveToken(token: String) {
        self.token = token
    }

    /// 存储信息
    /// - Parameter info: 用户信息
    func saveUserInfo(info: UserInfoType) {
        userInfo = info
    }
}
