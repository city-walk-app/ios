//
//  city_walk_iosApp.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

@main
struct city_walk_iosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LaunchScreenData())
                .environmentObject(UserInfoData())
                .environmentObject(GlobalData())
        }
    }
}
