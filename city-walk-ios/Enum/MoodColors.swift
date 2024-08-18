//
//  MoodColors.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/18.
//

import Foundation

/// 颜色选择
struct MoodColor {
    var color: String
    var borderColor: String
    var key: String
    var type: String
}

let moodColors: [MoodColor] = [
    MoodColor(color: "#f16a59", borderColor: "#ef442f", key: "EXCITED", type: "兴奋的"),
    MoodColor(color: "#f6a552", borderColor: "#f39026", key: "ENTHUSIASTIC", type: "热情的"),
    MoodColor(color: "#fad35c", borderColor: "#fac736", key: "HAPPY", type: "快乐的"),
    MoodColor(color: "#74cd6d", borderColor: "#50c348", key: "RELAXED", type: "放松的"),
    MoodColor(color: "#4a8cf9", borderColor: "#1d6ff8", key: "CALM", type: "平静的"),
    MoodColor(color: "#af72dc", borderColor: "#9b4fd3", key: "MYSTERIOUS", type: "神秘的"),
    MoodColor(color: "#9b9ca0", borderColor: "#838387", key: "NEUTRAL", type: "中性的"),
]
