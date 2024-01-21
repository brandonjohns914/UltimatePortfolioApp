//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/15/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
    var issues: [Issue] {
        
        // choosing between the selected if no filter then filter by all
        
        let filter = dataController.selectedFilter ?? .all
        var allIssues: [Issue]
        
        
        // if there is a tag if use it if not find issue
        if let tag = filter.tag {
            allIssues = tag.issues?.allObjects as? [Issue] ?? []
        } else {
            let request = Issue.fetchRequest()
            
            //only match issues from date later than minModificationDate
            request.predicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            
            // setting all issues to be fetched
            allIssues = (try? dataController.container.viewContext.fetch(request)) ?? []
        }
        
        return allIssues.sorted()
    }
    var body: some View {
        // active selected issues 
        List(selection: $dataController.selectedIssue) {
            ForEach(issues) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")
    }
    
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
}


//#Preview {
//    ContentView()
//}
