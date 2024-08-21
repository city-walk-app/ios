//
//  EmptyState.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/21.
//

import SwiftUI

struct EmptyState: View {
    var title: String = "暂无数据"

    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/empty.png")) { image in
                image
                    .resizable()
                    .frame(width: 199, height: 187)
            } placeholder: {
                Color.clear
                    .frame(width: 199, height: 187)
            }

            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: "#9A9A9A"))
        }
    }
}

#Preview {
    EmptyState()
}
