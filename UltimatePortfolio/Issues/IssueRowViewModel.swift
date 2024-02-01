//
//  IssueRowViewModel.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/31/24.
//

import CoreData
import Foundation

extension IssueRow {
    class ViewModel: ObservableObject {
        let issue: Issue
        
        var iconOpacity: Double {
            issue.priority == 2 ? 1 : 0
        }
        
        var iconIdentifier: String {
            issue.priority == 2 ? "\(issue.issueTitle) High Priority" : ""
        }
        
        var accessibilityHint: String {
            issue.priority == 2 ? "High priority" : ""
        }
        
        init(issue: Issue) {
            self.issue = issue
        }
        
        var creationDate: String {
            issue.issueCreationDate.formatted(date: .numeric, time: .omitted)
        }
        
        var accessibilityCreationDate: String {
            issue.issueCreationDate.formatted(date: .abbreviated, time: .omitted)
        }
    }
}
