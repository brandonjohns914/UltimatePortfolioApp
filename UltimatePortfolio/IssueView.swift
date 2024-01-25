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
                
                Menu {
                    // show selected tags
                    ForEach(issue.issueTags) { tag in
                        Button{
                            //removeFromTags created by coredata
                            issue.removeFromTags(tag)
                        } label: {
                            Label(tag.tagName, systemImage: "checkmark")
                        }
                    }
                    
                    //unselectedTags
                    
                    let otherTags = dataController.missingTags(from: issue)
                    
                    if otherTags.isEmpty == false {
                    Divider()
                        
                        Section("Add Tags") {
                            ForEach(otherTags) { tag in
                                Button(tag.tagName) {
                                    issue.addToTags(tag)
                                }
                            }
                        }
                    }
                } label: {
                    Text(issue.issueTagsList)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading) //tags selected view size
                        .animation(nil, value: issue.issueTagsList) // no animation on the tags selected 
                }
            }
            Section {
                VStack(alignment: .leading) {
                    Text("Basic Infomation")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    TextField("Description", text: $issue.issueContent, prompt: Text("Enter the issue description here"), axis: .vertical)
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
            Menu {
                Button {
                    UIPasteboard.general.string = issue.title
                } label: {
                    Label("Copy Issue Title", systemImage: "doc.on.doc")
                }

                Button {
                    issue.completed.toggle()
                    dataController.save()
                } label: {
                    Label(issue.completed ? "Re-open Issue" : "Close Issue", systemImage: "bubble.left.and.exclamationmark.bubble.right")
                }
            } label: {
                Label("Actions", systemImage: "ellipsis.circle")
            }
        }
        
    }
}

#Preview {
    IssueView(issue: .example)
}
