//
//  Demo.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/9/10.
//

import SwiftUI

struct RadiatingTrianglesView: View {
    let numberOfTriangles: Int = 40 // 三角形数量
    let lineWidthRatio: CGFloat = 0.05 // 底部线条占总半径的比例
    @State private var rotationAngle: Double = 0.0

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let center = CGPoint(x: width / 2, y: height / 2)
            let radius = min(width, height) / 2

            ZStack {
                ForEach(0 ..< numberOfTriangles, id: \.self) { index in
                    let angle = Angle.degrees(Double(index) / Double(numberOfTriangles) * 360)
                    let nextAngle = Angle.degrees(Double(index + 1) / Double(numberOfTriangles) * 360)

                    let startX = center.x + cos(angle.radians) * (radius * lineWidthRatio)
                    let startY = center.y + sin(angle.radians) * (radius * lineWidthRatio)

                    let endX1 = center.x + cos(angle.radians) * radius
                    let endY1 = center.y + sin(angle.radians) * radius

                    let endX2 = center.x + cos(nextAngle.radians) * radius
                    let endY2 = center.y + sin(nextAngle.radians) * radius

                    Path { path in
                        path.move(to: center) // 中心点
                        path.addLine(to: CGPoint(x: endX1, y: endY1)) // 第一条线到三角形外边
                        path.addLine(to: CGPoint(x: endX2, y: endY2)) // 第二条线到三角形外边
                        path.addLine(to: CGPoint(x: startX, y: startY)) // 回到底部更窄的部分
                        path.closeSubpath()
                    }
                    .fill(index % 2 == 0 ? Color.orange.opacity(0.6) : Color.white) // 交替颜色
                }
            }
            .frame(width: width, height: height)
        }
        .rotationEffect(.degrees(rotationAngle))
        .onAppear {
            withAnimation(Animation.linear(duration: 5.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360.0 // 完成360度旋转
            }
        }
    }
}

#Preview {
    RadiatingTrianglesView()
}
