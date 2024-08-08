//
//  Environment.swift
//  NimbleSurvey
//
//  Created by Kazu on 9/8/24.
//

import Foundation

// I accidentally pushed all my code on *[Feature] Supporting multiple application environments*
///https://github.com/kazu91/NimbleSurvey/issues/10
// into main branch, i'll explain my approach in PR later
enum AppEnvironment: String {
    case debugDevelopment = "Debug Development"
    case releaseDevelopment = "Release Development"

    case debugProduction = "Debug Production"
    case releaseProduction = "Release Production"
}

class BuildConfiguration {
    static let shared = BuildConfiguration()
    
    var environment: AppEnvironment
    
    var envSecret: String {
        switch environment {
        case .debugDevelopment, .releaseDevelopment:
           return Bundle.main.object(forInfoDictionaryKey: "DEV_SECRET") as? String ?? ""
        case .debugProduction, .releaseProduction:
            return Bundle.main.object(forInfoDictionaryKey: "PROD_SECRET") as? String ?? ""
        }
    }
    
    var envID: String {
        switch environment {
        case .debugDevelopment, .releaseDevelopment:
           return Bundle.main.object(forInfoDictionaryKey: "DEV_ID") as? String ?? ""
        case .debugProduction, .releaseProduction:
            return Bundle.main.object(forInfoDictionaryKey: "PROD_ID") as? String ?? ""
        }
    }
    
    init() {
        let currentConfiguration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as! String
        environment = AppEnvironment(rawValue: currentConfiguration)!
    }
}
