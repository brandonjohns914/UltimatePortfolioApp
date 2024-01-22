//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/15/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
  
    var body: some View {
        // active selected issues 
        List(selection: $dataController.selectedIssue) {
            ForEach(dataController.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")
        .searchable(text: $dataController.filterText, prompt: "Filter issues")
    }
    
    func delete(_ offsets: IndexSet) {
        let issues = dataController.issuesForSelectedFilter()
        
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
}


//#Preview {
//    ContentView()
//}
