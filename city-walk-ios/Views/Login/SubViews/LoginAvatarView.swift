//
//  LoginAvatarView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/6/11.
//

import SwiftUI

struct LoginAvatarView: View {
    @Binding var selectAvatarImage: UIImage?
    @Binding var isShowAvatarSelectSheet: Bool

    var uploadImageToBackend: (UIImage) -> Void

    var body: some View {
        // 点击选择头像
        Button {
            self.isShowAvatarSelectSheet.toggle()
        } label: {
            VStack {
                if let image = selectAvatarImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.gray.opacity(0.3))
                        .overlay {
                            Image(systemName: "person")
                                .foregroundStyle(.white)
                                .font(.system(size: 44))
                        }
                }

                HStack {
                    Spacer()
                    Text("设置你的头像")
                    Spacer()
                }
            }
        }
        // 选择头像的弹出层
        .sheet(isPresented: $isShowAvatarSelectSheet) {
            ImagePicker(selectedImage: $selectAvatarImage, isImagePickerPresented: $isShowAvatarSelectSheet) {
                if let image = selectAvatarImage {
                    self.uploadImageToBackend(image)
                }
            }

            Button {} label: {
                HStack {
                    Spacer()
                    Text("确定")
                    Spacer()
                }
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
            }
            .padding(.top, 50)
        }
    }
}
