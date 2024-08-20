//
//  Request.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/7/15.
//

import Foundation

/// HTTP 请求方法
enum HTTPMethods: String {
    case get = "GET"
    case post = "POST"
}

/// 请求拦截器协议
protocol RequestInterceptor {
    func intercept(_ request: URLRequest) -> URLRequest
}

/// 基础请求类
class Request {
    static let shared = Request()
    private let baseUrl = BASE_URL
    private let decoder = JSONDecoder()
    private let session = URLSession.shared

    /// 发送请求
    /// - Parameters:
    ///   - url: 请求路径
    ///   - params: 请求参数
    ///   - method: 请求方法
    ///   - type: 解析类型
    /// - Returns: 请求结果
    func request<T: Decodable>(url: String, params: [String: Any], method: HTTPMethods, type: T.Type) async throws -> T {
        guard let urlComponents = URLComponents(string: baseUrl + url) else {
            throw URLError(.badURL)
        }

//        print("请求地址", urlComponents)

        var request = URLRequest(url: urlComponents.url!)

//        print("创建请求", request)

        if method == .post {
            request.httpMethod = method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: params) else {
                throw URLError(.cannotParseResponse)
            }
            // 6. 设置请求头字段
            let token = UserCache.shared.getToken()

//            if let token = token {
            request.setValue(token, forHTTPHeaderField: "token")
//            }

            request.httpBody = httpBody
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("错误响应----")
            throw URLError(.badServerResponse)
        }

//        print("响应详情", httpResponse)
//        print("HTTP 状态码:", httpResponse.statusCode)
//        print("响应头:", httpResponse.allHeaderFields)

        // 检查返回的数据是否为空
        if data.isEmpty {
            print("响应内容为空")
            throw URLError(.zeroByteResource)
        }

        print("请求响应", data)

        do {
            let decodedData = try self.decoder.decode(type, from: data)

            return decodedData
        } catch {
            print("JSON 解析错误", error)
            throw error
        }
    }
}
