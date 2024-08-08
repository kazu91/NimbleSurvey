//
//  Environment.swift
//  NimbleSurvey
//
//  Created by Kazu on 9/8/24.
//

import Foundation

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
