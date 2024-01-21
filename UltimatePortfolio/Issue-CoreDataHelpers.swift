//
//  Issue-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/17/24.
//

import Foundation
// Issue is the class given when CoreDate Entinties are created
extension Issue {
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue}
    }
    var issueContent: String {
        get { content ?? "" }
        set { content = newValue}
    }
    
    var issueCreationDate: Date {
        creationDate ?? . now
    }
    
    var issueModificationDate: Date {
        modificationDate ?? .now
    }
    
    //sorts issueTags so they are sorted in order on the screen
    var issueTags: [Tag] {
        
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    
    // creates so the tags can be displayed by their name 
    var issueTagsList: String {
        guard let tags else { return "No tags" }

        if tags.count == 0 {
            return "No tags"
        } else {
            return issueTags.map(\.tagName).formatted()
        }
    }
    
    var issueStatus: String {
        if completed {
            return "Closed"
        } else {
            return "Open"
        }
    }
    
    //sample example issue
    static var example: Issue {
        
        let controller = DataController(inMemory: true)
        
        let viewContext = controller.container.viewContext
        
        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is an example issue."
        issue.priority = 2
        issue.creationDate = .now
        return issue
    }
}

// have to make Issue comparable so it can be sorted
extension Issue: Comparable {
    public static func <(lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase

        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }
}
