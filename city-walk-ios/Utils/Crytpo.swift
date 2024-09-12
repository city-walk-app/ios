//
//  Crytpo.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/9/12.
//

import CommonCrypto
import Foundation

let crytpoKey = "da12dahajk82skdasjd1827189hdajbd19hdjabd"

// MARK: - 加密方法

func encrypt(string: String, usingKey key: String) throws -> String {
    let data = Data(string.utf8) // 转换为 Data 格式
    let keyData = Data(key.utf8) // 密钥转换为 Data 格式
    
    // 填充密钥到 256 位（32 字节）
    let keyLength = kCCKeySizeAES256
    var keyBytes = [UInt8](repeating: 0, count: keyLength)
    keyData.copyBytes(to: &keyBytes, count: min(keyData.count, keyLength))
    
    // AES 加密
    let bufferSize = data.count + kCCBlockSizeAES128
    var encryptedData = Data(count: bufferSize)
    var numBytesEncrypted = 0
    
    let cryptStatus = encryptedData.withUnsafeMutableBytes { encryptedBytes in
        data.withUnsafeBytes { dataBytes in
            CCCrypt(
                CCOperation(kCCEncrypt),
                CCAlgorithm(kCCAlgorithmAES128),
                CCOptions(kCCOptionPKCS7Padding),
                keyBytes,
                keyLength,
                nil, // 如果需要使用 IV，可以传入 IV
                dataBytes.baseAddress,
                data.count,
                encryptedBytes.baseAddress,
                bufferSize,
                &numBytesEncrypted
            )
        }
    }
    
    guard cryptStatus == kCCSuccess else {
        throw NSError(domain: "Error during encryption", code: Int(cryptStatus), userInfo: nil)
    }
    
    encryptedData.removeSubrange(numBytesEncrypted..<encryptedData.count)
    
    return encryptedData.base64EncodedString() // 返回加密后的 Base64 编码字符串
}

// MARK: - 解密方法

func decrypt(base64String: String, usingKey key: String) throws -> String {
    let encryptedData = Data(base64Encoded: base64String)! // Base64 解码
    let keyData = Data(key.utf8)
    
    // 填充密钥到 256 位（32 字节）
    let keyLength = kCCKeySizeAES256
    var keyBytes = [UInt8](repeating: 0, count: keyLength)
    keyData.copyBytes(to: &keyBytes, count: min(keyData.count, keyLength))
    
    // AES 解密
    let bufferSize = encryptedData.count + kCCBlockSizeAES128
    var decryptedData = Data(count: bufferSize)
    var numBytesDecrypted = 0
    
    let cryptStatus = decryptedData.withUnsafeMutableBytes { decryptedBytes in
        encryptedData.withUnsafeBytes { encryptedBytes in
            CCCrypt(
                CCOperation(kCCDecrypt),
                CCAlgorithm(kCCAlgorithmAES128),
                CCOptions(kCCOptionPKCS7Padding),
                keyBytes,
                keyLength,
                nil, // 如果使用了 IV，需要传入相同的 IV
                encryptedBytes.baseAddress,
                encryptedData.count,
                decryptedBytes.baseAddress,
                bufferSize,
                &numBytesDecrypted
            )
        }
    }
    
    guard cryptStatus == kCCSuccess else {
        throw NSError(domain: "Error during decryption", code: Int(cryptStatus), userInfo: nil)
    }
    
    decryptedData.removeSubrange(numBytesDecrypted..<decryptedData.count)
    
    return String(data: decryptedData, encoding: .utf8) ?? ""
}
