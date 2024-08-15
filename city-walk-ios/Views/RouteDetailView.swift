//
//  MapView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/4.
//

import MapKit
import SwiftUI

struct RouteDetailView: View {
    var list_id: String
    var user_id: String

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
            }
        }
        .ignoresSafeArea(.all) // 忽略安全区域边缘
        .onAppear {
            Task {
                await self.getUserRouteDetail() // 获取用户步行记录详情
            }
        }
    }

    /// 获取用户步行记录详情
    private func getUserRouteDetail() async {
        do {
            let res = try await Api.shared.getUserRouteDetail(params: ["list_id": list_id, "user_id": user_id])

            print("获取指定步行记录历史打卡记录列表", res)

            if res.code == 200 && res.data != nil {}
        } catch {
            print("错误")
        }

//        print("请求参数", ["id": "\(listId)"])
//        API.gpsGetRouteHistory(params: ["id": "\(listId)"]) { result in
//            switch result {
//            case .success(let data):
//                if data.code == 200 && (data.data?.isEmpty) != nil {
//                    let list = data.data!
//
//                    let _landmarks = list.map { item in
//                        Landmark(coordinate: CLLocationCoordinate2D(latitude: Double(item.latitude) ?? 0, longitude: Double(item.longitude) ?? 0), name: item.address)
//                    }
//
//                    print("第一项", list[0])
//
//                    let firstItem = list[0]
//
//                    self.region = MKCoordinateRegion(
//                        center: CLLocationCoordinate2D(latitude: Double(firstItem.latitude) ?? 0, longitude: Double(firstItem.longitude) ?? 0),
//                        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
//                    )
//
//                    print("地图配置参数", region)
//
//                    self.landmarks = _landmarks
//                    self.routeDetail = list
//                }
//            case .failure:
//                print("获取步行打卡记录列表失败")
//            }
//        }
    }
}

struct Landmark: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var name: String
}

#Preview {
    RouteDetailView(
        list_id: "RL121414535105088630027513314120190363780",
        user_id: "U131995175454824711531011225172573302849"
    )
}