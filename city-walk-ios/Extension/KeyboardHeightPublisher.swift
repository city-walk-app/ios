//
//  Publishers.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/18.
//

import Combine
import UIKit

// https://www.vadimbulavin.com/how-to-move-swiftui-view-when-keyboard-covers-text-field/

extension Notification {
    var keyboardHeight: CGFloat {
        (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }

        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}
