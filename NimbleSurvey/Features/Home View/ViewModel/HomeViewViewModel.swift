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
    
    var modelContext: ModelContext?
    //let surveyService: SurveyService<URLSessionAPIClient<SurveyEndpoint>>
    
    let surveyService: SurveyServiceProtocol
    
    @Published var isFirstTimeLoading: Bool = true
    @Published var isLoading: Bool = false
    @Published var isShowingError: Bool = false
    @Published var page = 1
    @Published var needToSignIn = false
    var canLoadNextPage: Bool = false
    let pageSize = 10
    
    // current page of the highlighted capsule
    // not page# of pagination
    var currentIndexPage: Int {
        let pageIndex = Double(currentPageIndex)
        return (pageIndex / Double(pageSize)).rounded(.up).toInt() ?? 0
    }
    // current index on current page
    var pagingCurrentIndex: Int {
        currentIndexPage == 1 ? currentPageIndex :
        currentPageIndex - (currentIndexPage - 1) * pageSize
    }
    
    // current visible capsule, max 10 per page
    var capsuleCount: Int {
        let result = surveys.count - (currentIndexPage - 1) * pageSize
        if result > 10 {
            return 10
        }
        return result
    }
    
    
    var errorMessage: String = ""
    
    //MARK: - Initialize
    init(networkMonitor: NetworkMonitor,
         modelContent: ModelContext?,
         surveyService: SurveyServiceProtocol = SurveyService(apiClient: URLSessionAPIClient<SurveyEndpoint>())
    ) {
        self.surveyService = surveyService
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
                isShowingError = true
            case APIError.clientError(let message):
                errorMessage = message
                isShowingError = true
            case APIError.accessTokenRevoked:
                needToSignIn = true
                errorMessage = "Need to sign in again"
            case APIError.noInternetConnection:
                errorMessage = "No Internet Connection"
                isShowingError = true
            default: break
            }
           
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
        guard let modelContext = modelContext else {
            return
        }
        for survey in surveys {
            modelContext.insert(survey)
        }
    }
    
    @MainActor
    func fetchSurveys() {
        guard let modelContext = modelContext else {
            return
        }
        do {
            let descriptor = FetchDescriptor<SurveyData>(sortBy: [SortDescriptor(\.attributes.createdAt)])
            surveys = try modelContext.fetch(descriptor)
        } catch {
            print("Fail get survey")
        }
    }
    
    func removeAllSurveyFromLocal() {
        do {
            try modelContext?.delete(model: SurveyData.self)
        } catch {
            print("Failed to delete all surveys.")
        }
    }
}
