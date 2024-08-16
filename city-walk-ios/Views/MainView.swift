//
//  MainView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

struct MainView: View {
    var user_id: String

    /// 省份列表
    @State private var provinceList: [GetUserProvinceJigsawType.GetUserProvinceJigsawData] = []
    /// 热力图
    @State private var heatmap: [GetLocationUserHeatmapType.GetLocationUserHeatmapData] = []
    /// 步行记录列表
    @State private var routeList: [GetUserRouteListType.GetUserRouteListData] = []
    /// 用户的身份信息
    @State private var userInfo: UserInfoType?
    /// 步行记录详情列表
    @State private var routeDetailList: [GetLocationUserHeatmapType.GetLocationUserHeatmapDataRoutes] = []

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
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
                        .padding(.top, 16)
                        .foregroundStyle(Color(hex: "#333333"))
                        .font(.system(size: 18))

                    // 签名
                    Text("\(userInfo.signature ?? "")")
                        .padding(.top, 8)
                        .foregroundStyle(Color(hex: "#666666"))
                        .font(.system(size: 14))
                } else {
                    Text("用户信息加载中")
                }

                // 省份版图
                if !self.provinceList.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(self.provinceList, id: \.vis_id) { item in
                                Button {} label: {
                                    Color(hex: item.background_color)
                                        .frame(width: 107, height: 107)
                                        .mask(
                                            AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/provinces/\(item.province_code).png")) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 107, height: 107)
                                            } placeholder: {
                                                Rectangle()
                                                    .frame(width: 107, height: 107)
                                            }
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 17)
                    }
                    .scrollIndicators(.hidden)
                    .padding(.vertical, 24)
                } else {
                    Text("暂无版图")
                }

                // 日期选择
                HStack {
                    Spacer()

                    HStack {
                        Text("2024 年08月")
                            .foregroundStyle(Color(hex: "#9A9A9A"))
                            .font(.system(size: 12))

                        Image(systemName: "chevron.down")
                            .foregroundStyle(Color(hex: "#9A9A9A"))
                            .font(.system(size: 12))
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    .background(Color(hex: "#F3F3F3"))
                }
                .padding(.horizontal, 16)

                Spacer()

                // 热力图
                HStack {
                    // 图例
                    VStack(spacing: 30) {
                        HStack(spacing: 7) {
                            AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/main-heatmap-1.png")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 15, height: 17) // 设置图片的大小
                            } placeholder: {}

                            Text("打卡多")
                                .foregroundStyle(Color(hex: "#666666"))
                                .font(.system(size: 14))
                        }

                        HStack(spacing: 7) {
                            AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/main-heatmap-2.png")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 15, height: 17) // 设置图片的大小
                            } placeholder: {}

                            Text("打卡少")
                                .foregroundStyle(Color(hex: "#666666"))
                                .font(.system(size: 14))
                        }

                        HStack(spacing: 7) {
                            AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/main-heatmap-3.png")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 15, height: 17) // 设置图片的大小
                            } placeholder: {}

                            Text("未打卡")
                                .foregroundStyle(Color(hex: "#666666"))
                                .font(.system(size: 14))
                        }
                    }
                    .frame(width: 98)

                    // 热力图
                    HStack {
                        let columns = [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ]

                        if !self.heatmap.isEmpty {
                            LazyVGrid(columns: columns, spacing: 13) {
                                ForEach(self.heatmap, id: \.date) { item in
                                    let isHaveRoute: Bool = item.route_count != nil
                                        && item.route_count! > 0
                                        && item.background_color != nil

                                    Button {
                                        if isHaveRoute {
                                            self.routeDetailList = item.routes
                                        }
                                    } label: {
                                        if isHaveRoute {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color(hex: "\(item.background_color!)"))
                                                .frame(width: 26, height: 26)

                                        } else {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color(hex: "#eeeeee"))
                                                .frame(width: 26, height: 26)
                                        }
                                    }
                                }
                            }
                        } else {
                            Text("热力图加载中")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)

                // 步行记录详情
                if !self.routeDetailList.isEmpty {
                    VStack {
                        ForEach(Array(self.routeDetailList.enumerated()), id: \.element.create_at) { index, item in
                            HStack {
                                // 左侧标识和头像
                                if index == 0 {
                                    if let userInfo = self.userInfo {
                                        AsyncImage(url: URL(string: userInfo.avatar ?? defaultAvatar)) { image in
                                            image
                                                .resizable()
                                                .frame(width: 46, height: 46)
                                                .clipShape(Circle()) // 将图片裁剪为圆形
                                        } placeholder: {}
                                    }
                                } else {
                                    Circle()
                                        .fill(Color.white) // 设置圆形的背景颜色为白色
                                        .frame(width: 20, height: 20) // 设置圆形的大小
                                        .overlay(
                                            Circle()
                                                .stroke(Color(hex: "#F7B535"), lineWidth: 1)
                                                .overlay(content: {
                                                    Circle()
                                                        .fill(Color(hex: "#F7B535"))
                                                        .frame(width: 12, height: 12) // 设置圆形的大小
                                                })
                                        )
                                }

                                // 右侧详情内容
                                VStack {
                                    // 头部内容
                                    HStack {
                                        Text("\(item.city ?? "")")
                                    }

                                    // 发布的文案
                                    if item.content != nil {
                                        Text("\(item.content!)")
                                    }

                                    // 发布的图片
                                    if item.picture != nil && !item.picture!.isEmpty {
                                        ScrollView(.horizontal) {
                                            ForEach(item.picture!, id: \.self) { pictureItem in
                                                AsyncImage(url: URL(string: pictureItem)) { image in
                                                    image
                                                        .resizable()
                                                        .frame(width: 174, height: 175)
                                                        .cornerRadius(8)
                                                } placeholder: {}
                                            }
                                        }
                                        .scrollIndicators(.hidden)
                                    }
                                }
                            }
                        }
                    }
                }

                // 步行记录
                HStack {
                    if !self.routeList.isEmpty {
                        let columns = [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ]

                        LazyVGrid(columns: columns, alignment: .center) {
                            ForEach(self.routeList, id: \.list_id) { item in
                                NavigationLink(destination: RouteDetailView(list_id: item.list_id, user_id: self.user_id)) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: item.mood_color ?? "#FFCC94"))
                                        .frame(height: 116)
                                        .frame(maxWidth: .infinity)
                                        .overlay {
                                            HStack {
                                                Spacer()

                                                VStack {
                                                    // 地点数量
                                                    Text("地点×\(item.count)")
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 16))
                                                        .padding(.top, 28)
                                                        .padding(.trailing, 16)

                                                    Spacer()

                                                    // 时间
                                                    Text("\(convertToDateOnly(from: item.create_at)!)")
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 14))
                                                        .padding(.bottom, 10)
                                                        .padding(.trailing, 16)
                                                }
                                            }
                                        }
                                }
                            }
                        }
                    } else {
                        Text("步行记录加载中")
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            Task {
                await self.getUserInfo() // 获取用户信息
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

//            print("获取用户解锁的省份版图列表", res)

            if res.code == 200 && res.data != nil {
                self.provinceList = res.data!
            }
        } catch {
            print("获取用户解锁的省份版图列表异常")
        }
    }

    /// 获取用户信息
    private func getUserInfo() async {
        do {
            let res = try await Api.shared.getUserInfo(params: ["user_id": self.user_id])

//            print("我的页面获取的用户信息", res)

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

//            print("我的页面获取用户指定月份打卡热力图", res)

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
//        .environmentObject(GlobalData())
}
