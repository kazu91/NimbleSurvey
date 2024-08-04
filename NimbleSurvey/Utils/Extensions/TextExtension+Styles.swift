//
//  TextExtension.swift
//  NimbleSurvey
//
//  Created by Kazu on 2/8/24.
//

import SwiftUI

protocol TextStyle: ViewModifier {}

extension Text {
    func textStyle<T: TextStyle>(_ style: T) -> some View {
        modifier(style)
    }
}

// MARK: - Text Styles

struct LargeTitleTextStyle: TextStyle {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 34, weight: .bold))
            .foregroundColor(.white)
    }
}

struct Display2TextStyle: TextStyle {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.white)
    }
}

struct ParagraphTextStyle: TextStyle {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.white.opacity(0.8))
    }
}

struct MediumBoldTextStyle: TextStyle {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
    }
}

struct MediumLinkTextStyle: TextStyle {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .regular))
            .foregroundColor(.white.opacity(0.5))
    }
}

struct SmallTagTextStyle: TextStyle {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white.opacity(0.5))
    }
}
