//
//  NimbleSurveyApp.swift
//  NimbleSurvey
//
//  Created by Kazu on 31/7/24.
//

import SwiftUI
import SwiftfulRouting
import KeychainSwift
import SwiftData



@main
struct NimbleSurveyApp: App {
    @State private var networkMonitor = NetworkMonitor()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SurveyData.self,
            Survey.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RouterView { router in
                SignInView(viewModel: SignInViewModel(router: router, networkMonitor: networkMonitor))
            }
            .environment(networkMonitor)
            .modelContainer(sharedModelContainer)
        }
    }
}
