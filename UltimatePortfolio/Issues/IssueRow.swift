//
//  IssueRow.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/18/24.
//

import SwiftUI

struct IssueRow: View {
    
    @EnvironmentObject var dataController: DataController
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        // loading the local Issue view
        NavigationLink(value: viewModel.issue) {
            HStack {
                // priority of the issue
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    
                    .opacity(viewModel.iconOpacity)
                    .accessibilityIdentifier(viewModel.iconIdentifier)
                
                VStack (alignment: .leading) {
                    Text(viewModel.issue.issueTitle)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(viewModel.issue.issueTagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(viewModel.creationDate)
                        .accessibilityLabel(viewModel.accessibilityCreationDate)
                        .font(.subheadline)
                    
                    if viewModel.issue.completed {
                        Text("CLOSED")
                            .font(.body.smallCaps())
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .accessibilityHint(viewModel.accessibilityHint)
        .accessibilityIdentifier(viewModel.issue.issueTitle)
    }
    
    init(issue: Issue){
        let viewModel = ViewModel(issue: issue)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    IssueRow(issue: .example)
}
