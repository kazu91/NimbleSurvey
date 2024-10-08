//
//  UserService.swift
//  NimbleSurvey
//
//  Created by Kazu on 3/8/24.
//

import Foundation

protocol UserServiceProtocol {
    func signInWithEmail(email: String, password: String) async throws -> SignInResponse
    func getUserProfile() async throws -> UserModel
    func refeshToken() async throws -> SignInResponse
    func logout() async throws -> Empty
    func forgotPassword(email: String) async throws -> ForgotResponse
}

class UserService: UserServiceProtocol {
    let apiClient = URLSessionAPIClient<UserEndpoint>()
    
    func getUserProfile() async throws -> UserModel {
        return try await apiClient.request(.getUserProfile)

    }
    
    func refeshToken() async throws -> SignInResponse {
        return try await apiClient.request(.refeshToken)

    }
    
    func logout() async throws -> Empty {
        return try await apiClient.request(.logout)

    }
    
    func forgotPassword(email: String) async throws -> ForgotResponse {
        return try await apiClient.request(.forgotPassword(email: email))
    }
    
    func signInWithEmail(email: String, password: String) async throws -> SignInResponse {
        return try await apiClient.request(.signInWithEmail(email: email, password: password))
    }
}
