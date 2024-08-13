//
//  MainView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

struct MainView: View {
    var user_id: String

    let API = Api()

    /// 省份列表
    @State private var provinceList: [GetUserProvinceJigsawType.GetUserProvinceJigsawData] = []
    /// 热力图
    @State private var heatmap: [GetLocationUserHeatmapType.GetLocationUserHeatmapData] = []
    /// 步行记录列表
    @State private var routeList: [GetUserRouteListType.GetUserRouteListData] = []
    /// 用户的身份信息
    @State private var userInfo: UserInfoType?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                // 用户信息
                if let userInfo = self.userInfo {
                    // 头像
                    AsyncImage(url: URL(string: userInfo.avatar ?? defaultAvatar)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 74, height: 74) // 设置图片的大小
                            .clipShape(Circle()) // 将图片裁剪为圆形
                    } placeholder: {
                        // 占位符，图片加载时显示的内容
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 74, height: 74) // 占位符的大小与图片一致
                            .overlay(Text("加载失败").foregroundColor(.white))
                    }

                    // 昵称
                    Text("\(userInfo.nick_name)")

                    // 签名
                    Text("\(userInfo.signature ?? "")")
                } else {
                    Text("用户信息加载中")
                }

                // 省份版图
                if !self.provinceList.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(self.provinceList, id: \.vis_id) { item in
                                AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/provinces/\(item.province_code).png")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 107, height: 107) // 设置图片的大小
                                        .clipShape(Circle()) // 将图片裁剪为圆形
                                } placeholder: {
                                    // 占位符，图片加载时显示的内容
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 107, height: 107) // 占位符的大小与图片一致
                                        .overlay(Text("加载失败").foregroundColor(.white))
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                } else {
                    Text("暂无版图")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .onAppear {
            Task {
                await self.loadUserInfo() // 获取用户信息
                await self.getLocationUserHeatmap() // 获取用户指定月份打卡热力图
                await self.getUserProvinceJigsaw() // 获取用户解锁的省份版图列表
                await self.getUserRouteList() // 获取用户步行记录列表
            }
        }
    }

    /// 获取用户步行记录列表
    private func getUserRouteList() async {
        do {
            let res = try await Api.shared.getUserRouteList(params: ["user_id": self.user_id])

            print("获取用户步行记录列表", res)

            if res.code == 200 && res.data != nil {
                self.routeList = res.data!
            }
        } catch {
            print("获取用户步行记录列表异常")
        }
    }

    /// 获取用户解锁的省份版图列表
    private func getUserProvinceJigsaw() async {
        do {
            let res = try await Api.shared.getUserProvinceJigsaw(params: ["user_id": self.user_id])

            print("获取用户解锁的省份版图列表", res)

            if res.code == 200 && res.data != nil {
                self.provinceList = res.data!
            }
        } catch {
            print("获取用户解锁的省份版图列表异常")
        }
    }

    /// 获取用户信息
    private func loadUserInfo() async {
        do {
            let res = try await Api.shared.getUserInfo(params: ["user_id": self.user_id])

            print("我的页面获取的用户信息", res)

            if res.code == 200 && res.data != nil {
                self.userInfo = res.data!
            }
        } catch {
            print("获取用户信息异常")
        }
    }

    /// 获取用户指定月份打卡热力图
    private func getLocationUserHeatmap() async {
        do {
            let res = try await Api.shared.getLocationUserHeatmap(params: ["user_id": self.user_id])

            print("我的页面获取用户指定月份打卡热力图", res)

            if res.code == 200 && res.data != nil {
                self.heatmap = res.data!
            }

        } catch {
            print("取用户指定月份打卡热力图异常")
        }
    }
}

#Preview {
    MainView(user_id: "U131995175454824711531011225172573302849")
        .environmentObject(UserInfoData())
        .environmentObject(GlobalData())
}
