//
//  HomePhotoView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/5/18.
//

import SwiftUI

/// 图片选择视图
struct HomePhotoView: View {
    /// 控制头像选择弹窗的显示状态
    @State private var isShowAvatarSelectSheet = false
    /// 用户选择的图片
    @Binding var seletImage: UIImage?
    /// 控制导航返回的状态
    @Binding var isActive: Bool

    var body: some View {
        ImagePicker(selectedImage: $seletImage, isImagePickerPresented: $isShowAvatarSelectSheet) {
            if let image = seletImage {
                self.seletImage = image
                self.isActive = false
            }
        }
    }
}
