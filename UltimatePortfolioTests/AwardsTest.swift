//
//  AwardsTest.swift
//  UltimatePortfolioTests
//
//  Created by Brandon Johns on 1/29/24.
//

import CoreData
import XCTest
@testable import UltimatePortfolio

final class AwardsTest: BaseTestCase {
    let awards = Award.allAwards
  
    func testAwardIDMatchesName() {
        for award in awards {
            //.id & .name should be unique
            XCTAssertEqual(award.id, award.name, "Award ID should always match its name.")
        }
    }
    
    func testNewUserHasUnlockedNoAwards() {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award), "New users should have no earned awards")
        }
    }
    
    func testCreatingIssuesUnlocksAwards() {
        // values correspond to how many issues and their position in the array
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {
            var issues = [Issue]()

            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issues.append(issue)
            }
            
            //how many awards have been unlocked
            let matches = awards.filter { award in
                award.criterion == "issues" && dataController.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Adding \(value) issues should unlock \(count + 1) awards.")
            //so the test starts over empty everytime
            dataController.deleteAll()
        }
    }
    func testClosingIssuesUnlocksAwards() {
        // values correspond to how many issues and their position in the array
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {
            var issues = [Issue]()

            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issue.completed = true
                issues.append(issue)
            }
            
            //how many awards have been unlocked
            let matches = awards.filter { award in
                award.criterion == "closed" && dataController.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Completing \(value) issues should unlock \(count + 1) awards.")
            //so the test starts over empty everytime
            dataController.deleteAll()
        }
    }
    
}
