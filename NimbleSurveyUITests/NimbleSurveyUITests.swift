//
//  NimbleSurveyUITests.swift
//  NimbleSurveyUITests
//
//  Created by Kazu on 31/7/24.
//

import XCTest

final class NimbleSurveyUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        let app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLoginFlow() {
        let app = XCUIApplication()
        
        let todayStaticText = app.staticTexts["Today"]
        let passwordSecureTextField = app.secureTextFields["Password"]
        
        let element = app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        let surveyListView = element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        
        
        let emailTextField = app.textFields["Email"]
        
        let logoutButton = app.buttons["Logout"]
        let signInButton = app.buttons["Sign In"]
        
        let exists = NSPredicate(format: "exists == true")
        // Check if logged in
        
        
        let loginScreenExpectation = XCTNSPredicateExpectation(predicate: exists, object: emailTextField)
        let homeScreenExpectation = XCTNSPredicateExpectation(predicate: exists, object: todayStaticText)
        let logOutButtonExpectation = XCTNSPredicateExpectation(predicate: exists, object: logoutButton)
        
        let firstHomeResult = XCTWaiter().wait(for: [homeScreenExpectation], timeout: 30)
        let firstLoginResult = XCTWaiter().wait(for: [loginScreenExpectation], timeout: 10)
        
        if firstHomeResult == .completed || firstLoginResult == .completed {
            // loggin, need logout
            if todayStaticText.exists {
                
                XCTAssertTrue(todayStaticText.exists, "Home screen should be displayed.")
                
                XCTAssertTrue(surveyListView.exists, "List Survey exist")
                
                // surveyListView.swipeRight()
                
                todayStaticText.tap()
                sleep(2)
                if !logoutButton.exists {
                    todayStaticText.tap()
                }
                                
                let logoutButtonWaiter = XCTWaiter().wait(for: [logOutButtonExpectation], timeout: 10)
                
                XCTAssertEqual(logoutButtonWaiter, .completed, "Log out button should appear within 30 seconds")
                
                if (logoutButtonWaiter == .completed) {
                    
                    logoutButton.tap()
                    
                    let loginScreenExpectation2 = XCTNSPredicateExpectation(predicate: exists, object: emailTextField)
                    
                    let loginScreenWaiter = XCTWaiter().wait(for: [loginScreenExpectation2], timeout: 30)
                    
                    XCTAssertEqual(loginScreenWaiter, .completed, "Log out successfully within 30 seconds")
                    
                } else {
                    XCTFail("Button logout didnt appeared within 10 seconds.")
                }
            }
            
            XCTAssertTrue(emailTextField.exists, "Login screen should be displayed.")
            
            emailTextField.tap()
            emailTextField.typeText("phankyphu@gmail.com")
            
            
            passwordSecureTextField.tap()
            sleep(1)
            passwordSecureTextField.typeText("12345678")
            
            signInButton.tap()
            
            let homeScreenExpectation = XCTNSPredicateExpectation(predicate: exists, object: todayStaticText)
            
            let _ = XCTWaiter().wait(for: [homeScreenExpectation], timeout: 30)
            
            XCTAssertTrue(todayStaticText.exists, "Home screen should be displayed.")
            
        } else {
            XCTFail("Neither login screen nor home screen appeared within 30 seconds.")
        }
        
    }
}
