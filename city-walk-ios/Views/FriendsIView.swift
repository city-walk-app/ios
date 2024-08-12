//
//  FriendsIView.swift
//  city-walk-ios
//
//  Created by Tyh2001 on 2024/7/15.
//

import SwiftUI

struct FriendsIView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("朋友列表")
                }
            }
            .navigationTitle("朋友列表")
        }
    }
}

#Preview {
    FriendsIView()
}
