//
//  SidebarView.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/17/24.
//

import SwiftUI

struct SidebarView: View {
    @StateObject private var viewModel: ViewModel
    
    // this accesses the all and recent filters in filter
    let smartFilters: [Filter] = [.all, .recent]
    
    
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
 
    
    var body: some View {
        List(selection: $viewModel.dataController.selectedFilter) {
            Section("Smart Filters") {
                // Creation filters of  recent and all
                ForEach(smartFilters, content: SmartFilterRow.init)
            }
            // takes in the tags and places them
            // changes the view of where the tag goes
            Section("Tags") {
                ForEach(viewModel.tagFilters) { filter in
                    // passing the functions
                    UserFilterRow(filter: filter, rename: viewModel.rename, delete: viewModel.delete)
                }
                .onDelete(perform: viewModel.delete) // to swipe and delete tags
            }
        }
        .toolbar(content: SideBarViewToolbar.init)
        .alert("Rename Tag", isPresented: $viewModel.renamingTag) {
            Button("OK", action: viewModel.completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $viewModel.tagName)
        }
        .navigationTitle("Filters")
    }
    
}

#Preview {
    SidebarView(dataController: DataController.preview)
        
}
