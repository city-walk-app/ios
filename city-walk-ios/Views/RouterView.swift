//
//  RouterView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

struct RouterView: View {
    let API = ApiBasic()

    /// tab 切换数据
    @EnvironmentObject var tabbarDataModel: TabbarData

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(tabbarDataModel.routerData.indices, id: \.self) { index in
                        NavigationLink(destination: MapView(listId: tabbarDataModel.routerData[index].id)) {
                            HStack {
                                Image(systemName: "figure.run.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(Color.green)

                                Text("打卡\(tabbarDataModel.routerData[index].route_detail)个位置")
                                Spacer()
                                Text("\(tabbarDataModel.routerData[index].city)")
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 22)
                            .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 22))
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 200)
            }
        }
        .navigationTitle("打卡记录")
        .onAppear {
            self.getRouteList() // 获取指定用户去过的省份
        }
    }

    /// 获取指定用户去过的省份
    private func getRouteList() {
        API.getRouteList(params: ["page": "1", "page_size": "20"]) { result in
            switch result {
            case .success(let data):
                if data.code == 200 && ((data.data?.isEmpty) != nil) {
                    tabbarDataModel.setRouterData(data.data!)
                }
            case .failure:
                print("获取失败")
            }
        }
    }
}

#Preview {
    RouterView()
        .environmentObject(TabbarData())
}
