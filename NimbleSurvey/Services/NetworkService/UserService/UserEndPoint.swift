//
//  UserEndPoint.swift
//  NimbleSurvey
//
//  Created by Kazu on 3/8/24.
//

import Foundation
import KeychainSwift


enum UserEndpoint: APIEndpoint {
    case getUserProfile
    case signInWithEmail(email: String, password: String)
    case refeshToken
    case logout
    case forgotPassword
    
    var baseURL: URL {
        switch self {
        case .forgotPassword:
            return URL(string: "https://survey-api.nimblehq.co/api/v1")!
        default:
            return URL(string: "https://survey-api.nimblehq.co/api/v1/oauth")!
        }
        
    }
    
    var path: String {
        switch self {
        case .getUserProfile:
            return "/me"
        case .signInWithEmail:
            return "/token"
        case .refeshToken:
            return "/token"
        case .logout:
            return "/token"
        case .forgotPassword:
            return "/passwords"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getUserProfile:
            return .get
        case .signInWithEmail, .refeshToken, .logout, .forgotPassword:
            return .post
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .getUserProfile:
            return ["Authorization": "Bearer \(KeychainManager.sharedInstance.get(Constant.KeychainKey.accessToken) ?? "")"]
            
        case .signInWithEmail, .forgotPassword, .logout, .refeshToken:
            return [:]
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .signInWithEmail(let email, let password):
            return [ "grant_type": "password",
                     "email": email,
                     "password": password,
                     "client_id": Constant.SecretKey.key,
                     "client_secret": Constant.SecretKey.secret
            ]
        case .getUserProfile:
            return [:]
        case .refeshToken:
            return["grant_type": "refresh_token",
                   "refresh_token": KeychainManager.sharedInstance.get(Constant.KeychainKey.refreshToken) ?? "",
                   "client_id": Constant.SecretKey.key,
                   "client_secret": Constant.SecretKey.secret
            ]
        case .logout:
            return ["token": (KeychainManager.sharedInstance.get(Constant.KeychainKey.accessToken) ?? ""),
                    "client_id": Constant.SecretKey.key,
                    "client_secret": Constant.SecretKey.secret
            ]
        case .forgotPassword:
            return [ "user": [
                "email": "your_email@example.com"
            ],
                     "client_id": Constant.SecretKey.key,
                     "client_secret": Constant.SecretKey.secret
            ]
        }
    }
    
}
