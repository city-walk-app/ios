//
//  RouteDetailView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/4.
//

import Kingfisher
import MapKit
import SwiftUI

/// 步行记录详情
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
    @State private var landmarks: [LandmarkItem] = []
    /// 步行记录详情
    @State private var routeDetail: [GpsGetRouteHistory.GpsGetRouteHistoryData] = []
    /// 是否显示预览的图片
    @State private var isPreviewing = false
    /// 预览的图片列表
    @State private var previewImages: [String] = []
    /// 预览的图片索引
    @State private var previewSelectedIndex = 0

    var body: some View {
        ZStack {
            // 地图
            Map(coordinateRegion: $region, annotationItems: landmarks) { landmark in
                MapAnnotation(coordinate: landmark.coordinate) {
                    Landmark(landmark: landmark, pictureClick: pictureClick)
                }
            }

            // 预览图片
            if isPreviewing {
                ImagePreviewView(images: previewImages, selectedIndex: $previewSelectedIndex, isPresented: $isPreviewing)
            }
        }
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton {
            self.presentationMode.wrappedValue.dismiss()
        }) // 自定义返回按钮
        .onAppear {
            Task {
                await self.getUserRouteDetail() // 获取用户步行记录详情
            }
        }
    }

    /// 照片点击的回调
    private func pictureClick(picture: [String]) {
        previewImages = picture

        withAnimation {
            self.isPreviewing.toggle()
        }
    }

    /// 获取用户步行记录详情
    private func getUserRouteDetail() async {
        do {
            let res = try await Api.shared.getUserRouteDetail(params: ["list_id": list_id, "user_id": user_id])

            print("结果", res)

            guard res.code == 200, let data = res.data else {
                return
            }

            withAnimation {
                self.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: Double(data[0].latitude) ?? 0, longitude: Double(data[0].longitude) ?? 0),
                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                )
                self.landmarks = data.map { item in
                    LandmarkItem(
                        coordinate: CLLocationCoordinate2D(
                            latitude: Double(item.latitude) ?? 0,
                            longitude: Double(item.longitude) ?? 0
                        ),
                        picure: item.picture
                    )
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
