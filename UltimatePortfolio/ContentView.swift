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
        List(selection: $dataController.selectedIssue) {
            ForEach(dataController.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")
        .searchable(text: $dataController.filterText, tokens: $dataController.filterTokens, suggestedTokens: .constant(dataController.suggestedFilterTokens), prompt: "Select a Tag or Type to find an issue") { tag in
            Text(tag.tagName)
            
        }
        .toolbar(content: ContentViewToolbar.init)
    }

    func delete(_ offsets: IndexSet) {
        let issues = dataController.issuesForSelectedFilter()

        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(DataController(inMemory: true))
}
