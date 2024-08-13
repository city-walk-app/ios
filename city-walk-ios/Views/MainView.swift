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
    /// 缓存信息
//    let cacheInfo = UserCache.shared.getInfo()!
    /// 非自己，其它用户的身份信息
    @State private var userInfo: UserInfoType?
    /// 用户信息数据
    @EnvironmentObject var userInfoDataModel: UserInfoData
    /// 全局数据
    @EnvironmentObject var globalDataModel: GlobalData
    /// 日历热力图
    @State var calendarHeatmap: [[UserGetCalendarHeatmap.UserGetCalendarHeatmapDataItem]] = []
    /// 省份版图列表
    @State var userProvince: [GetUserProvince.GetUserProvinceData] = []

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                // 身份信息，如果有其它人的信息，显示其它的，否则显示自己的信息
//                if let info =
//                    self.user_id == userInfoDataModel.data!.user_id
//                        ? self.userInfoDataModel.data
//                        : self.otherUserInfo
//                {
                // 头像
//                HStack(alignment: .center) {
//                    if self.userInfo.avatar != nil {
//                        URLImage(url: URL(string: "\(BASE_URL)/\(info.avatar!)")!)
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 140, height: 140)
//                            .mask(Circle())
//
//                    } else {
//                        Image(systemName: "person")
//                    }
//                }

                // 昵称
                Text("\(self.userInfo?.nick_name ?? "")")
                    .font(.title)

                // 签名
                Text(self.userInfo?.signature ?? "")
                    .padding(.top, 4)

                // 位置信息
//                HStack {
//                    Text(userInfo.province ?? "")
//                    Text("-")
//                    Text(userInfo.city ?? "")
//                }
//                .foregroundStyle(.gray)
//                }

//                // 省份版图列表
//                if userProvince.count != 0 {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack {
//                            ForEach(userProvince.indices, id: \.self) { index in
//                                URLImage(url: URL(string: "\(BASE_URL)/images/province/\(userProvince[index].province_code).png")!)
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 100, height: 100)
//                                    .mask(Circle())
//                            }
//                        }
//                    }
//                    .padding(.top, 12)
//                } else {
//                    Text("版图信息加载中...")
//                }

//                // 热力图列表
//                if calendarHeatmap.count != 0 {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(alignment: .top) {
//                            ForEach(calendarHeatmap.indices, id: \.self) { groupIndex in
//                                VStack {
//                                    ForEach(calendarHeatmap[groupIndex], id: \.self) { innerItem in
//                                        Text(" ")
//                                            .frame(width: 22, height: 22)
//                                            .font(.system(size: 11))
//                                            .background(
//                                                innerItem.opacity == 0 ? .gray.opacity(0.07) : .green.opacity(innerItem.opacity),
//                                                in: RoundedRectangle(cornerRadius: 3)
//                                            )
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .padding(.top, 12)
//                } else {
//                    Text("热力图加载中...")
//                }

                // 用户的打卡记录
//                if let routerList = globalDataModel.routerData {
//                    ForEach(routerList.indices, id: \.self) { index in
//                        NavigationLink(destination: RouterDetailView(listId: routerList[index].id)) {
//                            HStack {
//                                Image(systemName: "figure.run.circle.fill")
//                                    .font(.system(size: 30))
//                                    .foregroundStyle(Color.green)
//
//                                Text("打卡\(routerList[index].route_detail)个位置")
//                                Spacer()
//                                Text("\(routerList[index].city)")
//                            }
//                            .padding(.vertical, 20)
//                            .padding(.horizontal, 22)
//                            .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 22))
//                        }
//                    }
//                } else {
//                    Text("暂无打卡记录")
//                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .onAppear {
            Task {
                await self.loadUserInfo() // 获取用户信息
//                await self.getLocationUserHeatmap() // 获取用户指定月份打卡热力图
                await self.getUserProvinceJigsaw() // 获取用户解锁的省份版图列表
            }
        }
    }

    /// 获取用户解锁的省份版图列表
    private func getUserProvinceJigsaw() async {
        do {
            let res = try await Api.shared.getUserProvinceJigsaw(params: ["user_id": self.user_id])

            print("获取用户解锁的省份版图列表", res)

            if res.code == 200 && res.data != nil {}
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
                self.userInfo = res.data
            }
        } catch {
            print("获取用户信息异常")
        }
    }

    /// 获取用户指定月份打卡热力图
    private func getLocationUserHeatmap() async {
        do {
            let res = try await API.getLocationUserHeatmap(params: ["user_id": self.user_id])

            print("我的页面获取用户指定月份打卡热力图", res)

            if res.code == 200 && res.data != nil {}

        } catch {
            print("取用户指定月份打卡热力图异常")
        }
    }

//    private func loadUserInfo() async {
//        do {
//            let params: [String: Any] = ["user_id": "U131995175454824711531011225172573302849"] // 根据您的实际参数
//            let res = try await Api.shared.getUserInfo(params: params)
//
//            print("获取的用户信息", res)
//
//            if res.code == 200 {
//                otherUserInfo = res.data!
//            }
//            //            userInfo = info
//        } catch {
//            print("获取用户信息异常")
//        }
//    }

//        try await API.emailSend(params: ["user_id": "1121"])
//        API.userInfo(params: ["id": "\(userId)"]) { result in
//            switch result {
//            case .success(let data):
//                if data.code == 200 && data.data != nil {
//                    self.otherUserInfo = data.data!
//                }
//            case .failure:
//                print("接口错误")
//            }
//        }
//    }

//    /// 获取指定用户的打卡记录
//    private func getRouteList() {
//        API.getRouteList(params: ["page": "1", "page_size": "20"]) { result in
//            switch result {
//            case .success(let data):
//                if data.code == 200 && ((data.data?.isEmpty) != nil) {
//                    globalDataModel.setRouterData(data.data!)
//                }
//            case .failure:
//                print("获取失败")
//            }
//        }
//    }
//
//    /// 获取指定用户去过的省份
//    private func loadGetUserProvince() {
//        API.getUserProvince(params: ["data": String(userId)]) { result in
//            switch result {
//            case .success(let data):
//                if data.code == 200 && (data.data?.isEmpty) != nil {
//                    userProvince = data.data!
//                }
//            case .failure:
//                print("接口错误")
//            }
//        }
//    }
}

#Preview {
    MainView(user_id: "U131995175454824711531011225172573302849")
        .environmentObject(UserInfoData())
        .environmentObject(GlobalData())
}
