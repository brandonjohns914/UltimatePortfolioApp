//
//  SidebarView.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/17/24.
//

import SwiftUI

struct SidebarView: View {
    
    //getting the data controller
    @EnvironmentObject var dataController: DataController
   
        // this accesses the all and recent filters in filter
    let smartFilters: [Filter] = [.all, .recent]
    
    // find and sort Tags by name
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    
    // convert tags into one filter object
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }
    
    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("Smart Filters") {
                // this sorts through both recent and all
                ForEach(smartFilters) { filter in
                    // changes the view of recent or all
                    NavigationLink(value: filter) {
                        // this shows all issues.names
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
            }
            
            // takes in the tags and places them
            // changes the view of where the tag goes
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                            .badge(filter.tag?.tagActiveIssues.count ?? 0)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .toolbar {
            Button {// creates sample data adds and deletes them 
                dataController.deleteAll()
                dataController.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
        }
    }
    
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            dataController.delete(item)
        }
    }
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}
