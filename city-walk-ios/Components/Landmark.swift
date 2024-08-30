//
//  Landmark.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/30.
//

import Kingfisher
import MapKit
import SwiftUI

struct LandmarkItem: Identifiable {
    let id = UUID()

    var coordinate: CLLocationCoordinate2D
    var picure: [String]?
    var name: String?
}

/// 地图标点
struct Landmark: View {
    /// 地图标点
    var landmark: LandmarkItem

    var body: some View {
        VStack(spacing: 3) {
            KFImage(homeMarkers)
                .placeholder {
                    Color.clear
                        .frame(width: 50, height: 64)
                }
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 64)

            if let picture = landmark.picure, !picture.isEmpty {
                ForEach(picture, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("background-1"))
                        .frame(width: 90, height: 90)
                        .overlay {
                            KFImage(URL(string: item))
                                .resizable()
                                .frame(width: 82, height: 82)
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .clipped()
                        }
                        .shadow(radius: 5)
                }
            }
        }
    }
}
