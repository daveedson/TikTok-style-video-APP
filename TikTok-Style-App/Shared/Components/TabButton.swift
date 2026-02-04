//
//  TabButton.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

 struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))

               
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 30, height: 2)
                    .opacity(isSelected ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
    }
}


