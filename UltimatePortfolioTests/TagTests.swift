//
//  TagTests.swift
//  UltimatePortfolioTests
//
//  Created by Brandon Johns on 1/29/24.
//

import CoreData
import XCTest
@testable import UltimatePortfolio


/// Testing Creating and Deleting Tags
final class TagTests: BaseTestCase {

    
    /// Testing the creation of tags
    func testCreatingTagsAndIssues() {
        let count = 10
        
        for _ in 0..<count {
            let tag = Tag(context: managedObjectContext)
            
            
            for _ in 0..<count {
                let issue = Issue(context: managedObjectContext)
                tag.addToIssues(issue)
            }
        }
        
        
        //tests basics of core data stack
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), count, "Expected \(count) tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), count * count, "Expected \(count * count) issues.")
    }
  
    
    /// Testing that deleting Tags does not delete issues 
    func testDeletingTagDoesNotDeleteIssues() throws {
        dataController.createSampleData()
        
        let request = NSFetchRequest<Tag>(entityName: "Tag")
        let tags = try managedObjectContext.fetch(request)
        
        dataController.delete(tags[0])
        
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 4, "Expected 4 tags after deleting 1.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50, "Expected 50 issues after deleting a tag.")
    }
}
