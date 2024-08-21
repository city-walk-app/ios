//
//  MainView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import SwiftUI

struct MainView: View {
    /// 用户 id
    var user_id: String

    struct MonthSelectItem {
        var title: String
        var key: Int
        var active: Bool
    }
    
    let monthSelectList = [
        MonthSelectItem(title: "一", key: 1, active: false),
        MonthSelectItem(title: "二", key: 2, active: false),
        MonthSelectItem(title: "三", key: 3, active: false),
        MonthSelectItem(title: "四", key: 4, active: false),
        MonthSelectItem(title: "五", key: 5, active: false),
        MonthSelectItem(title: "六", key: 6, active: false),
        MonthSelectItem(title: "七", key: 7, active: false),
        MonthSelectItem(title: "八", key: 8, active: false),
        MonthSelectItem(title: "九", key: 9, active: false),
        MonthSelectItem(title: "十", key: 10, active: false),
        MonthSelectItem(title: "十一", key: 11, active: false),
        MonthSelectItem(title: "十二", key: 12, active: false),
    ]
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    /// 省份列表
    @State private var provinceList: [GetUserProvinceJigsawType.GetUserProvinceJigsawData] = []
    /// 热力图
    @State private var heatmap: [GetLocationUserHeatmapType.GetLocationUserHeatmapData] = []
    /// 步行记录列表
    @State private var routeList: [GetUserRouteListType.GetUserRouteListData] = []
    /// 用户的身份信息
    @State private var userInfo: UserInfoType?
    /// 步行记录详情列表
    @State private var routeDetailList: [GetLocationUserHeatmapType.GetLocationUserHeatmapDataRoutes]?
    /// 当前日期
    @State private var selectedDate = Date()
    /// 是否显示选择日期的对话框
    @State private var showDatePicker = false
    /// 选中的热力图元素索引
    @State private var routeDetailActiveIndex: Int?
    /// 步行记录详情列表是否在加载中
    @State private var isRouteDetailListLoading = true
  
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 用户信息
                    if let userInfo = self.userInfo {
                        // 头像
                        AsyncImage(url: URL(string: userInfo.avatar ?? defaultAvatar)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 74, height: 74) // 设置图片的大小
                                .clipShape(Circle()) // 将图片裁剪为圆形
                        } placeholder: {
                            Circle()
                                .fill(skeletonBackground)
                                .frame(width: 74, height: 74)
                        }
                        
                        // 昵称
                        Text("\(userInfo.nick_name)")
                            .padding(.top, 16)
                            .foregroundStyle(Color(hex: "#333333"))
                            .font(.system(size: 18))
                        
                        // 签名
                        Text("\(userInfo.signature ?? "")")
                            .padding(.top, 8)
                            .foregroundStyle(Color(hex: "#666666"))
                            .font(.system(size: 14))
                    } else {
                        Circle()
                            .fill(skeletonBackground)
                            .frame(width: 74, height: 74)
                        
                        // 昵称
                        RoundedRectangle(cornerRadius: 4)
                            .fill(skeletonBackground)
                            .padding(.top, 16)
                            .frame(width: 54, height: 31)
                           
                        // 签名
                        RoundedRectangle(cornerRadius: 4)
                            .fill(skeletonBackground)
                            .padding(.top, 16)
                            .frame(width: 280, height: 31)
                    }
                    
                    // 省份版图
                    if !self.provinceList.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(self.provinceList, id: \.vis_id) { item in
                                    Button {} label: {
                                        Color.clear
                                            .frame(width: 107, height: 107)
                                            .background {
                                                AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/provinces/\(item.province_code).png")) { phase in
                                                    if let image = phase.image {
                                                        Color(hex: item.background_color)
                                                            .mask {
                                                                image
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fill)
                                                            }
                                                    } else {
                                                        Circle()
                                                            .fill(skeletonBackground)
                                                            .frame(width: 107, height: 107)
                                                    }
                                                }
                                            }
                                    }
                                }
                            }
                            .padding(.horizontal, 17)
                        }
                        .scrollIndicators(.hidden)
                        .padding(.vertical, 24)
                    } else {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0 ..< 4) { _ in
                                    Circle()
                                        .fill(skeletonBackground)
                                        .frame(width: 107, height: 107)
                                }
                            }
                            .padding(.horizontal, 17)
                        }
                        .scrollIndicators(.hidden)
                        .padding(.vertical, 24)
                    }
                    
                    let heatmapColumns = [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ]
                  
                    // 热力图
                    if !self.heatmap.isEmpty {
                        // 日期选择
                        HStack {
                            Spacer()
                            
                            Button {
                                self.showDatePicker.toggle()
                            } label: {
                                HStack {
                                    Text("2024年08月")
                                        .foregroundStyle(Color(hex: "#9A9A9A"))
                                        .font(.system(size: 12))
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(Color(hex: "#9A9A9A"))
                                        .font(.system(size: 12))
                                }
                                .padding(.vertical, 5)
                                .padding(.horizontal, 8)
                                .background(Color(hex: "#F3F3F3"))
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // 热力图
                        HStack {
                            // 图例
                            VStack(spacing: 30) {
                                HStack(spacing: 7) {
                                    AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/main-heatmap-1.png")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 15, height: 17)
                                    } placeholder: {
                                        Color.clear
                                            .frame(width: 15, height: 17)
                                    }
                                    
                                    Text("打卡多")
                                        .foregroundStyle(Color(hex: "#666666"))
                                        .font(.system(size: 14))
                                }
                                
                                HStack(spacing: 7) {
                                    AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/main-heatmap-2.png")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 15, height: 17)
                                    } placeholder: {
                                        Color.clear
                                            .frame(width: 15, height: 17)
                                    }
                                    
                                    Text("打卡少")
                                        .foregroundStyle(Color(hex: "#666666"))
                                        .font(.system(size: 14))
                                }
                                
                                HStack(spacing: 7) {
                                    AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/main-heatmap-3.png")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 15, height: 17)
                                    } placeholder: {
                                        Color.clear
                                            .frame(width: 15, height: 17)
                                    }
                                    
                                    Text("未打卡")
                                        .foregroundStyle(Color(hex: "#666666"))
                                        .font(.system(size: 14))
                                }
                            }
                            .frame(width: 98)
                            
                            // 热力图
                            HStack {
                                ZStack {
                                    LazyVGrid(columns: heatmapColumns, spacing: 13) {
                                        ForEach(Array(self.heatmap.enumerated()), id: \.element.date) { index, item in
                                            let isHaveRoute: Bool = item.route_count != nil
                                                && item.route_count! > 0
                                                && item.background_color != nil
                                            
                                            Button {
                                                if isHaveRoute {
                                                    withAnimation {
                                                        if self.routeDetailActiveIndex == index {
                                                            self.routeDetailActiveIndex = nil
                                                            self.routeDetailList = nil
                                                        } else {
                                                            self.routeDetailActiveIndex = index
                                                            self.routeDetailList = item.routes
                                                        }
                                                    }
                                                }
                                                print("点击的索引", index)
                                            } label: {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color(hex: isHaveRoute
                                                            ? "\(item.background_color!)"
                                                            : "#eeeeee"
                                                    ))
                                                    .frame(width: 26, height: 26)
                                            }
                                            .scaleEffect(self.routeDetailActiveIndex == index ? 40 : 1)
                                            .zIndex(self.routeDetailActiveIndex == index ? 30 : 1)
                                            .offset(x: self.routeDetailActiveIndex == index ? -13 : 0, y: self.routeDetailActiveIndex == index ? -13 : 0) // 根据放大倍数进行偏移
                                        }
                                    }
                                    
                                    if let activeIndex = self.routeDetailActiveIndex {
                                        let item = self.heatmap[activeIndex]
                                        
                                        Button {
                                            withAnimation {
                                                self.routeDetailActiveIndex = nil
                                                self.routeDetailList = nil
                                            }
                                        } label: {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color(hex: "\(item.background_color!)"))
                                                .scaleEffect(1)
                                                .zIndex(3)
                                                .animation(.easeInOut(duration: 0.3), value: self.routeDetailActiveIndex)
                                                .transition(.identity)
                                                .buttonStyle(PlainButtonStyle())
                                                .overlay {
                                                    VStack(spacing: 4) {
                                                        Text("\(item.date)")
                                                        Text("打卡\(item.routes.count)个地方")
                                                    }
                                                    .font(.system(size: 22))
                                                    .foregroundStyle(.white)
                                                    .bold()
                                                }
                                        }
                                    }
                                }
                                .clipped()
                                .cornerRadius(10)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(16)
                    } else {
                        // 日期选择
                        HStack {
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(skeletonBackground)
                                .frame(width: 106, height: 26)
                        }
                        .padding(.horizontal, 16)
                        
                        // 热力图
                        HStack {
                            // 图例
                            VStack(spacing: 30) {
                                ForEach(0 ..< 3) { _ in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(skeletonBackground)
                                        .frame(width: 66, height: 20)
                                }
                            }
                            .frame(width: 98)
                            
                            // 热力图
                            HStack {
                                LazyVGrid(columns: heatmapColumns, spacing: 13) {
                                    ForEach(0 ..< 31) { _ in
                                        Color.clear
                                            .frame(width: 26, height: 26)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(skeletonBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(16)
                    }
                    
                    // 步行记录详情
                    if let routeDetailList = self.routeDetailList,
                       self.routeDetailList != nil,
                       !self.routeDetailList!.isEmpty
                    {
                        VStack(spacing: 24) {
                            ForEach(Array(routeDetailList.enumerated()), id: \.element.create_at) { index, item in
                                HStack {
                                    // 左侧标识和头像
                                    VStack {
                                        if index == 0 {
                                            if let userInfo = self.userInfo {
                                                AsyncImage(url: URL(string: userInfo.avatar ?? defaultAvatar)) { image in
                                                    image
                                                        .resizable()
                                                        .frame(width: 46, height: 46)
                                                        .clipShape(Circle()) // 将图片裁剪为圆形
                                                } placeholder: {}
                                            }
                                        } else {
                                            Circle()
                                                .fill(Color.white) // 设置圆形的背景颜色为白色
                                                .frame(width: 20, height: 20) // 设置圆形的大小
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color(hex: "#F7B535"), lineWidth: 1)
                                                        .overlay(content: {
                                                            Circle()
                                                                .fill(Color(hex: "#F7B535"))
                                                                .frame(width: 12, height: 12) // 设置圆形的大小
                                                        })
                                                )
                                        }
                                    }
                                    .frame(width: 76)
                                    
                                    // 右侧详情内容
                                    ZStack(alignment: .topTrailing) {
                                        // 左上角的图表
                                        AsyncImage(url: URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/main-position.png")) { image in
                                            image
                                                .resizable()
                                                .frame(width: 61, height: 56)
                                        } placeholder: {}
                                            .zIndex(30)
                                        
                                        // 主要内容
                                        VStack(alignment: .leading) {
                                            // 头部内容
                                            HStack {
                                                Text("\(item.city ?? "")")
                                                    .padding(.horizontal, 24)
                                                    .frame(maxHeight: .infinity)
                                                    .background(
                                                        LinearGradient(
                                                            gradient: Gradient(
                                                                colors: [Color(hex: "#FFF8E8"), Color(hex: "#ffffff")]
                                                            ),
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                
                                                Spacer()
                                            }
                                            .frame(height: 46)
                                            
                                            // 发布的文案
                                            if item.content != nil && item.content != "" {
                                                HStack {
                                                    Text("\(item.content!)")
                                                        .font(.system(size: 14))
                                                        .foregroundStyle(Color(hex: "#666666"))
                                                        .padding(.horizontal, 24)
                                                        .padding(.top, 14)
                                                        .padding(.bottom, 12)
                                                }
                                            }
                                            
                                            // 发布的图片
                                            if item.picture != nil && !item.picture!.isEmpty {
                                                ScrollView(.horizontal) {
                                                    HStack {
                                                        ForEach(item.picture!, id: \.self) { pictureItem in
                                                            AsyncImage(url: URL(string: pictureItem)) { image in
                                                                image
                                                                    .resizable()
                                                                    .frame(width: 174, height: 175)
                                                                    .cornerRadius(8)
                                                            } placeholder: {
                                                                Rectangle()
                                                                    .fill(skeletonBackground)
                                                                    .frame(width: 174, height: 174)
                                                            }
                                                        }
                                                    }
                                                    .padding(.horizontal, 24)
                                                    .padding(.bottom, 23)
                                                }
                                                .scrollIndicators(.hidden)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .shadow(color: Color(hex: "#656565").opacity(0.1), radius: 5.4, x: 0, y: 1)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                    }
                    
                    // 步行记录
                    HStack(spacing: 17) {
                        let columns = [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ]
                        
                        if isRouteDetailListLoading {
                            LazyVGrid(columns: columns, alignment: .center) {
                                ForEach(0 ..< 5) { _ in
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(skeletonBackground)
                                        .frame(height: 116)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        } else {
                            if !self.routeList.isEmpty {
                                LazyVGrid(columns: columns, alignment: .center) {
                                    ForEach(self.routeList, id: \.list_id) { item in
                                        NavigationLink(destination: RouteDetailView(list_id: item.list_id, user_id: self.user_id)) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(hex: item.mood_color ?? "#FFCC94"))
                                                .frame(height: 116)
                                                .frame(maxWidth: .infinity)
                                                .overlay {
                                                    HStack {
                                                        Spacer()
                                                    
                                                        VStack {
                                                            // 地点数量
                                                            Text("地点×\(item.count)")
                                                                .foregroundStyle(.white)
                                                                .font(.system(size: 16))
                                                                .padding(.top, 28)
                                                                .padding(.trailing, 16)
                                                        
                                                            Spacer()
                                                        
                                                            // 时间
                                                            Text("\(convertToDateOnly(from: item.create_at)!)")
                                                                .foregroundStyle(.white)
                                                                .font(.system(size: 14))
                                                                .padding(.bottom, 10)
                                                                .padding(.trailing, 16)
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                }
                            } else {
                                EmptyState(title: "暂无打卡记录")
                                    .padding(.top, 100)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, viewPaddingTop)
            }
            .background(viewBackground)
            .overlay(alignment: .top) {
                VariableBlurView(maxBlurRadius: 12)
                    .frame(height: topSafeAreaInsets + globalNavigationBarHeight)
                    .ignoresSafeArea()
            }
        }
        .background(Color(hex: "#FAF9FA"))
        .navigationBarItems(leading: BackButton {
            self.presentationMode.wrappedValue.dismiss() // 返回上一个视图
        }) // 自定义返回按钮
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showDatePicker) {
            VStack {
                VStack {
                    // 选择年份
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(monthSelectList, id: \.key) { item in
                                Button {} label: {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "#eeeeee"))
                                        .frame(width: 110, height: 110)
                                        .overlay(alignment: .bottomTrailing) {
                                            Text("\(item.title)月")
                                                .padding()
                                                .foregroundStyle(Color(hex: "#333333"))
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .scrollIndicators(.hidden)
                    
                    // 选择月份
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(monthSelectList, id: \.key) { item in
                                Button {} label: {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "#eeeeee"))
                                        .frame(width: 110, height: 110)
                                        .overlay(alignment: .bottomTrailing) {
                                            Text("\(item.title)月")
                                                .padding()
                                                .foregroundStyle(Color(hex: "#333333"))
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .scrollIndicators(.hidden)
                }
                
                Spacer()

                Button {
                    self.showDatePicker = false
                } label: {
                    Text("确定")
                        .padding()
                        .frame(width: 100)
                        .background(Color(hex: "#F3943F"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.top, 40)
            // https://x.com/ios_dev_alb/status/1824031474502246710
            .presentationDetents([.medium])
            .presentationCornerRadius(40)
        }
        .onAppear {
            Task {
                await self.getUserInfo() // 获取用户信息
                await self.getLocationUserHeatmap() // 获取用户指定月份打卡热力图
                await self.getUserProvinceJigsaw() // 获取用户解锁的省份版图列表
                await self.getUserRouteList() // 获取用户步行记录列表
            }
        }
    }
    
    /// 获取用户步行记录列表
    private func getUserRouteList() async {
        do {
            withAnimation {
                self.isRouteDetailListLoading = true
            }
            
            let res = try await Api.shared.getUserRouteList(params: ["user_id": user_id])

            withAnimation {
                self.isRouteDetailListLoading = false
            }
            
            guard res.code == 200, let data = res.data else {
                return
            }

            withAnimation {
                self.routeList = data
            }
        } catch {
            print("获取用户步行记录列表异常")
            withAnimation {
                self.isRouteDetailListLoading = false
            }
        }
    }

    /// 获取用户解锁的省份版图列表
    private func getUserProvinceJigsaw() async {
        do {
            let res = try await Api.shared.getUserProvinceJigsaw(params: ["user_id": user_id])

            guard res.code == 200, let data = res.data else {
                return
            }

            withAnimation {
                self.provinceList = data
            }
        } catch {
            print("获取用户解锁的省份版图列表异常")
        }
    }

    /// 获取用户信息
    private func getUserInfo() async {
        do {
            let res = try await Api.shared.getUserInfo(params: ["user_id": user_id])

            guard res.code == 200, let data = res.data else {
                return
            }
            
            withAnimation {
                self.userInfo = data
            }
        } catch {
            print("获取用户信息异常")
        }
    }

    /// 获取用户指定月份打卡热力图
    private func getLocationUserHeatmap() async {
        do {
            let res = try await Api.shared.getLocationUserHeatmap(params: ["user_id": user_id])

            guard res.code == 200, let data = res.data else {
                return
            }
            
            withAnimation {
                self.heatmap = data
            }
        } catch {
            print("取用户指定月份打卡热力图异常")
        }
    }
}

#Preview {
    MainView(user_id: "U131995175454824711531011225172573302849")
        .environmentObject(UserInfoData())
}
