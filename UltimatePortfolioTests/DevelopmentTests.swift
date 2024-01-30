//
//  DevelopmentTests.swift
//  UltimatePortfolioTests
//
//  Created by Brandon Johns on 1/29/24.
//

import CoreData
import XCTest
@testable import UltimatePortfolio


/// Testing that the sample data does what it is suppose to do
/// creates 5 Tags and 50 Issues
final class DevelopmentTests: BaseTestCase {

    
    /// Testing 5 Tags and 50 Issues are created
    func testSampleDataCreationWorks() {
        dataController.createSampleData()
        
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 5, "There should be 5 sample tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50, "There should be 50 sample tags.")
    }

    
    /// Testing DeleteAll clears all issues and tags
    func testDeleteAllClearsEverything() {
        dataController.createSampleData()
        dataController.deleteAll()

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 0, "deleteAll() should leave 0 tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 0, "deleteAll() should leave 0 issues.")
    }
    
    
    /// Testing that the example tag is created without any issues
    func testExampleTagHasNoIssues() {
        let tag = Tag.example
        XCTAssertEqual(tag.issues?.count, 0, "The example tag should have 0 issues.")
    }

    
    /// Testing the priorty rating of the issues 
    func testExampleIssueIsHighPriority() {
        let issue = Issue.example
        XCTAssertEqual(issue.priority, 2, "The example issue should be high priority.")
    }
}
