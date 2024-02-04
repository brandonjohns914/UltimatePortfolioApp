//
//  ContentViewModel.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/31/24.
//

import CoreData
import Foundation

extension ContentView {
    class ViewModel: ObservableObject {
        var dataController: DataController
        var shouldRequestReview: Bool {
            dataController.count(for: Tag.fetchRequest()) >= 5
        }
        init(dataController: DataController) {
            self.dataController = dataController
        }
     
        func delete(_ offsets: IndexSet) {
            let issues = dataController.issuesForSelectedFilter()
            for offset in offsets {
                let item = issues[offset]
                dataController.delete(item)
            }
        }
        
    }
    
}
