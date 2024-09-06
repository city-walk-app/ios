//
//  Utils.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/14.
//

import Foundation

func convertToDateOnly(from dateString: String) -> String? {
    // 定义原始格式的 DateFormatter
    let inputDateFormatter = DateFormatter()
    inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    inputDateFormatter.locale = Locale(identifier: "en_US_POSIX")

    // 将字符串转为 Date 对象
    if let date = inputDateFormatter.date(from: dateString) {
        // 定义目标格式的 DateFormatter
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "yyyy-MM-dd"

        // 将 Date 对象转为目标格式的字符串
        return outputDateFormatter.string(from: date)
    } else {
        // 如果输入字符串格式不正确，返回 nil
        return nil
    }
}

/// 限制字符串的最大长度
/// - Parameters:
///   - content: 输入的字符串
///   - maxLength: 最大允许的字符数
func limitMaxLength(content: inout String, maxLength: Int) {
    if content.count > maxLength {
        content = String(content.prefix(maxLength))
    }
}

// 将日期字符串转换为 xx:xx 格式的时间
func convertToTime(from dateString: String) -> String? {
    // 定义原始格式的 DateFormatter
    let inputDateFormatter = DateFormatter()
    inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    inputDateFormatter.locale = Locale(identifier: "en_US_POSIX")

    // 将字符串转为 Date 对象
    if let date = inputDateFormatter.date(from: dateString) {
        // 定义目标格式的 DateFormatter
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "HH:mm"

        // 将 Date 对象转为目标格式的字符串
        return outputDateFormatter.string(from: date)
    } else {
        // 如果输入字符串格式不正确，返回 nil
        return nil
    }

//    // 创建一个日期格式化器，用于解析日期字符串
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 输入日期的格式
//
//    // 将日期字符串转换为 Date 对象
//    guard let date = dateFormatter.date(from: dateString) else {
//        return nil // 如果转换失败返回 nil
//    }
//
//    // 创建另一个日期格式化器，用于转换为 xx:xx 格式
//    let timeFormatter = DateFormatter()
//    timeFormatter.dateFormat = "HH:mm" // 输出时间的格式
//
//    // 返回转换后的时间字符串
//    return timeFormatter.string(from: date)
}
