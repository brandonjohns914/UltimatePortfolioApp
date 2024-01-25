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
    
    
    @State private var showingAwards = false
    
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
                            .accessibilityHint("^[\(filter.activeIssuesCount) issue](inflect: true)") //automatic grammar agreement
                    }
                }
                .onDelete(perform: delete) // to swipe and delete tags
            }
        }
        .toolbar {
            Button(action: dataController.newTag) {
                Label("Add tag", systemImage: "plus")
            }
            
            Button {
                showingAwards.toggle()
            } label: {
                Label("Show awards", systemImage: "rosette")
            }
            
            
            //only used during debug wont be viewed from appstore
            #if DEBUG
            Button {// creates sample data adds and deletes them
                dataController.deleteAll()
                dataController.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            } #endif
            
        }
        .alert("Rename tag", isPresented: $renamingTag) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $tagName)
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init) 
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
