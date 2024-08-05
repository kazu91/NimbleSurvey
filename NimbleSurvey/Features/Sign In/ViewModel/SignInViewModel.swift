//
//  SignInViewModel.swift
//  NimbleSurvey
//
//  Created by Kazu on 3/8/24.
//

import SwiftUI
import Combine
import SwiftfulRouting
import KeychainSwift
import SwiftData

class SignInViewModel: ObservableObject {
    private let router: AnyRouter
    private let userService: UserService
    private let networkMonitor: NetworkMonitor
    var modelContext: ModelContext?
    private var tasks: [Task<Void, Never>] = []
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isLoading: Bool = false
    @Published var isShowingError: Bool = false

    var errorMessage: String = ""
    
    init(router: AnyRouter, networkMonitor: NetworkMonitor) {
        self.router = router
        self.userService = UserService()
        self.networkMonitor = networkMonitor
    }
    
    deinit {
        tasks.forEach({ $0.cancel() })
    }
    
    var isNotValid: Bool {
        return (self.email.isEmpty || self.password.isEmpty)
    }
    
    @MainActor
    func signIn() {
        if !email.isValidEmail  {
            isShowingError = true
            errorMessage = "Wrong email format!"
            return
        }
        let task = Task(priority: .high) {
            isLoading = true
            defer { isLoading = false }
            do {
                let signInResponse: SignInResponse = try await userService.apiClient.request(.signInWithEmail(email: email, password: password))
                
                KeychainManager.sharedInstance.set(signInResponse.data.attributes.accessToken, forKey: Constant.KeychainKey.accessToken)
                KeychainManager.sharedInstance.set(signInResponse.data.attributes.refreshToken, forKey: Constant.KeychainKey.refreshToken)
                
                password = ""
                guard let modelContext = modelContext else {
                    return
                }
                router.showScreen(.push) { _ in
                    HomeView(
                        userViewModel: UserViewModel(userService: UserService()),
                        homeViewModel: HomeViewViewModel(
                            networkMonitor: self.networkMonitor,
                            modelContent: modelContext
                        )
                    )
                }
                
            } catch {
                switch error {
                case APIError.serverError:
                    errorMessage = "Please try again later!"
                case APIError.clientError:
                    errorMessage = "Wrong email or password"
                default: break
                }
                isShowingError = true
                print(error.localizedDescription)
            }
        }
        
        tasks.append(task)
       
    }
    
}
