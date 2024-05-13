//
//  MainView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

struct MainView: View {
    var userId: Int

    let API = ApiBasic()
    /// 缓存信息
    let cacheInfo = UserCache.shared.getInfo()!
    /// 用户信息数据
    @EnvironmentObject var userInfoDataModel: UserInfoData
    /// 全局数据
    @EnvironmentObject var globalDataModel: GlobalData
    /// 日历热力图
    @State var calendarHeatmap: [[UserGetCalendarHeatmap.UserGetCalendarHeatmapDataItem]] = []
    /// 省份版图列表
    @State var userProvince: [GetUserProvince.GetUserProvinceData] = []

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                // 头像
                HStack {
                    if userInfoDataModel.data != nil {
                        URLImage(url: URL(string: "\(BASE_URL)/\(userInfoDataModel.data!.avatar ?? "")")!)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .mask(Circle())

                    } else {
                        Image(systemName: "person")
                    }

                    Spacer()
                }

                // 昵称
                HStack {
                    Text("\(userInfoDataModel.data?.nick_name ?? "")")
                        .bold()

                    Spacer()
                }

                // 签名
                HStack {
                    Text(userInfoDataModel.data?.signature ?? "")

                    Spacer()
                }

                // 位置信息
                HStack {
                    Text(userInfoDataModel.data?.province ?? "")
                    Text("-")
                    Text(userInfoDataModel.data?.city ?? "")

                    Spacer()
                }

                // 省份版图列表
                if userProvince.count != 0 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(userProvince.indices, id: \.self) { index in
                                URLImage(url: URL(string: "\(BASE_URL)/images/province/\(userProvince[index].province_code).png")!)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .mask(Circle())
                            }
                        }
                    }
                    .padding(.top, 12)
                } else {
                    Text("版图信息加载中...")
                }

                // 热力图列表
                if calendarHeatmap.count != 0 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(calendarHeatmap.indices, id: \.self) { groupIndex in
                                VStack {
                                    ForEach(calendarHeatmap[groupIndex], id: \.self) { innerItem in
                                        Text(" ")
                                            .frame(width: 22, height: 22)
                                            .font(.system(size: 11))
                                            .background(
                                                innerItem.opacity == 0 ? .gray.opacity(0.07) : .green.opacity(innerItem.opacity),
                                                in: RoundedRectangle(cornerRadius: 3)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 12)
                } else {
                    Text("热力图加载中...")
                }

                // 用户的打卡记录
                if globalDataModel.routerData.count != 0 {
                    ForEach(globalDataModel.routerData.indices, id: \.self) { index in
                        NavigationLink(destination: MapView(listId: globalDataModel.routerData[index].id)) {
                            HStack {
                                Image(systemName: "figure.run.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(Color.green)

                                Text("打卡\(globalDataModel.routerData[index].route_detail)个位置")
                                Spacer()
                                Text("\(globalDataModel.routerData[index].city)")
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 22)
                            .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 22))
                        }
                    }
                } else {
                    Text("暂无打卡记录")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 80)
        }
        .onAppear {
            self.loadGetUserProvince() // 获取指定用户去过的省份
            self.loadUserGetCalendarHeatmap() // 获取用户的动态发布日历热力图
            self.getRouteList() // 获取指定用户的打卡记录
        }
    }

    /// 获取用户的动态发布日历热力图
    private func loadUserGetCalendarHeatmap() {
        API.userGetCalendarHeatmap(params: ["year": "2023"]) { result in
            switch result {
            case .success(let data):
                if data.code == 200 && (data.data?.isEmpty) != nil {
                    calendarHeatmap = data.data!
                }
            case .failure:
                print("接口错误")
            }
        }
    }

    /// 获取指定用户的打卡记录
    private func getRouteList() {
        API.getRouteList(params: ["page": "1", "page_size": "20"]) { result in
            switch result {
            case .success(let data):
                if data.code == 200 && ((data.data?.isEmpty) != nil) {
                    globalDataModel.setRouterData(data.data!)
                }
            case .failure:
                print("获取失败")
            }
        }
    }

    /// 获取指定用户去过的省份
    private func loadGetUserProvince() {
        API.getUserProvince(params: ["data": String(userId)]) { result in
            switch result {
            case .success(let data):
                if data.code == 200 && (data.data?.isEmpty) != nil {
                    userProvince = data.data!
                }
            case .failure:
                print("接口错误")
            }
        }
    }
}

#Preview {
    MainView(userId: 1)
        .environmentObject(UserInfoData())
        .environmentObject(GlobalData())
}
