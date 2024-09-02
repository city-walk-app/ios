//
//  MainView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/4/3.
//

import Kingfisher
import SwiftUI

private let mainHeatmap1 = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/main-heatmap-1.png")
private let mainHeatmap2 = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/main-heatmap-2.png")
private let mainHeatmap3 = URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/city-walk/main-heatmap-3.png")

/// 热力图布局
private let heatmapColumns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
]

/// 月份选择
private let selectmonths = [
    SelectmonthItem(title: "一", key: 1),
    SelectmonthItem(title: "二", key: 2),
    SelectmonthItem(title: "三", key: 3),
    SelectmonthItem(title: "四", key: 4),
    SelectmonthItem(title: "五", key: 5),
    SelectmonthItem(title: "六", key: 6),
    SelectmonthItem(title: "七", key: 7),
    SelectmonthItem(title: "八", key: 8),
    SelectmonthItem(title: "九", key: 9),
    SelectmonthItem(title: "十", key: 10),
    SelectmonthItem(title: "十一", key: 11),
    SelectmonthItem(title: "十二", key: 12),
]
/// 开始的年份（项目从 2024 年开始，不允许选择 2024 之前的年份）
private let startYear = 2024
/// 结束的年份，就是当前的年份
private let endYear = Calendar.current.component(.year, from: Date())
/// 年份选择
private let selectYears = Array(startYear ... endYear)

/// 我的
struct MainView: View {
    /// 用户 id
    var user_id: String
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    /// 我的数据
    @EnvironmentObject private var mainData: MainData
    /// 当前日期
    @State private var selectedDate = Date()
    /// 是否显示选择日期的对话框
    @State private var showDatePicker = false
  
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 用户信息
                    if let userInfo = mainData.userInfo {
                        // 头像
                        KFImage(URL(string: userInfo.avatar ?? defaultAvatar))
                            .placeholder {
                                Circle()
                                    .fill(Color("skeleton-background"))
                                    .frame(width: 74, height: 74)
                            }
                            .resizable()
                            .frame(width: 74, height: 74)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                     
                        // 昵称
                        Text("\(userInfo.nick_name)")
                            .padding(.top, 16)
                            .foregroundStyle(Color("text-1"))
                            .font(.system(size: 18))
                        
                        // 签名
                        Text("\(userInfo.signature ?? "")")
                            .padding(.top, 8)
                            .foregroundStyle(Color("text-2"))
                            .font(.system(size: 14))
                    } else {
                        Circle()
                            .fill(Color("skeleton-background"))
                            .frame(width: 74, height: 74)
                        
                        // 昵称
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("skeleton-background"))
                            .padding(.top, 16)
                            .frame(width: 54, height: 31)
                        
                        // 签名
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("skeleton-background"))
                            .padding(.top, 16)
                            .frame(width: 280, height: 31)
                    }
                    
                    // 省份版图
                    if mainData.isProvinceListLoading {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0 ..< 4) { _ in
                                    Circle()
                                        .fill(Color("skeleton-background"))
                                        .frame(width: 107, height: 107)
                                        .redacted(reason: .placeholder)
                                }
                            }
                            .padding(.horizontal, 17)
                        }
                        .scrollIndicators(.hidden)
                        .padding(.vertical, 24)
                    } else {
                        // 有数据
                        if !mainData.provinceList.isEmpty {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(mainData.provinceList, id: \.vis_id) { item in
                                        Button {} label: {
                                            Color.clear
                                                .frame(width: 107, height: 107)
                                                .background {
                                                    Color(hex: item.background_color)
                                                        .mask {
                                                            KFImage(URL(string: "https://city-walk.oss-cn-beijing.aliyuncs.com/assets/images/provinces/\(item.province_code).png"))
                                                                .placeholder {
                                                                    Circle()
                                                                        .fill(Color("skeleton-background"))
                                                                        .frame(width: 107, height: 107)
                                                                }
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
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
                                    Circle()
                                        .fill(Color("skeleton-background"))
                                        .frame(width: 107, height: 107)
                                        .redacted(reason: .placeholder)
                                        .overlay {
                                            Text("暂无版图")
                                                .font(.system(size: 13))
                                                .foregroundStyle(.gray)
                                        }
                                }
                                .padding(.horizontal, 17)
                            }
                            .scrollIndicators(.hidden)
                            .padding(.vertical, 24)
                        }
                    }
                    
                    // 热力图
                    if !mainData.isRouteHistoryLoading {
                        // 日期选择
                        HStack {
                            Spacer()
                            
                            Button {
                                self.showDatePicker.toggle()
                            } label: {
                                HStack {
                                    Text("\(mainData.year)年\(mainData.month)月")
                                        .foregroundStyle(Color("text-3"))
                                        .font(.system(size: 14))
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(Color("text-3"))
                                        .font(.system(size: 12))
                                }
                                .padding(.vertical, 5)
                                .padding(.horizontal, 8)
                                .background(Color("background-2"))
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        if mainData.heatmap.isEmpty {
                            MainHeatmapSkeletonView()
                        } else {
                            // 热力图
                            HStack {
                                // 图例
                                VStack(spacing: 30) {
                                    HStack(spacing: 7) {
                                        KFImage(mainHeatmap1)
                                            .placeholder {
                                                Color.clear
                                                    .frame(width: 15, height: 17)
                                            }
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 15, height: 17)
                                        
                                        Text("打卡多")
                                            .foregroundStyle(Color("text-2"))
                                            .font(.system(size: 14))
                                    }
                                    
                                    HStack(spacing: 7) {
                                        KFImage(mainHeatmap2)
                                            .placeholder {
                                                Color.clear
                                                    .frame(width: 15, height: 17)
                                            }
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 15, height: 17)
                                        
                                        Text("打卡少")
                                            .foregroundStyle(Color("text-2"))
                                            .font(.system(size: 14))
                                    }
                                    
                                    HStack(spacing: 7) {
                                        KFImage(mainHeatmap3)
                                            .placeholder {
                                                Color.clear
                                                    .frame(width: 15, height: 17)
                                            }
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 15, height: 17)
                                        
                                        Text("未打卡")
                                            .foregroundStyle(Color("text-2"))
                                            .font(.system(size: 14))
                                    }
                                }
                                .frame(width: 98)
                                
                                // 热力图
                                HStack {
                                    ZStack {
                                        LazyVGrid(columns: heatmapColumns, spacing: 13) {
                                            ForEach(Array(mainData.heatmap.enumerated()), id: \.element.date) { index, item in
                                                let isHaveRoute: Bool = item.route_count != nil
                                                    && item.route_count! > 0
                                                    && item.background_color != nil
                                                
                                                Button {
                                                    if isHaveRoute {
                                                        withAnimation {
                                                            if mainData.routeDetailActiveIndex == index {
                                                                mainData.routeDetailActiveIndex = nil
                                                                mainData.routeDetailList = nil
                                                            } else {
                                                                mainData.routeDetailActiveIndex = index
                                                                mainData.routeDetailList = item.routes
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
                                                .scaleEffect(mainData.routeDetailActiveIndex == index ? 40 : 1)
                                                .zIndex(mainData.routeDetailActiveIndex == index ? 30 : 1)
                                                .offset(x: mainData.routeDetailActiveIndex == index ? -13 : 0, y: mainData.routeDetailActiveIndex == index ? -13 : 0) // 根据放大倍数进行偏移
                                            }
                                        }
                                        
                                        if let activeIndex = mainData.routeDetailActiveIndex {
                                            let item = mainData.heatmap[activeIndex]
                                            
                                            Button {
                                                withAnimation {
                                                    mainData.routeDetailActiveIndex = nil
                                                    mainData.routeDetailList = nil
                                                }
                                            } label: {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color(hex: "\(item.background_color!)"))
                                                    .scaleEffect(1)
                                                    .zIndex(3)
                                                    .animation(.easeInOut(duration: 0.3), value: mainData.routeDetailActiveIndex)
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
                        }
                    }
                    // 热力图加载中
                    else {
                        // 日期选择
                        HStack {
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color("skeleton-background"))
                                .frame(width: 106, height: 26)
                        }
                        .padding(.horizontal, 16)
                        
                        MainHeatmapSkeletonView() // 热力图骨架图
                    }
                    
                    // 步行记录详情
                    if let routeDetailList = mainData.routeDetailList,
                       mainData.routeDetailList != nil,
                       !mainData.routeDetailList!.isEmpty
                    {
                        VStack(spacing: 24) {
                            ForEach(Array(routeDetailList.enumerated()), id: \.element.create_at) { index, item in
                                HStack {
                                    // 左侧标识和头像
                                    VStack {
                                        if index == 0 {
                                            if let userInfo = mainData.userInfo {
                                                KFImage(URL(string: userInfo.avatar ?? defaultAvatar))
                                                    .resizable()
                                                    .frame(width: 46, height: 46)
                                                    .aspectRatio(contentMode: .fill)
                                                    .clipShape(Circle())
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
                                        // 左上角的图标
                                        KFImage(mainPosition)
                                            .resizable()
                                            .frame(width: 61, height: 56)
                                            .zIndex(30)
                                       
                                        // 主要内容
                                        VStack(alignment: .leading) {
                                            // 头部内容
                                            HStack {
                                                Text("\(item.city ?? "")")
                                                    .padding(.horizontal, 24)
                                                    .frame(maxHeight: .infinity)
                                                    .foregroundStyle(Color("text-1"))
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
                                                        .foregroundStyle(Color("text-2"))
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
                                                            KFImage(URL(string: pictureItem))
                                                                .placeholder {
                                                                    Rectangle()
                                                                        .fill(Color("skeleton-background"))
                                                                        .frame(width: 174, height: 174)
                                                                        .cornerRadius(8)
                                                                }
                                                                .resizable()
                                                                .frame(width: 174, height: 175)
                                                                .aspectRatio(contentMode: .fit)
                                                                .cornerRadius(8)
                                                        }
                                                    }
                                                    .padding(.horizontal, 24)
                                                    .padding(.bottom, 23)
                                                }
                                                .scrollIndicators(.hidden)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
//                                        .background(.white)
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
                        
                        if mainData.isRouteHistoryLoading {
                            LazyVGrid(columns: columns, alignment: .center) {
                                ForEach(0 ..< 5) { _ in
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color("skeleton-background"))
                                        .frame(height: 116)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        } else {
                            if !mainData.routeList.isEmpty {
                                LazyVGrid(columns: columns, alignment: .center) {
                                    ForEach(mainData.routeList, id: \.list_id) { item in
                                        MainRouteListItem(item: item, user_id: user_id)
                                    }
                                }
                            } else {
                                EmptyState(title: "暂无打卡记录")
                                    .padding(.vertical, 70)
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
                            ForEach(selectYears, id: \.self) { item in
                                Button {
                                    mainData.year = item
                                } label: {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(mainData.year == item ? Color("theme-1") : Color(hex: "#eeeeee"))
                                        .frame(width: 110, height: 110)
                                        .overlay(alignment: .bottomTrailing) {
                                            Text("\(item)年")
                                                .padding()
                                                .font(.system(size: 17))
                                                .bold()
                                                .foregroundStyle(mainData.year == item ? Color.white : Color(hex: "#333333"))
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .scrollIndicators(.hidden)
                    
                    // 选择月份
                    ScrollViewReader { scrollViewProxy in
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(selectmonths, id: \.key) { item in
                                    Button {
                                        mainData.month = item.key
                                    } label: {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(mainData.month == item.key ? Color("theme-1") : Color(hex: "#eeeeee"))
                                            .frame(width: 110, height: 110)
                                            .overlay(alignment: .bottomTrailing) {
                                                Text("\(item.title)月")
                                                    .padding()
                                                    .font(.system(size: 17))
                                                    .bold()
                                                    .foregroundStyle(mainData.month == item.key ? Color.white : Color(hex: "#333333"))
                                            }
                                    }
                                    .id(item.key)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .scrollIndicators(.hidden)
                        .onAppear {
                            // 滚动到默认选择的月份
                            withAnimation(.easeInOut(duration: 1.0)) {
                                scrollViewProxy.scrollTo(mainData.month, anchor: .center)
                            }
                        }
                    }
                }
                
                Spacer()

                Button {
                    mainData.isFilter = true
                    
                    Task {
                        await mainData.getUserRouteHistory() // 获取用户步行历史记录
                    }
                    
                    self.showDatePicker.toggle()
                } label: {
                    Text("确定")
                        .padding()
                        .frame(width: 100)
                        .background(Color("theme-1"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.top, 40)
            // https://x.com/ios_dev_alb/status/1824031474502246710
            .presentationDetents([.fraction(0.8), .medium])
            .presentationCornerRadius(40)
        }
        .onAppear {
            mainData.setUserId(user_id: user_id) // 设置用户 id
            
            Task {
                await mainData.getUserInfo() // 获取用户信息
                await mainData.getUserRouteHistory() // 获取用户步行历史记录
                await mainData.getUserProvinceJigsaw() // 获取用户解锁的省份版图列表
            }
        }
        .onDisappear {
            mainData.onDisappear() // 清除数据
        }
    }
}

/// 热力图骨架图
private struct MainHeatmapSkeletonView: View {
    var body: some View {
        // 热力图
        HStack {
            // 图例
            VStack(spacing: 30) {
                ForEach(0 ..< 3) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("skeleton-background"))
                        .frame(width: 66, height: 20)
                }
            }
            .frame(width: 98)
            
            // 热力图
            HStack {
                LazyVGrid(columns: heatmapColumns, spacing: 13) {
                    ForEach(0 ..< 31) { _ in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#eeeeee"))
                            .frame(width: 26, height: 26)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
    }
}

/// 步行记录列表每一项
private struct MainRouteListItem: View {
    /// 每一项
    var item: GetUserRouteHistoryType.GetUserRouteHistoryRoute
    /// 用户 id
    var user_id: String
    
    var body: some View {
        NavigationLink(destination: RouteDetailView(list_id: item.list_id, user_id: user_id)) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: item.mood_color ?? "#FFCC94"))
                    .frame(height: 116)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.3))
                            .overlay {
                                RoundedRectangle(cornerRadius: 200)
                                    .fill(Color(hex: item.mood_color ?? "#FFCC94"))
                                    .frame(width: 400, height: 370)
                                    .offset(y: -170)
                                    .rotationEffect(.degrees(13))
                            }
                            .clipped()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                HStack(alignment: .top) {
                    Spacer()
               
                    VStack(alignment: .trailing) {
                        // 地点数量
                        Text("地点×\(item.count)")
                            .foregroundStyle(.white)
                            .font(.system(size: 18))
                            .padding(.top, 28)
                            .bold()
               
                        Spacer()
               
                        // 时间
                        Text("\(convertToDateOnly(from: item.create_at)!)")
                            .foregroundStyle(.white)
                            .font(.system(size: 15))
                            .padding(.bottom, 10)
                    }
                    .padding(.trailing, 16)
                }
                .overlay(alignment: .topLeading) {
                    if let travel_type = item.travel_type,
                       let travelType = TravelTypeKey.getTravelType(from: travel_type),
                       let trainIcon = travelTypes.first(where: { $0.key == travelType })?.icon
                    {
                        Image(systemName: trainIcon)
                            .font(.system(size: 75))
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.top, 6)
                            .offset(x: -16)
                    }
                }
                .clipped()
            }
        }
    }
}

/// 月份选择
private struct SelectmonthItem {
    var title: String
    var key: Int
}

#Preview {
    MainView(user_id: "U131995175454824711531011225172573302849")
        .environmentObject(MainData())
}
