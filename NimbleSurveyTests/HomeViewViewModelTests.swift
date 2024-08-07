//
//  HomeViewViewModelTests.swift
//  NimbleSurveyTests
//
//  Created by Kazu on 6/8/24.
//

import XCTest
import Foundation
import SwiftData

class HomeViewViewModelTests: XCTestCase {
    var mockAPIClient: MockAPIClient!
    var surveyService: SurveyService<MockAPIClient>!
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SurveyData.self,
            Survey.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        surveyService = SurveyService(apiClient: mockAPIClient)
    }
    
    override func tearDown() {
        mockAPIClient = nil
        surveyService = nil
        super.tearDown()
    }
    
    func getSurveyFromJson() throws -> SurveyListModel?  {
        // Locate the JSON file in the test bundle
        guard let url = BundleClass().bundle.url(forResource: "survey_json", withExtension: "json") else {
            XCTFail("Missing file: survey_json.json")
            return nil
        }
        
        // Load data from the file
        let data = try Data(contentsOf: url)
        
        // Decode the JSON data
        let decoder = JSONDecoder()
        let surveyListModel = try decoder.decode(SurveyListModel.self, from: data)
        
        
        
        return surveyListModel
    }
    
    func testSurveyListModelDecodingFromFile() throws {
        do {
            if let surveyListModel = try getSurveyFromJson() {
                
                XCTAssertFalse(surveyListModel.data.isEmpty, "Cannot retrieve model from json")
                XCTAssertEqual(surveyListModel.data.count, 2)
                XCTAssertEqual(surveyListModel.data[0].id, "1")
                XCTAssertEqual(surveyListModel.meta.page, 1)
                XCTAssertEqual(surveyListModel.meta.records, 2)
            } else {
                XCTFail("Error occurred when getting data from json")
            }
        } catch {
            XCTFail("Error occurred when decoding data from json: \(error)")
        }
    }
    
    func testGetSurveyListSuccess() async throws {
        
        let modelContent = ModelContext(sharedModelContainer)
        
        let viewModel = HomeViewViewModel(
            networkMonitor: NetworkMonitor(),
            modelContent: modelContent,
            surveyService: surveyService
        )
        
        if let surveyListModel = try getSurveyFromJson() {
            
            mockAPIClient.result = .success(surveyListModel)
            
            await viewModel.getSurveyListFromServer()
            
            XCTAssertEqual(viewModel.surveys.count, 2, "Expected 2 surveys in the list")
            XCTAssertEqual(viewModel.surveys[0].attributes.title, "Customer Satisfaction Survey", "Expected Customer Satisfaction Survey")
            XCTAssertEqual(viewModel.surveys[0].attributes.secondTitle, "We value your feedback!", "Expected We value your feedback!")
            
        } else {
            XCTFail("Error occurred when decoding data from json")
        }
        
    }
    
    func testGetSurveyListFailure() async {
        mockAPIClient.result = .failure(.serverError)
        
        let modelContent = ModelContext(sharedModelContainer)
        let viewModel = HomeViewViewModel(
            networkMonitor: NetworkMonitor(),
            modelContent: modelContent,
            surveyService: surveyService
        )
        
        await viewModel.getSurveyListFromServer()
        let errorMessage = viewModel.errorMessage
        
        XCTAssertEqual(errorMessage, "Please try again later!")
        
    }
    
    func testGetSurveyListClientFailure() async {
        mockAPIClient.result = .failure(.clientError(message: "Test Client Message"))
        
        let modelContent = ModelContext(sharedModelContainer)
        let viewModel = HomeViewViewModel(
            networkMonitor: NetworkMonitor(),
            modelContent: modelContent,
            surveyService: surveyService
        )
        
        await viewModel.getSurveyListFromServer()
        let errorMessage = viewModel.errorMessage
        
        XCTAssertEqual(errorMessage, "Test Client Message")
    }
    
    func testGetSurveyListNoInternetFailure() async {
        mockAPIClient.result = .failure(.noInternetConnection)
        let modelContent = ModelContext(sharedModelContainer)
        let viewModel = HomeViewViewModel(
            networkMonitor: NetworkMonitor(),
            modelContent: modelContent,
            surveyService: surveyService
        )
        
        await viewModel.getSurveyListFromServer()
        let errorMessage = viewModel.errorMessage
        
        XCTAssertEqual(errorMessage, "No Internet Connection")
        
    }
}
