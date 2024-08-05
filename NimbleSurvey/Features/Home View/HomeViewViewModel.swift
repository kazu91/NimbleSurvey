//
//  HomeViewViewModel.swift
//  NimbleSurvey
//
//  Created by Kazu on 4/8/24.
//

import SwiftData
import Foundation

class HomeViewViewModel: ObservableObject {
    
    @Published var surveys: [SurveyData] = []
    @Published var currentPageIndex = 1
    @Published var networkMonitor: NetworkMonitor
    
    var modelContext: ModelContext
    private let surveyService: SurveyService
    
    @Published var isFirstTimeLoading: Bool = true
    @Published var isLoading: Bool = false
    @Published var isShowingError: Bool = false
    @Published var page = 1
    
    var canLoadNextPage: Bool = false
    let pageSize = 10
    
    
    var errorMessage: String = ""
    
    //MARK: - Initialize
    init(networkMonitor: NetworkMonitor, modelContent: ModelContext) {
        self.surveyService = SurveyService()
        self.networkMonitor = networkMonitor
        self.modelContext = modelContent
    }
    
    deinit {
       // tasks.forEach({ $0.cancel() })
    }
    
    //MARK: - Functions
    
    @MainActor
    func getSurveyListFromServer() async {
        
        do {
            
            let model: SurveyListModel = try await surveyService.getSurveyList(page: page, size: pageSize)
            
            if page == 1 {
                surveys.removeAll()
            }
            
            surveys.append(contentsOf: model.data)
            
            canLoadNextPage = page < model.meta.pages
            
            // save to local
            //updateOrAddNewSurvey(remoteSurvey: model.data)
            
            if page == 1 {
                removeAllSurveyFromLocal()
            }
            addNewSurveys(surveys: model.data)
            
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
    
    @MainActor
    func refreshView() async {
        isLoading = true
        currentPageIndex = 1
        page = 1
        await getSurveyListFromServer()
        isLoading = false
    }
    
    //MARK: - Local storage
    
    ///Encountering with error  Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'The specified URI is not a valid Core Data URI: x-coredata:///SurveyData/A35633F4-B910-45DA-A469-3A0A91B7287E'
    /// Xcode 16 Beta
    /// https://forums.developer.apple.com/forums/thread/756769
    /// i'll try to work around this by remove and then add new array of data
//    func updateOrAddNewSurvey(remoteSurvey: [SurveyData]) {
//        do {
//            for survey in remoteSurvey {
//                if let localSurvey = modelContext.model(for: survey.id) as? SurveyData {
//                    localSurvey.attributes = survey.attributes
//                }
//            }
//            try modelContext.save()
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
    
    func addNewSurveys(surveys: [SurveyData]) {
        for survey in surveys {
            modelContext.insert(survey)
        }
    }
    
    @MainActor
    func fetchSurveys() {
        do {
            let descriptor = FetchDescriptor<SurveyData>(sortBy: [SortDescriptor(\.attributes.createdAt)])
            surveys = try modelContext.fetch(descriptor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeAllSurveyFromLocal() {
        do {
            try modelContext.delete(model: SurveyData.self)
        } catch {
            print("Failed to delete all surveys.")
        }
    }
}
