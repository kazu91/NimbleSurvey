//
//  UserModel.swift
//  NimbleSurvey
//
//  Created by Kazu on 4/8/24.
//

import Foundation

struct UserModel: Codable {
    let data: UserData
}

// MARK: - DataClass
struct UserData: Codable {
    let id, type: String
    let attributes: UserAttributes
}

// MARK: - Attributes
struct UserAttributes: Codable {
    let email, name: String
    let avatarURL: String

    enum CodingKeys: String, CodingKey {
        case email, name
        case avatarURL = "avatar_url"
    }
}
