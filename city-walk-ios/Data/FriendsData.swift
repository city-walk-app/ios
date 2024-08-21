//
//  FriendsData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/21.
//

import Foundation
import SwiftUI

class FriendsData: ObservableObject {
    /// 朋友列表
    @Published var friends: [FriendListType.FriendListData] = []
    /// 朋友列表是否在加载中
    @Published var isFriendsLoading = true

    /// 获取朋友列表
    func friendList() async {
        do {
            withAnimation {
                isFriendsLoading = true
            }

            let res = try await Api.shared.friendList(params: [:])

            print("获取朋友列表", res)

            withAnimation {
                isFriendsLoading = false
            }

            guard res.code == 200, let data = res.data else {
                return
            }

            withAnimation {
                friends = data
            }
        } catch {
            print("获取朋友列表异常")
            withAnimation {
                isFriendsLoading = false
            }
        }
    }
}
