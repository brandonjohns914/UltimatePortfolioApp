//
//  Filter.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/17/24.
//

import Foundation


// filtering by Issues so it can be broken down to specifics of the issue
struct Filter: Identifiable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var minModificationDate = Date.distantPast
    // can also filter by tags
    var tag: Tag?
    
    var activeIssuesCount: Int {
        tag?.tagActiveIssues.count ?? 0
    }
    //all the issues conform to this
    static var all = Filter( 
        id: UUID(),
        name: "All Issues",
        icon: "tray"
    )
    // all recent issues
    static var recent = Filter(
        id: UUID(),
        name: "Recent Issues",
        icon: "clock",
        minModificationDate: .now.addingTimeInterval(86400 - 7)
    )
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
