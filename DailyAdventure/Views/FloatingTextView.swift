//
//  FloatingTextView.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

struct FloatingTextView: View {
    let text: String
    let color: Color
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, Theme.Spacing.small)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    offset = -60
                    opacity = 0
                }
            }
    }
}