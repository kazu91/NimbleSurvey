//
//  UserViewModel.swift
//  NimbleSurvey
//
//  Created by Kazu on 4/8/24.
//

import Foundation

class UserViewModel: ObservableObject {
    
    @Published var user: UserModel = UserModel(data: nil)
    @Published var isShowingError = false
    private let userService: UserService
    
    var message = ""
    
    
    init(userService: UserService) {
        self.userService = userService
    }

    deinit {
        // tasks.forEach({ $0.cancel() })
    }
    
    
    // MARK: - Functions
    @MainActor
    func getUserInfo() async {
        
        do {
            let user: UserModel = try await userService.apiClient.request(.getUserProfile)
            
            self.user = user
        } catch {
            switch error {
            case APIError.accessTokenRevoked:
                // need log out
                break
            default:
                message = error.localizedDescription
            }
            isShowingError = true
          
        }
    }
    
    func logout() async {
        defer {
            KeychainManager.sharedInstance.remove(Constant.KeychainKey.accessToken)
            KeychainManager.sharedInstance.remove(Constant.KeychainKey.refreshToken)
        }
        
        do {
            let _: Empty = try await userService.apiClient.request(.logout)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func forgetPassword(email: String) async {
        do {
            if !email.isValidEmail {
                message = "Invalid email format."
                isShowingError = true
                return
            }
            let response: ForgotResponse = try await userService.apiClient.request(.forgotPassword(email: email))
            message = response.meta.message
        } catch {
            isShowingError = true
            message = error.localizedDescription
        }
    }
    
    @MainActor
    func refreshAccessToken() async {
        do {
            let refresh: SignInResponse  = try await userService.apiClient.request(.refeshToken)
            
            KeychainManager.sharedInstance.set(refresh.data.attributes.accessToken, forKey: Constant.KeychainKey.accessToken)
            KeychainManager.sharedInstance.set(refresh.data.attributes.refreshToken, forKey: Constant.KeychainKey.refreshToken)
            
        } catch {
            isShowingError = true
            message = error.localizedDescription
        }
    }
}
