//
//  HomeData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/23.
//

import Foundation
import MapKit
import SwiftUI

struct Landmark: Identifiable {
    let id = UUID()

    var coordinate: CLLocationCoordinate2D
    var picure: [String]?
    var name: String?
}

class HomeData: NSObject, ObservableObject {
    /// 地图区域
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30, longitude: 120),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    /// 标注列表
    @Published var landmarks: [Landmark]?

    init(region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30, longitude: 120),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    ), landmarks: [Landmark]? = nil) {
        self.region = region
        self.landmarks = landmarks
    }

    /// 获取今天的打卡记录
    func getTodayRecord() async {
        do {
            let res = try await Api.shared.getTodayRecord(params: [:])

            print("今日打卡记录", res)

            guard res.code == 200, let data = res.data else {
                landmarks = nil
                return
            }

            // SwiftUI 期望这些变化是在主线程上完成的
            DispatchQueue.main.async {
                withAnimation {
//                    self.region = MKCoordinateRegion(
//                        center: CLLocationCoordinate2D(latitude: Double(data[0].latitude) ?? 0, longitude: Double(data[0].longitude) ?? 0),
//                        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
//                    )
                    self.landmarks = data.map { item in
                        Landmark(
                            coordinate: CLLocationCoordinate2D(
                                latitude: Double(item.latitude) ?? 0,
                                longitude: Double(item.longitude) ?? 0
                            ),
                            picure: item.picture
                        )
                    }
                }
            }

        } catch {
            print("获取今日的打卡记录异常")
        }
    }
}
