//
//  MockUserService.swift
//  NimbleSurveyTests
//
//  Created by Kazu on 6/8/24.
//

import Foundation

class MockAPIClient: APIClient {
    typealias EndpointType = SurveyEndpoint
    
    var result: Result<SurveyListModel, APIError>?
    
    func request<T: Decodable>(_ endpoint: EndpointType) async throws -> T {
        switch result {
        case .success(let data as T):
            return data
        case .failure(let error):
            throw error
        default:
            fatalError("MockAPIClient result is not set or invalid type")
        }
    }
}

