//
//  IssueView.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/18/24.
//

import SwiftUI

struct IssueView: View {
    @ObservedObject var issue: Issue
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    Text("**Status:** \(issue.issueStatus)")
                        .foregroundStyle(.secondary)
                }
                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                TagsMenuView(issue: issue)
            }
            Section {
                VStack(alignment: .leading) {
                    Text("Basic Infomation")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    TextField("Description",
                              text: $issue.issueContent,
                              prompt: Text("Enter the issue description here"),
                              axis: .vertical
                    )
                }
            }
        } // if issue is deleted dont allow editing
        .disabled(issue.isDeleted)
        // every small change wont instantly save it will wait 3 seconds before calling save
        .onReceive(issue.objectWillChange){ _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save) // user submits does not have to wait for the queue
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
    }
}

#Preview {
    IssueView(issue: .example)
        .environmentObject(DataController(inMemory: true))
}
