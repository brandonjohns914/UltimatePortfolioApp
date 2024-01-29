//
//  UserFilterRow.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/26/24.
//

import SwiftUI

struct UserFilterRow: View {
    var filter: Filter // functions passed into
    var rename: (Filter) -> Void
    var delete: (Filter) -> Void
    
    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
                .badge(filter.activeIssuesCount)
                .contextMenu {
                    Button {
                        rename(filter)
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    // delete the tag during creation
                    Button(role: .destructive){
                        delete(filter)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .accessibilityElement() //groups all of these as one element for accessibility
                .accessibilityLabel(filter.name)
                .accessibilityHint("\(filter.activeIssuesCount) issues")
                //.accessibilityHint("^[\(filter.activeIssuesCount) issue](inflect: true)") //automatic grammar agreement
        }
    }
}

#Preview {
    UserFilterRow(filter: .all, rename: { _ in }, delete: {_ in })
}
