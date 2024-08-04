//
//  ViewExtension.swift
//  NimbleSurvey
//
//  Created by Kazu on 31/7/24.
//

import SwiftUI
import Lottie

// MARK: - View

extension View {
    func customBackButton() -> some View {
        modifier(CustomBackButton())
    }
}
