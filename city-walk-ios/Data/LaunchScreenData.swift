//
//  LaunchScreenData.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/9.
//

import Foundation
import SwiftUI

enum LaunchScreenStates {
    case enter
    case leave
}

class LaunchScreenData: ObservableObject {
    /// 当前状态
    @Published private(set) var states: LaunchScreenStates = .enter

    /// 切换当前状态
    func change() {
        withAnimation {
            self.states = .leave
        }
    }
}
