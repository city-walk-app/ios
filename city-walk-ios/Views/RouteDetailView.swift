//
//  RouteDetailView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/4.
//

import MapKit
import SwiftUI

struct Landmark: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var name: String
}

struct RouteDetailView: View {
    /// 列表 id
    var list_id: String
    /// 用户 id
    var user_id: String

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

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
        NavigationView {
            // 地图
            Map(coordinateRegion: self.$region, annotationItems: self.landmarks) { landmark in
                MapAnnotation(coordinate: landmark.coordinate) {
                    VStack {
                        AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/home-markers.png")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 64)
                        } placeholder: {}

                        Text("地点")
                            .font(.system(size: 20))
                    }
                }
            }
            .ignoresSafeArea(.all) // 忽略安全区域边缘
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .navigationBarItems(leading: BackButton {
            self.presentationMode.wrappedValue.dismiss() // 返回上一个视图
        }) // 自定义返回按钮
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

            guard res.code == 200, let data = res.data else {
                return
            }

            withAnimation {
                self.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: Double(data[0].latitude) ?? 0, longitude: Double(data[0].longitude) ?? 0),
                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                )
                self.landmarks = data.map { item in
                    Landmark(coordinate: CLLocationCoordinate2D(latitude: Double(item.latitude) ?? 0, longitude: Double(item.longitude) ?? 0), name: item.address ?? "")
                }
            }
        } catch {
            print("获取用户步行记录详情异常", error)
        }
    }
}

#Preview {
    RouteDetailView(
        list_id: "RL121414535105088630027513314120190363780",
        user_id: "U131995175454824711531011225172573302849"
    )
}
