//
//  HomeMapView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/18.
//

import MapKit
import SwiftUI

/// 地图视图，显示地图和标注
struct HomeMapView: UIViewRepresentable {
    /// 地图区域
    @Binding var region: MKCoordinateRegion
    /// 地图区域变化时的回调
    var onRegionChange: (() -> Void)?
    /// 标注列表
    @Binding var landmarks: [Landmark]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        let annotations = landmarks.map { landmark in
            let annotation = MKPointAnnotation()
            annotation.coordinate = landmark.coordinate
            annotation.title = landmark.name
            return annotation
        }
        uiView.addAnnotations(annotations)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: HomeMapView
        
        init(parent: HomeMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
            parent.onRegionChange?()
            print("地图区域变化：\(mapView.region.center.latitude), \(mapView.region.center.longitude)")
        }
    }
}
