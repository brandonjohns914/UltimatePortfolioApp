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
    // renaming tags are local
    @State private var tagToRename: Tag?
    @State private var renamingTag = false
    @State private var tagName = ""
    // convert tags into one filter object
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }
    
    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("Smart Filters") {
                // Creation filters of  recent and all
                ForEach(smartFilters, content: SmartFilterRow.init)
            }
            // takes in the tags and places them
            // changes the view of where the tag goes
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    // passing the functions
                    UserFilterRow(filter: filter, rename: rename, delete: delete)
                }
                .onDelete(perform: delete) // to swipe and delete tags
            }
        }
        .toolbar(content: SideBarViewToolbar.init)
        .alert("Rename tag", isPresented: $renamingTag) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $tagName)
        }
        .navigationTitle("Filters")
    }
    //for swipe to delete
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            dataController.delete(item)
        }
    }
    func delete(_ filter: Filter) {
        guard let tag = filter.tag else {return}
        dataController.delete(tag)
        dataController.save()
    }
    func rename(_ filter: Filter) {
        // setting local rename to filter.tag
        tagToRename = filter.tag
        //setting name to filter.name
        tagName = filter.name
        
        renamingTag = true
    }
    func completeRename() {
        // setting tagNAme to the rename
        tagToRename?.name = tagName
        // saving the rename
        dataController.save()
    }
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}
