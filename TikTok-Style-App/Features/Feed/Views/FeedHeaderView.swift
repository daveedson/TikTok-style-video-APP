//
//  FeedHeaderView.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

enum FeedTab: String, CaseIterable {
    case following = "Following"
    case forYou = "For You"
}

struct FeedHeaderView: View {
    @Binding var selectedTab: FeedTab

    var body: some View {
        HStack {
           
            Text("TakTik")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Spacer()

          
            HStack(spacing: 20) {
                ForEach(FeedTab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.rawValue,
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 40)
    }
}




#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        FeedHeaderView(selectedTab: .constant(.forYou))
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 50)
    }
}
