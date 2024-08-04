//
//  HomeViewViewModel.swift
//  NimbleSurvey
//
//  Created by Kazu on 4/8/24.
//

import Foundation

class HomeViewViewModel: ObservableObject {
    
    @Published var surveys: [Survey] = []
    
}
