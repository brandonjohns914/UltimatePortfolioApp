//
//  AssetTests.swift
//  UltimatePortfolioTests
//
//  Created by Brandon Johns on 1/29/24.
//

import XCTest
@testable import UltimatePortfolio


final class AssetTests: XCTestCase {
    
    
    /// Tests to see that the color JSON has loaded
    func testColorsExists() {
        let allColors = ["Dark Blue", "Dark Gray", "Gold", "Gray", "Green",
                         "Light Blue", "Midnight", "Orange", "Pink", "Purple", "Red", "Teal"]
        
        for color in allColors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog.")
        }
        
    }
    
    /// Tests that the awards have loaded correctly based 
    func testAwardsLoadCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON")
    }
}
