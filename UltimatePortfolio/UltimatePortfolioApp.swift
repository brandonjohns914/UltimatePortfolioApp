//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/15/24.
//

import SwiftUI

@main
struct UltimatePortfolioApp: App {
    // instance of data controller to be shared everywhere
    @StateObject var dataController = DataController()
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            } // everytime Swift wants to query core data needs to know where to look
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
            
         .onChange(of: scenePhase) { oldPhase, phase in
           
                // if app is not active immediately call save
                if phase != .active {
                    dataController.save()
                }
            }
        }
    }
}
