//
//  NimbleSurveyApp.swift
//  NimbleSurvey
//
//  Created by Kazu on 31/7/24.
//

import SwiftUI
import SwiftfulRouting
import KeychainSwift

final class KeychainManager {
    static let sharedInstance = KeychainManager()
    
    private let keychain: KeychainSwift
    
    init() {
        keychain = KeychainSwift()
        keychain.synchronizable = true
    }
    
    func set(_ value: String, forKey key: String) {
        keychain.set(value, forKey: key)
    }
    
    func get(_ key: String) -> String? {
        return keychain.get(key)
    }
    
    func remove(_ key: String) {
        keychain.delete(key)
    }
}

@main
struct NimbleSurveyApp: App {
    var body: some Scene {
        WindowGroup {
            RouterView { router in
                SignInView(viewModel: SignInViewModel(router: router))
            }
        }
    }
}
