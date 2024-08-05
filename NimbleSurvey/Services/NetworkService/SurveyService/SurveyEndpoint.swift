//
//  SurveyEndpoint.swift
//  NimbleSurvey
//
//  Created by Kazu on 4/8/24.
//

import Foundation

enum SurveyEndpoint: APIEndpoint {
    case getSurveyList(pageNumber: Int, pageSize: Int)
    
    var baseURL: URL {
        return URL(string: "https://survey-api.nimblehq.co/api/v1")!
    }
    
    var path: String {
        switch self {
        case .getSurveyList:
            return "/surveys"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getSurveyList:
            return .get
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .getSurveyList:
            return ["Authorization": "Bearer \(KeychainManager.sharedInstance.get(Constant.KeychainKey.accessToken) ?? "")"]
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .getSurveyList(let page, let size):
            return [
                "page[number]":page,
                "page[size]": size
            ]
        }
    }
}
