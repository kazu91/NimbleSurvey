//
//  NimbleSurveyTests.swift
//  NimbleSurveyTests
//
//  Created by Kazu on 31/7/24.
//

import Testing
@testable import NimbleSurvey
import Foundation

class BundleClass {
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
}

struct NimbleSurveyTests {

    @Test func testExample() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}
