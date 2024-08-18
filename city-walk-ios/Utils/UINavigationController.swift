//
//  UINavigationController.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/17.
//

import SwiftUI

/// https://swiftflamel.com/2023/02/17/swiftui%E4%B8%AD%E5%A6%82%E4%BD%95%E8%87%AA%E5%AE%9A%E4%B9%89navigation%E8%BF%94%E5%9B%9E%E6%8C%89%E9%92%AE/

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }

    // To make it works also with ScrollView
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
