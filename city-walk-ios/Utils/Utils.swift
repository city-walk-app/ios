//
//  Utils.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/14.
//

//import Foundation
//
//func convertToDateOnly(from dateString: String) -> String? {
//    // 定义原始格式的 DateFormatter
//    let inputDateFormatter = DateFormatter()
//    inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//    inputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
//
//    // 将字符串转为 Date 对象
//    if let date = inputDateFormatter.date(from: dateString) {
//        // 定义目标格式的 DateFormatter
//        let outputDateFormatter = DateFormatter()
//        outputDateFormatter.dateFormat = "yyyy-MM-dd"
//
//        // 将 Date 对象转为目标格式的字符串
//        return outputDateFormatter.string(from: date)
//    } else {
//        // 如果输入字符串格式不正确，返回 nil
//        return nil
//    }
//}
