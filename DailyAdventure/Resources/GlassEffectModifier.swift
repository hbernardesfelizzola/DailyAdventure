//
//  GlassEffectModifier.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import SwiftUI

// MARK: - Glass Effect
struct GlassEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        } else {
            content
        }
    }
}

struct GlassEffectShapeModifier: ViewModifier {
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(in: RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            content
        }
    }
}

struct GlassEffectCircleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(in: Circle())
        } else {
            content
        }
    }
}

struct GlassEffectCapsuleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(in: Capsule())
        } else {
            content
        }
    }
}

extension View {
    func glassEffectIfAvailable() -> some View {
        modifier(GlassEffectModifier())
    }
    
    func glassEffectIfAvailable(cornerRadius: CGFloat) -> some View {
        modifier(GlassEffectShapeModifier(cornerRadius: cornerRadius))
    }
    
    func glassEffectCircleIfAvailable() -> some View {
        modifier(GlassEffectCircleModifier())
    }
    
    func glassEffectCapsuleIfAvailable() -> some View {
        modifier(GlassEffectCapsuleModifier())
    }
}

// MARK: - Placeholder
extension View {
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - ScrollEdgeEffectStyle
struct ScrollEdgeEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .scrollEdgeEffectStyle(.soft, for: .top)
        } else {
            content
        }
    }
}

extension View {
    func scrollEdgeEffectIfAvailable() -> some View {
        modifier(ScrollEdgeEffectModifier())
    }
}
