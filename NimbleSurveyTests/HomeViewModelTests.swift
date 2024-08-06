//
//  SurveyServiceTests.swift
//  NimbleSurveyTests
//
//  Created by Kazu on 6/8/24.
//

import Testing
import Foundation
import SwiftData

struct HomeViewModelTests {
    var mockAPIClient: MockAPIClient
    var surveyService: SurveyService<MockAPIClient>
    let schema = Schema([
        SurveyData.self,
        Survey.self
    ])
    
    init() {
        mockAPIClient = MockAPIClient()
        surveyService = SurveyService(apiClient: mockAPIClient)
    }
    
    func getSurveyFromJson() throws -> SurveyListModel  {
        // Locate the JSON file in the test bundle
        guard let url = BundleClass().bundle.url(forResource: "survey_json", withExtension: "json") else {
            Issue.record("Missing file: survey_json.json")
            return SurveyListModel(data: [], meta: SurveyMetaData(page: 0, pages: 0, pageSize: 00, records: 0))
        }
        
        // Load data from the file
        let data = try Data(contentsOf: url)
        
        // Decode the JSON data
        let decoder = JSONDecoder()
        let surveyListModel = try decoder.decode(SurveyListModel.self, from: data)
        
        return surveyListModel
    }
    
    @Test func testSurveyListModelDecodingFromFile() throws {
        
        do {
            let surveyListModel = try getSurveyFromJson()
            
            if surveyListModel.data.count == 0  {
                Issue.record("Cannot retrieve model from json")
                return
            }
            
            #expect(surveyListModel.data.count == 2)
            #expect(surveyListModel.data[0].id == "1")
            #expect(surveyListModel.data[0].attributes.title == "Customer Satisfaction Survey")
            #expect(surveyListModel.meta.page == 1)
            #expect(surveyListModel.meta.records == 2)
        } catch {
            Issue.record("Error occured when decoding data from json")
        }
        
    }
    
    @Test func testGetSurveyListSuccess() async {
        do {
            
            let modelContent = try ModelContext(ModelContainer(for: schema))
            let viewModel = HomeViewViewModel(
                networkMonitor: NetworkMonitor(),
                modelContent: modelContent,
                surveyService: surveyService
            )
            
            let surveyListModel = try getSurveyFromJson()
            mockAPIClient.result = .success(surveyListModel)
            
            await viewModel.getSurveyListFromServer()
            
            #expect(viewModel.surveys.count == 2, "Expected 2 survey in the list")
            #expect(viewModel.surveys[0].attributes.title == "Customer Satisfaction Survey", "Expected Customer Satisfaction Survey")
        } catch {
            Issue.record("Expected no error but got \(error)")
        }
    }
    
    
    @Test func testGetSurveyListFailure() async {
        var errorMessage = ""
        do {
            mockAPIClient.result = .failure(.serverError)
            
            let modelContent = try ModelContext(ModelContainer(for: schema))
            let viewModel = HomeViewViewModel(
                networkMonitor: NetworkMonitor(),
                modelContent: modelContent,
                surveyService: surveyService
            )
            await viewModel.getSurveyListFromServer()
            
            errorMessage = viewModel.errorMessage
        } catch {
            // Then
            Issue.record("Error from model context")
        }
        
        #expect(errorMessage == "Please try again later!")
        
    }
    
    @Test func testGetSurveyListClientFailure() async {
        var errorMessage = ""
        do {
            mockAPIClient.result = .failure(.clientError(message: "Test Client Message"))

            let modelContent = try ModelContext(ModelContainer(for: schema))
            let viewModel = HomeViewViewModel(
                networkMonitor: NetworkMonitor(),
                modelContent: modelContent,
                surveyService: surveyService
            )
            
            await viewModel.getSurveyListFromServer()
            
            errorMessage = viewModel.errorMessage
        } catch {
            Issue.record("Error from model context")
        }
        #expect(errorMessage == "Test Client Message")
        
    }
    
    @Test func testGetSurveyListNoInternetFailure() async {
        var errorMessage = ""
        do {
            mockAPIClient.result = .failure(.noInternetConnection)

            let modelContent = try ModelContext(ModelContainer(for: schema))
            let viewModel = HomeViewViewModel(
                networkMonitor: NetworkMonitor(),
                modelContent: modelContent,
                surveyService: surveyService
            )
            
            await viewModel.getSurveyListFromServer()
            errorMessage = viewModel.errorMessage
        } catch {
            Issue.record("Error from model context")
        }
        #expect(errorMessage == "No Internet Connection")
    }
}
