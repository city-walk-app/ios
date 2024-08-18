//
//  ImagePickerView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/29.
//

import PhotosUI
import SwiftUI

//
//// 定义一个 UIViewControllerRepresentable 协议的结构体 ImagePicker，用于从相册中选择图片
// struct ImagePicker: UIViewControllerRepresentable {
//    // 用于存储从相册中选择的图片的绑定属性
//    @Binding var selectedImage: UIImage?
//    // 用于控制相册选择器的显示状态的绑定属性
//    @Binding var visible: Bool
//    // 用于在选择图片后执行的回调闭包
//    var onImagePicked: (() -> Void)?
//
//    // 创建并返回一个 PHPickerViewController 实例
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        // 创建一个 PHPickerConfiguration 实例，并配置为只允许选择图片
//        var configuration = PHPickerConfiguration()
//        configuration.filter = .images
//        // 创建 PHPickerViewController 实例，并使用配置的 PHPickerConfiguration
//        let picker = PHPickerViewController(configuration: configuration)
//        // 将 context.coordinator 设置为 PHPickerViewController 的委托对象
//        picker.delegate = context.coordinator
//        // 返回 PHPickerViewController 实例
//        return picker
//    }
//
//    // 更新 PHPickerViewController 的视图状态
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
//
//    // 创建并返回一个协调器对象
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(parent: self)
//    }
//
//    // 定义一个内部协调器类，实现 PHPickerViewControllerDelegate 协议
//    class Coordinator: NSObject, PHPickerViewControllerDelegate {
//        // 保存 ImagePicker 的引用
//        let parent: ImagePicker
//
//        // 初始化函数，将 ImagePicker 实例传递给协调器
//        init(parent: ImagePicker) {
//            self.parent = parent
//        }
//
//        // 处理从相册中选择的图片
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            // 判断是否选择了图片，并且图片可以加载
//            if let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) {
//                // 加载图片对象，并在加载完成后处理图片
//                provider.loadObject(ofClass: UIImage.self) { image, _ in
//                    // 将加载的图片赋值给 selectedImage
//                    if let image = image as? UIImage {
//                        // 使用 self 显式地指明引用父类属性
//                        self.parent.selectedImage = image
//                        // 在选择图片后执行回调闭包
//                        self.parent.onImagePicked?()
//                    }
//                }
//            }
//            // 关闭相册选择器
//            parent.visible = false
//        }
//    }
// }

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 2 // 允许选择最多2张照片
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            parent.selectedImages.removeAll()
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}
