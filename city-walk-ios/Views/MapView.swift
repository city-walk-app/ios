//
//  MapView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/4.
//

import MapKit
import SwiftUI

struct MapView: View {
    let API = ApiBasic()

    /// 查询的步行列表 id
    var listId: Int

    /// 地图配置
    @State private var region: MKCoordinateRegion = .init(
        // 地图的中心坐标
        center: CLLocationCoordinate2D(latitude: 30, longitude: 120),
        // 地图显示区域的范围
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    // 标注列表
    @State private var landmarks: [Landmark] = []
    /// 步行记录详情
    @State private var routeDetail: [GpsGetRouteHistory.GpsGetRouteHistoryData] = []

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // 地图

                Map(coordinateRegion: $region, annotationItems: landmarks) { landmark in
                    // 为每个地标创建标注视图
                    MapAnnotation(coordinate: landmark.coordinate) {
                        VStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
//                            Text(landmark.name)
                            Text("地点")
                                .font(.system(size: 20))
                        }
                    }
                }

                // 底部内容
//                VStack {
//                    ScrollView(showsIndicators: false) {
//                        ForEach(routeDetail.indices, id: \.self) { index in
//                            HStack {
//                                Image(systemName: "paperplane.circle")
//                                Text("\(routeDetail[index].name)")
//                                    .frame(width: 100)
//                                    .lineLimit(1)
//                                    .truncationMode(.tail)
//
//                                Spacer()
//
//                                Text("\(routeDetail[index].create_at)")
//                                    .frame(width: 110)
//                                    .lineLimit(1)
//                                    .truncationMode(.tail)
//                            }
//                            .padding()
//                        }
//                    }
//                    .padding(.vertical)
//                    .frame(height: 200)
//                }
//                .background(.white, in: RoundedRectangle(cornerRadius: 20))
//                .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: -5)
//                .padding()
            }
        }
//        .navigationBarHidden(true) // 隐藏导航栏
        .ignoresSafeArea(.all) // 忽略安全区域边缘
        .onAppear {
            self.gpsGetRouteHistory() // 获取指定步行记录历史打卡记录列表
        }
    }

    /// 获取指定步行记录历史打卡记录列表
    private func gpsGetRouteHistory() {
        print("请求参数", ["id": "\(listId)"])
        API.gpsGetRouteHistory(params: ["id": "\(listId)"]) { result in
            switch result {
            case .success(let data):
                if data.code == 200 && (data.data?.isEmpty) != nil {
                    let list = data.data!

                    let _landmarks = list.map { item in
                        Landmark(coordinate: CLLocationCoordinate2D(latitude: Double(item.latitude) ?? 0, longitude: Double(item.longitude) ?? 0), name: item.address)
                    }

                    print("第一项", list[0])

                    let firstItem = list[0]

                    region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: Double(firstItem.latitude) ?? 0, longitude: Double(firstItem.longitude) ?? 0),
                        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                    )

                    print("地图配置参数", region)

                    landmarks = _landmarks
                    routeDetail = list
                }
            case .failure:
                print("获取步行打卡记录列表失败")
            }
        }
    }
}

struct Landmark: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var name: String
}

#Preview {
    MapView(listId: 29)
}
