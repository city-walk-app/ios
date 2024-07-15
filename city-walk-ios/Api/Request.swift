//
//  Request.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/7/15.
//

import Foundation

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
        guard var urlComponents = URLComponents(string: baseUrl + url) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: urlComponents.url!)

        if method == .get {
            urlComponents.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            request.url = urlComponents.url
            request.httpMethod = method.rawValue
        } else if method == .post {
            request.httpMethod = method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: params) else {
                throw URLError(.cannotParseResponse)
            }
            request.httpBody = httpBody
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        do {
            let decodedData = try self.decoder.decode(type, from: data)
            return decodedData
        } catch {
            throw error
        }
    }
}
