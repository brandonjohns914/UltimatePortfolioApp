//
//  SideBarViewToolbar.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/26/24.
//

import SwiftUI

struct SideBarViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    // Binding there is a value type property created and owned somewhere else to changing it here
    @State private var showingAwards = false
    @State private var showingStore = false
    
    var body: some View {
        Button(action: tryNewTag) {
            Label("Add tag", systemImage: "plus")
        }
        .sheet(isPresented: $showingStore, content: StoreView.init)
        
        
        Button {
            showingAwards.toggle()
        } label: {
            Label("Show awards", systemImage: "rosette")
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)
        //only used during debug wont be viewed from appstore
#if DEBUG
        Button {// creates sample data adds and deletes them
            dataController.deleteAll()
            dataController.createSampleData()
        } label: {
            Label("ADD SAMPLES", systemImage: "flame")
        } #endif
    }
    
    func tryNewTag() {
        if dataController.newTag() == false {
            showingStore = true
        }
    }
}

#Preview {
    SideBarViewToolbar()
}
