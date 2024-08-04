//
//  ResponseModel.swift
//  NimbleSurvey
//
//  Created by Kazu on 3/8/24.
//

import Foundation



// MARK: - SignInResponse
struct SignInResponse: Codable {
    let data: DataClass
}

struct DataClass: Codable {
    let id, type: String
    let attributes: Attributes
}

// MARK: - Attributes
struct Attributes: Codable {
    let accessToken, tokenType: String
    let expiresIn: Int
    let refreshToken: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case createdAt = "created_at"
    }
}

// MARK: - ForgotResponse
struct ForgotResponse: Codable {
    let meta: Meta
}

struct Meta: Codable {
    let message: String
}
