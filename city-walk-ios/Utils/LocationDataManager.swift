//
//  Location.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/8.
//

import CoreLocation
import Foundation

/// 定位服务
class LocationDataManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        // 提供定位服务。
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
            locationManager.requestLocation()
            
        // 定位服务当前不可用。
        case .restricted:
            authorizationStatus = .restricted
            
        // 定位服务当前不可用。
        case .denied:
            authorizationStatus = .denied
            
        // 授权尚未确定。
        case .notDetermined:
            authorizationStatus = .notDetermined
            manager.requestWhenInUseAuthorization()
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 插入代码以处理位置更新
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("获取位置信息错误: \(error.localizedDescription)")
    }
}
