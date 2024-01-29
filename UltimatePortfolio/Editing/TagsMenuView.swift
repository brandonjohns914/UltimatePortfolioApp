//
//  TagsMenuView.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/26/24.
//

import SwiftUI

struct TagsMenuView: View {
    @ObservedObject var issue: Issue
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
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
}

#Preview {
    TagsMenuView(issue: .example)
        .environmentObject(DataController(inMemory: true))
}
