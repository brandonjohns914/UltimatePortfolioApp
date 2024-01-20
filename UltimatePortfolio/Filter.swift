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
    
    //all the issues
    static var all = Filter(id: UUID(), name: "All Issues", icon: "tray")
    
    // recent issues
    static var recent = Filter(id: UUID(), name: "Recent issues", icon: "clock", minModificationDate: .now.addingTimeInterval(86400 - 7))
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
