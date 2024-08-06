//
//  SurveyService.swift
//  NimbleSurvey
//
//  Created by Kazu on 4/8/24.
//

import Foundation

protocol SurveyServiceProtocol {
    func getSurveyList(page: Int, size: Int) async throws -> SurveyListModel
}

//class SurveyService: SurveyServiceProtocol {
//    var apiClient: any APIClient
//    
//    init(apiClient: any APIClient = URLSessionAPIClient<SurveyEndpoint>()) {
//        self.apiClient = apiClient
//    }
//    
//    func getSurveyList(page: Int, size: Int) async throws -> SurveyListModel {
//        return try await apiClient.request(.getSurveyList(pageNumber: page, pageSize: size))
//    }
//}
class SurveyService<Client: APIClient>: SurveyServiceProtocol where Client.EndpointType == SurveyEndpoint {
    var apiClient: Client
    
    init(apiClient: Client) {
        self.apiClient = apiClient
    }
    
    func getSurveyList(page: Int, size: Int) async throws -> SurveyListModel {
        return try await apiClient.request(.getSurveyList(pageNumber: page, pageSize: size))
    }
}
