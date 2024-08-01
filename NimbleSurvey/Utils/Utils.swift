//
//  Utils.swift
//  NimbleSurvey
//
//  Created by Kazu on 31/7/24.
//

import Foundation
import SwiftUI

// MARK: - Key
struct Key {
    
    struct FontName {
        static let Neuzeit = "NeuzeitSLTStd-Book"
    }
}

// MARK: - View Modifiers

struct TextFieldModifier: ViewModifier {
    let fontSize: CGFloat
    let backgroundColor: Color
    let textColor: Color
    let height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: fontSize))
            .foregroundColor(textColor)
            .padding(.leading)
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: height/2)
                    .strokeBorder(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 0.3))
                
            )
            .background(RoundedRectangle(cornerRadius: height/2).fill(backgroundColor))
    }
}


struct CustomBackButton: ViewModifier {
    
    @Environment(\.presentationMode) var presentationMode

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                }
            }
    }
}

