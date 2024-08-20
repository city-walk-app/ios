//
//  ImagePickerView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/29.
//

import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    /// 选择的图片文件列表
    @Binding var selectedImages: [UIImage]
    /// 做多选择的文件数量
    var maxCount: Int
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = maxCount // 允许选择最多的照片数量
        
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
            
//            parent.selectedImages.removeAll()
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(image)
                                
                                print("选择的图片列表", self.parent.selectedImages)
                            }
                        }
                    }
                }
            }
        }
    }
}
