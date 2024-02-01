//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/15/24.
//

import CoreSpotlight
import SwiftUI

@main
struct UltimatePortfolioApp: App {
    // instance of data controller to be shared everywhere
    @StateObject var dataController = DataController()
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(dataController: dataController)
            } content: {
                ContentView(dataController: dataController)
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
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }
    
    /// Reads out the core identifier spotlight sent
    /// - Parameter userActivity: is the spotlight search
    /// returns the selectedIssue from the selectedFilter  all
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        // reading out core identifer spot light sent
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            dataController.selectedIssue = dataController.issue(with: uniqueIdentifier)
            dataController.selectedFilter = .all
        }
    }
    
}
