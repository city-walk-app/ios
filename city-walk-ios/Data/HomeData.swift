//
//  HomeData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/23.
//

import Foundation
import MapKit
import SwiftUI

let defaultDelta = 0.3
let uploadDelta = 0.04

/// 首页数据
class HomeData: NSObject, ObservableObject {
    /// 地图区域
    @Published var region: MKCoordinateRegion
    /// 标注列表
    @Published var landmarks: [LandmarkItem] = []
    /// 用户所在位置
    @Published var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    init(
        region: MKCoordinateRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 30, longitude: 120),
            span: MKCoordinateSpan(latitudeDelta: defaultDelta, longitudeDelta: defaultDelta)
        )
    ) {
        self.region = region
    }

    /// 获取今天的打卡记录
    func getTodayRecord() async {
        do {
            let res = try await Api.shared.getTodayRecord(params: [:])

            print("今日打卡记录", res)

            guard res.code == 200, let data = res.data else {
                return
            }

            // 如果数组为空
            if data.isEmpty {
                DispatchQueue.main.async {
                    self.landmarks = []
                }
                return
            }

            // SwiftUI 期望这些变化是在主线程上完成的
            DispatchQueue.main.async {
                withAnimation {
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

                    self.landmarks = records

                    print("打卡地点列表", self.landmarks)
                }
            }

        } catch {
            print("获取今日的打卡记录异常")
        }
    }
}
