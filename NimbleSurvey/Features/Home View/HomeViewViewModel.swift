//
//  HomeViewViewModel.swift
//  NimbleSurvey
//
//  Created by Kazu on 4/8/24.
//

import Foundation

class HomeViewViewModel: ObservableObject {
    
    @Published var surveys: [SurveyData] = []
    @Published var currentPageIndex = 1
    
    private let surveyService: SurveyService
    
    @Published var isLoading: Bool = true
    @Published var isShowingError: Bool = false
    @Published var page = 1
    
    var canLoadNextPage: Bool = false
    let pageSize = 10
    
    
    var errorMessage: String = ""
    
    init() {
        self.surveyService = SurveyService()
    }
    
    deinit {
       // tasks.forEach({ $0.cancel() })
    }
    
    @MainActor
    func getSurveyList() async {
        do {
            if page == 1 {
                surveys.removeAll()
            }
            
            let model: SurveyListModel = try await surveyService.getSurveyList(page: page, size: pageSize)
            surveys.append(contentsOf: model.data)
            
            canLoadNextPage = page < model.meta.pages
            
            // save local
            
        } catch {
            switch error {
            case APIError.serverError:
                errorMessage = "Please try again later!"
            case APIError.clientError(let message):
                errorMessage = message
            default: break
            }
            isShowingError = true
            print(error.localizedDescription)
        }
    }
    
}
