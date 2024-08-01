//
//  ViewExtension.swift
//  NimbleSurvey
//
//  Created by Kazu on 31/7/24.
//

import SwiftUI

// MARK: - View

extension View {
    func customBackButton() -> some View {
        modifier(CustomBackButton())
    }
}
