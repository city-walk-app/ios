//
//  UploadImages.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/8/19.
//

import Foundation
import PhotosUI

/// 上传图片
/// - Parameter image: 图片文件
/// - Returns: 图片上传成功的完整地址
func uploadSingleImage(image: UIImage) async -> String? {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        
    do {
        let res = try await Api.shared.universalContentUpload(params: ["suffix": ".jpg"])
            
        guard res.code == 200,
              let data = res.data
        else {
            print("无法获取上传凭据")
            return nil
        }
            
        let url = URL(string: data.host)!
        let boundary = UUID().uuidString
            
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
        let body = createMultipartBody(with: imageData, fileName: data.key, credentials: data, boundary: boundary)
      
        do {
            let response = try await URLSession.shared.upload(for: request, from: body)
       
            let uploadedURL = "\(data.host)/\(data.key)"
            
            return uploadedURL
        } catch {
            print("上传错误: \(error.localizedDescription)")
            return nil
        }
    } catch {
        print("上传异常: \(error)")
        return nil
    }
}

/// 构建 multipart/form-data 请求体
/// - Parameters:
///   - imageData: 图像的二进制数据。这个数据通常是通过 `UIImage` 转换成 JPEG 格式的二进制数据。
///   - fileName: 上传文件的名称，通常是服务器返回的 `key` 字段值。
///   - credentials: 服务器返回的上传凭据数据，包括 `key`、`policy`、`OSSAccessKeyId`、`signature` 等。
///   - boundary: 每个部分之间的分隔符字符串，用于标记不同数据段的开始和结束。
/// - Returns: 构建好的 `multipart/form-data` 请求体的 `Data` 对象。
func createMultipartBody(
    with imageData: Data,
    fileName: String,
    credentials: UniversalContentUploadType.UniversalContentUploadData,
    boundary: String
) -> Data {
    var body = Data()
    let boundaryPrefix = "--\(boundary)\r\n"
    
    body.append(Data(boundaryPrefix.utf8))
    body.append(Data("Content-Disposition: form-data; name=\"key\"\r\n\r\n".utf8))
    body.append(Data("\(credentials.key)\r\n".utf8))
    
    body.append(Data(boundaryPrefix.utf8))
    body.append(Data("Content-Disposition: form-data; name=\"policy\"\r\n\r\n".utf8))
    body.append(Data("\(credentials.policy)\r\n".utf8))
    
    body.append(Data(boundaryPrefix.utf8))
    body.append(Data("Content-Disposition: form-data; name=\"OSSAccessKeyId\"\r\n\r\n".utf8))
    body.append(Data("\(credentials.OSSAccessKeyId)\r\n".utf8))
    
    body.append(Data(boundaryPrefix.utf8))
    body.append(Data("Content-Disposition: form-data; name=\"signature\"\r\n\r\n".utf8))
    body.append(Data("\(credentials.signature)\r\n".utf8))
    
    body.append(Data(boundaryPrefix.utf8))
    body.append(Data("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".utf8))
    body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
    body.append(imageData)
    body.append(Data("\r\n".utf8))
    
    body.append(Data("--\(boundary)--\r\n".utf8))
    
    return body
}

/// 上传图片文件
/// - Parameter images: 图片文件列表
/// - Returns: 图片文件完整地址列表
func uploadImages(images: [UIImage]) async -> [String] {
    if images.isEmpty {
        return []
    }
      
    var uploadedURLs: [String] = []

    await withTaskGroup(of: String?.self) { taskGroup in
        for image in images {
            taskGroup.addTask {
                await uploadSingleImage(image: image)
            }
        }
          
        for await url in taskGroup {
            if let url = url {
                uploadedURLs.append(url)
            }
        }
    }
      
    return uploadedURLs
}
