//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/16/24.
//

import CoreData

class DataController: ObservableObject {
    
    // loads/stores core data information so it can be passed between devices
    let container: NSPersistentCloudKitContainer
    
    
    // selectedFilter of the issues so this accesses the static all in filter
    @Published var selectedFilter: Filter? = Filter.all
    
    // This accesses the Issues on the mainDataModel
    @Published var selectedIssue: Issue?
    
    // example of a of the DataController without creating an instance
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    
    //creates a testing feature that only exsists in ram
    init(inMemory: Bool = false ){
        // this loads the main data file
        
        container = NSPersistentCloudKitContainer(name: "Main")
        
        //
        if inMemory{
            // write this file to nowhere
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator, queue: .main, using: remoteStoreChanged)
        
        
        
        // error if the main file is never loaded
        container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
    
    // used for testing and previewing
    func createSampleData() {
        
        // main queues managed object context
        let viewContext = container.viewContext
        
        //Issue/Tag == entities created in th main data file
        
        // 5 tags
        for i in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"
            
            // in each tag create 10 issues
            for j in 1...10 {
                
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(i)-\(j)"
                issue.content = "Description goes here"
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                // addToIssues comes from automatically generated files from data model
                tag.addToIssues(issue)
            }
        }
        try? viewContext.save()
    }
    
    func save() {
        // active memory has changed then save it
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    
    func delete(_ object: NSManagedObject) {
        //NSManagedObect = base core data Model that all objects inherit from
        
        // memory is going to change send it to the queue and delete it form the queue then save it
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }
    
    //private because its only used for testing
    // deleting the values found from the fetchRequest in a batchDeleteRequest
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        //1st tell me what you deleted the batch.result the object identifiers
        //2nd execute fetch request
        //3rd place the delete objects into a dictionary
        
        
        
        // taking the fetchRequest results and making them a batchDelete
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
            // send back the results IDs
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        // delete the IDs found and define them as a batchDeleteResult
        // execute can take any kind of fetch request
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            // changes = new dictionary
            // [IDs: the delete result as a NSObjectID Array if not return an empty array
            let changes = [NSDeletedObjectIDsKey: delete.result as? [NSManagedObjectID] ?? [] ]
            
            // adding the removed items to the container MainQueue
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext] )
        }
    }
    
    //NSFetchRequest find objects held in NSPersistentStore and NSManagedObject
    func deleteAll() {
        
        //deleting all Tags
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)
        
        //deleting all Issues
        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)
        save()
    }
}
