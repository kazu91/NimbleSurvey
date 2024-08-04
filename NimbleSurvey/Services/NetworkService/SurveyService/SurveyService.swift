//
//  SurveyService.swift
//  NimbleSurvey
//
//  Created by Kazu on 4/8/24.
//

import Foundation

protocol SurveyServiceProtocol {
    func getSurveyList(page: Int, size: Int) async throws -> Survey
}

class SurveyService: SurveyServiceProtocol {
    let apiClient = URLSessionAPIClient<SurveyEndpoint>()
    
    func getSurveyList(page: Int, size: Int) async throws -> Survey {
        return try await apiClient.request(.getSurveyList(pageNumber: page, pageSize: size))
        
    }
}
