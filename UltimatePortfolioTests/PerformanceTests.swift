//
//  PerformanceTests.swift
//  UltimatePortfolioTests
//
//  Created by Brandon Johns on 1/30/24.
//

import XCTest
@testable import UltimatePortfolio

final class PerformanceTests: BaseTestCase {
    
    /// Testing preformance of the app by adding 500 sample data awards
    func testAwardCalculationPerformance() {
        for _ in 1...100 {
            dataController.createSampleData()
        }
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        
        //Future testing. Sets the award count to 500.
        // So any slow preformance is due to something else
        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant. Change this if you add awards")
        
        
        //anywork to be measured inside measure
        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }
    
}
