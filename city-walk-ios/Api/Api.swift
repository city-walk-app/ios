////
////  Api.swift
////  city-walk-ios
////
////  Created by Tyh2001 on 2024/4/3.
////
//
//import Alamofire
//import Foundation
//import SwiftUI
//
//class Http {
//    private let baseURL = BASE_URL
//    private let token = UserCache.shared.getInfo()?.token
//    private let decoder = JSONDecoder()
//
//    /// 发起网络请求
//    /// - Parameters:
//    ///   - url: 请求路径
//    ///   - method: 请求方法，GET、POST等
//    ///   - parameters: 请求参数
//    ///   - completion: 请求完成后的回调闭包，包含一个 AFDataResponse<Data> 类型的参数
//    func request(url: String, method: HTTPMethod, parameters: [String: Any]?, completion: @escaping (AFDataResponse<Data>) -> Void) {
//        var headers: HTTPHeaders = [:] // 初始化一个空的 HTTPHeaders 字典
//
//        headers["token"] = token
//
//        AF.request(baseURL + url, method: method, parameters: parameters, headers: headers)
//            .responseData { response in
//                completion(response)
//            }
//    }
//
//    func jsonFormat<T: Decodable>(response: AFDataResponse<Data>, type: T.Type) -> Any {
//        switch response.result {
//        case .success(let data):
//            do {
//                let results = try decoder.decode(type, from: data)
//                return results
//            } catch {
//                print("JSON 结构转换错误: \(error)")
//                return [:]
//            }
//        case .failure(let error):
//            print("接口响应错误: \(error)")
//            return [:]
//        }
//    }
//}
//
//class Index: Http {
//    /// 获取邮箱验证码
//    func emailSend(data: [String: Any], callback: @escaping (EmailSend) -> Void) {
//        request(url: "/email/send", method: .post, parameters: data) { response in
//            let formatData = self.jsonFormat(response: response, type: EmailSend.self)
//            callback(formatData as! EmailSend)
//        }
//    }
//
//    /// 邮箱验证码登录
//    func userLoginEmail(data: [String: Any], callback: @escaping (UserLoginEmail) -> Void) {
//        request(url: "/user/login/email", method: .post, parameters: data) { response in
//            let formatData = self.jsonFormat(response: response, type: UserLoginEmail.self)
//            callback(formatData as! UserLoginEmail)
//        }
//    }
//
//    /// 获取用户信息
//    func userInfo(data: [String: Any], callback: @escaping (UserInfo) -> Void) {
//        request(url: "/user/info", method: .get, parameters: data) { response in
//            let formatData = self.jsonFormat(response: response, type: UserInfo.self)
//            callback(formatData as! UserInfo)
//        }
//    }
//
//    /// 获取用户的动态发布日历热力图
//    func userGetCalendarHeatmap(data: [String: Any], callback: @escaping (UserGetCalendarHeatmap) -> Void) {
//        request(url: "/user/get_calendar_heatmap", method: .get, parameters: data) { response in
//            let formatData = self.jsonFormat(response: response, type: UserGetCalendarHeatmap.self)
//            callback(formatData as! UserGetCalendarHeatmap)
//        }
//    }
//
//    /// 获取指定用户去过的省份
//    func getUserProvince(data: [String: Any], callback: @escaping (GetUserProvince) -> Void) {
//        request(url: "/gps/get_user_province", method: .get, parameters: data) { response in
//            let formatData = self.jsonFormat(response: response, type: GetUserProvince.self)
//            callback(formatData as! GetUserProvince)
//        }
//    }
//
//    /// 获取指定用户去过的省份
//    func getRouteList(data: [String: Any], callback: @escaping (GetRouteList) -> Void) {
//        request(url: "/gps/get_route_list", method: .get, parameters: data) { response in
//            let formatData = self.jsonFormat(response: response, type: GetRouteList.self)
//            callback(formatData as! GetRouteList)
//        }
//    }
//
//    /// 获取经验排行榜
//    func experienceRanking(data: [String: Any], callback: @escaping (ExperienceRanking) -> Void) {
//        request(url: "/experience/ranking", method: .get, parameters: data) { response in
//            let formatData = self.jsonFormat(response: response, type: ExperienceRanking.self)
//            callback(formatData as! ExperienceRanking)
//        }
//    }
//}
