//
//  HomeData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/23.
//

import Foundation
import MapKit
import SwiftUI

/// 首页数据
class HomeData: NSObject, ObservableObject {
    /// 地图区域
    @Published var region: MKCoordinateRegion
    /// 标注列表
    @Published var landmarks: [LandmarkItem] = []

    @Published var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    init(
        region: MKCoordinateRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 30, longitude: 120),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
//        landmarks: [Landmark]? = nil
    ) {
        self.region = region
//        self.landmarks = landmarks
    }

    /// 获取今天的打卡记录
    func getTodayRecord() async {
        do {
            let res = try await Api.shared.getTodayRecord(params: [:])

            print("今日打卡记录", res)

//            let user = Landmark(
//                coordinate: CLLocationCoordinate2D(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude),
//                type: .user
//            )
//
//            self.landmarks.append(user)

            guard res.code == 200, let data = res.data else {
                return
            }

            // SwiftUI 期望这些变化是在主线程上完成的
            DispatchQueue.main.async {
                withAnimation {
//                    self.region = MKCoordinateRegion(
//                        center: CLLocationCoordinate2D(latitude: Double(data[0].latitude) ?? 0, longitude: Double(data[0].longitude) ?? 0),
//                        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
//                    )
//                    self.landmarks

                    // 打卡记录
                    let records = data.map { item in
                        LandmarkItem(
                            coordinate: CLLocationCoordinate2D(
                                latitude: Double(item.latitude) ?? 0,
                                longitude: Double(item.longitude) ?? 0
                            ),
                            picure: item.picture
                        )
                    }

                    self.landmarks.append(contentsOf: records)

                    print("打卡地点列表", self.landmarks)
                }
            }

        } catch {
            print("获取今日的打卡记录异常")
        }
    }
}
