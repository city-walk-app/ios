//
//  RankingView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

struct RankingView: View {
    let API = ApiBasic()

    /// tab 切换数据
    @EnvironmentObject var globalDataModel: GlobalData

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(globalDataModel.rankingData.indices, id: \.self) { index in

                        HStack {
                            NavigationLink(destination: MainView(userId: globalDataModel.rankingData[index].user_id)) {
                                URLImage(url: URL(string: "\(BASE_URL)/\(globalDataModel.rankingData[index].user_info.avatar ?? "")")!)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 70, height: 70)
                                    .mask(Circle())
                            }

                            VStack(alignment: .leading) {
                                Text("\(globalDataModel.rankingData[index].user_info.nick_name ?? "")")
                                    .font(.title2)

                                HStack {
                                    Image(systemName: "star")
                                    Text("500")
                                }
                                .padding(.top, 4)
                            }
                            .padding(.leading, 8)

                            Spacer()
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 22)
                        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 22))
                    }
                }
                .padding(20)
                .padding(.bottom, 200)
            }
            .navigationTitle("经验排名")
            .onAppear {
                self.experienceRanking() // 获取经验排行榜
            }
        }
    }

    /// 获取经验排行榜
    private func experienceRanking() {
        API.experienceRanking(params: ["province_code": "330000"]) { result in
            switch result {
            case .success(let data):
                if data.code == 200 && (data.data?.isEmpty) != nil {
                    self.globalDataModel.setRankingData(data.data!)
                }
            case .failure:
                print("获取失败")
            }
        }
    }
}

#Preview {
    RankingView()
        .environmentObject(GlobalData())
}
