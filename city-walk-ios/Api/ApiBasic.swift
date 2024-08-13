////
////  BasicApi.swift
////  city-walk-ios
////
////  Created by Tyh2001 on 2024/4/11.
////
//
//import Foundation
//
///// HTTP 请求方法
//enum HTTPMethods: String {
//    case get = "GET"
//    case post = "POST"
//}
//
///// 使用 Swift 基础库实现的网络请求
//struct ApiBasicOld {
//    /// 单例模式
//    static let shared = ApiBasicOld()
//    /// 基础请求地址
//    private let baseUrl = BASE_URL
//    /// json 解析器
//    private let decoder = JSONDecoder()
//    /// token
//    private let token = UserCache.shared.getToken()
//    
//    /// 发送 GET 请求
//    /// - Parameters:
//    ///   - url: 请求路径
//    ///   - params: 请求参数
//    ///   - type: 解析类型
//    ///   - callback: 请求成功的回调方法
//    ///     Result https://developer.apple.com/documentation/swift/result/
//    ///     urlcomponents https://developer.apple.com/documentation/foundation/urlcomponents/
//    private func request<T: Decodable>(url: String, params: [String: Any], method: HTTPMethods, type: T.Type, callback: @escaping (Result<T, Error>) -> Void) {
//        // 1. 创建一个 URLSession 实例
//        let session = URLSession.shared
//        
//        // 2. 创建 URLComponents 来构建 URL
//        guard var urlComponents = URLComponents(string: baseUrl + url) else {
//            print("URLComponents 创建失败")
//            return
//        }
//        
//        // 4. 创建 URL 对象
//        guard let url = urlComponents.url else {
//            print("URL 对象创建失败")
//            return
//        }
//        
//        // 5. 创建 URLRequest 对象并设置参数
//        var request = URLRequest(url: url)
//        
////        if method == .post {
//        guard let httpBody = try? JSONSerialization.data(withJSONObject: params) else {
//            print("Failed to create HTTP body")
//            return
//        }
//            
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = httpBody
////        } else if method == .get {
////            request.httpMethod = "GET"
////        }
//        
//        // 6. 设置请求头字段
//        request.setValue(token, forHTTPHeaderField: "token")
//        
//        //        print("用户 Token", token)
//        
//        // 7. 创建一个数据任务（Data Task）
//        let task = session.dataTask(with: request) { data, _, error in
//            if let error = error {
//                print("接口响应错误: \(error)")
//                return
//            }
//            
//            if let data = data {
//                do {
//                    // 将原始数据转换为 JSON
//                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                    
//                    // 使用 JSONDecoder 解析 JSON 数据为您的对象类型
//                    let jsonData = try JSONSerialization.data(withJSONObject: json ?? [:], options: [])
//                    
//                    // 将 json 数据转换为实例对象
//                    let toObject = jsonToObject(type: type.self, data: jsonData)
//                    
//                    switch toObject {
//                    case .success(let data):
//                        //                        print("JSON 转换成功", data)
//                        callback(.success(data))
//                    case .failure(let err):
//                        print("JSON 转换失败", err)
//                        callback(.failure(err))
//                    }
//                } catch {
//                    print("JSON 解析异常: \(error)")
//                }
//            }
//        }
//        
//        // 8. 启动任务
//        task.resume()
//    }
//    
//    /// 将 JSON 转换为实例对象
//    /// - Parameters:
//    ///   - type: 转换的类型
//    ///   - data: JSON 数据
//    /// - Returns: 根据类型转换的实例对象
//    private func jsonToObject<T: Decodable>(type: T.Type, data: Data) -> Result<T, Error> {
//        do {
//            let decodedData = try decoder.decode(type, from: data)
//            return .success(decodedData)
//        } catch {
//            return .failure(error)
//        }
//    }
//    
//    /// 获取用户信息
//    func getUserInfo(params: [String: Any], callback: @escaping (Result<UserInfo, Error>) -> Void) {
//        request(url: "/user/get/user_info", params: params, method: .post, type: UserInfo.self, callback: callback)
//    }
//    
//    /// 邮箱验证码登录
//    func userLoginEmail(params: [String: Any], callback: @escaping (Result<UserLoginEmail, Error>) -> Void) {
//        request(url: "/user/login/email", params: params, method: .post, type: UserLoginEmail.self, callback: callback)
//    }
//    
//    /// 设置用户信息
//    func setUserInfo(params: [String: Any], callback: @escaping (Result<UserLoginEmail, Error>) -> Void) {
//        request(url: "/user/set/user_info", params: params, method: .post, type: UserLoginEmail.self, callback: callback)
//    }
//    
//    /// 发送邮箱验证码
//    func emailSend(params: [String: Any], callback: @escaping (Result<EmailSend, Error>) -> Void) {
//        request(url: "/email/send", params: params, method: .post, type: EmailSend.self, callback: callback)
//    }
//    
//    /// 获取经验排行榜
//    func experienceRanking(params: [String: Any], callback: @escaping (Result<ExperienceRanking, Error>) -> Void) {
//        request(url: "/experience/ranking", params: params, method: .post, type: ExperienceRanking.self, callback: callback)
//    }
//}
