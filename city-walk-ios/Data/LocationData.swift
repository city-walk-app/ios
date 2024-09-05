//
//  Location.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/8.
//

import CoreLocation
import Foundation

/// 定位服务
class LocationData: NSObject, ObservableObject, CLLocationManagerDelegate {
    /// 记录位置信息
    @Published var currentLocation: CLLocationCoordinate2D?

    /// 初始化CLLocationManager实例
    var locationManager = CLLocationManager()

    func checkLocationAuthorization() {
        // 设置代理
        locationManager.delegate = self

        // 获取用户授权状态
        let authorizationStatus = locationManager.authorizationStatus

        DispatchQueue.global().async { [weak self] in
            // 判断用户设备的系统位置权限是否开启，而非App的。该判断需要异步进行，否则会卡主线程。
            if CLLocationManager.locationServicesEnabled() {
                // 如果设备系统位置权限开启了，回主线程继续操作
                DispatchQueue.main.async {
                    if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
                        // 如果用户授权了，开启位置更新。
                        self?.locationManager.desiredAccuracy = kCLLocationAccuracyBest // 使用最高精度
                        self?.locationManager.startUpdatingLocation()

                        print("授权了位置，开始定位")
                    } else if authorizationStatus == .notDetermined {
                        // 如果用户未曾选择过，那么弹出授权框。
                        self?.locationManager.requestWhenInUseAuthorization()
                    } else {
                        // 用户拒绝了，停止位置更新。
                        self?.locationManager.stopUpdatingLocation()
                    }
                }
            } else {
                // 如果设备系统位置权限未开启，回主线程继续操作
                DispatchQueue.main.async {
                    if authorizationStatus == .notDetermined {
                        // 如果用户未曾选择过，那么弹出授权框。
                        self?.locationManager.requestWhenInUseAuthorization()
                    } else {
                        // 因系统位置权限未开启，停止位置更新。
                        self?.locationManager.stopUpdatingLocation()
                    }
                }
            }
        }
    }

    // 每当位置更新时都会被调用，这里更新currentLocation变量。
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = manager.location, !(newLocation.coordinate.longitude == 0.0 && newLocation.coordinate.latitude == 0.0) {
            currentLocation = newLocation.coordinate
        }
    }

    // 当位置管理器无法获取位置或发生错误时调用。
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        currentLocation = nil
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
    }

    // 当用户的位置权限状态发生变化时调用，例如用户从拒绝状态改为允许状态。用于根据当前的授权状态调整应用的行为，如在用户授权后开始位置更新。
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .denied {
            locationManager.stopUpdatingLocation()
        } else if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}
