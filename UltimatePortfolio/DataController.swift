//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/16/24.
//


import CoreData

enum SortType: String {
    // raw value is what is assigned in coredata so the string version of these
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

enum Status {
    case all, open, closed
}



class DataController: ObservableObject {
    
    // loads/stores core data information so it can be passed between devices
    let container: NSPersistentCloudKitContainer
    
    
    // selectedFilter of the issues so this accesses the static all in filter
    @Published var selectedFilter: Filter? = Filter.all
    
    // This accesses the Issues on the mainDataModel
    @Published var selectedIssue: Issue?
    
    //store filter text
    @Published var filterText = ""
    
    @Published var filterTokens = [Tag]()
    
    @Published var filterEnabled = false
    // 1 = low 2 = high -1 = any priority
    @Published var filterPriority = -1
    
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true 
    
    
    
    private var saveTask: Task<Void, Error>?
    
    // example of a of the DataController without creating an instance
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    
    // searching for a specific value
    var suggestedFilterTokens: [Tag] {
        // ios 17 requires tag query to be empty
        // search starts with #
//        guard filterText.starts(with: "#") else {
//            return []
//        }
        
        // removing # and white spaces to search for the request
        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        // searching Tag for the request
        let request = Tag.fetchRequest()
        
        if trimmedFilterText.isEmpty == false {
            // search case insensitive for exactly what was typed in
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }
        
        // return the result or an empty array
        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    
    
    
   
    
    
    
    //creates a testing feature that only exsists in ram
    init(inMemory: Bool = false ){
        // this loads the main data file
        
        container = NSPersistentCloudKitContainer(name: "Main")
        
        //
        if inMemory{
            // write this file to nowhere
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        
        //if something happens on another device
        container.viewContext.automaticallyMergesChangesFromParent = true
        //in memory changes more important that remote changes
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        //tell when something has changed
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // when changes has happened call remoteStoreChanged so the views will update
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator, queue: .main, using: remoteStoreChanged)
        
        
        
        // error if the main file is never loaded
        container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    // change has happened to the data
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
        //because the onsubmit in issueview  save if there is a queued save just cancel it 
        saveTask?.cancel()
        // active memory has changed then save it
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    // save task after waiting a few seconds
    func queueSave() {
        // cancel the save if changes happen before 3 seconds are complete
        saveTask?.cancel()
        
        // creating a new task to wait 3 seconds before saving
        // must run this task on the MainActor
        saveTask = Task { @MainActor in
            print("Queuing save")
            try await Task.sleep(for: .seconds(3))
            save()
            print("Saved")
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
    
    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        
        // all tags as an array
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        
        let allTagsSet = Set(allTags)
        //difference between all tags and issue tags
        let difference = allTagsSet.symmetricDifference(issue.issueTags)

        
        //array of tags 
        return difference.sorted()
    }
    
    //filtering issues
    func issuesForSelectedFilter() -> [Issue] {
        
        // choosing between the selected if no filter then filter by all
        let filter = selectedFilter ?? .all
        
        // array that will contain all predicates
        var predicates = [NSPredicate]()
        
        
        // searching based on tags or modificationDate
        // filter comes from the coredata automatticaly generated classes
        if let tag = filter.tag {
            
           // is there a tag that contains the searched tag
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            // adding the tagPredicate to the predicates array
            predicates.append(tagPredicate)
            
            
        } else {
            // searching by minModificationDate
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }
        
        
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

        
        if trimmedFilterText.isEmpty == false {
            // contains case insensitive of title and content
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            
            // either title or content predicate
            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            predicates.append(combinedPredicate)
        }
        
        if filterTokens.isEmpty == false {
            for filterToken in filterTokens {
                let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterToken)
                predicates.append(tokenPredicate)
            }
        }
        
        if filterEnabled {
            if filterPriority >= 0 {
                // filtering a number
                let priorityFilter = NSPredicate(format: "priority = %d", filterPriority)
                //adding number priority to predicate array
                predicates.append(priorityFilter)
            }
            // filterStatus not all issues
            if filterStatus != .all {
                // filterStatus = closed make it true if not make it false
                let lookForClosed = filterStatus == .closed
                // looking  for closed status filters
                let statusFilter = NSPredicate(format: "completed = %@", NSNumber(value: lookForClosed))
                // adding closed status filtesr to the predicate array
                predicates.append(statusFilter)
                
            }
        }
        
        
        let request = Issue.fetchRequest()
        
        //Combining all predicates and making it one single predicate
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        // fetching sort descriptory
        //reading out the rawValue of dateCreated/ dateModified 
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]
        
        
        // setting allIssues = the predicate search array results
        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        return allIssues
    }
    
    //creates and saves new issue
    func newIssue() {
        let issue = Issue(context: container.viewContext)
        // .title comes from the dataModel attributes
        // NSLocalizedString for multiple language support
        issue.title = NSLocalizedString("New Issue", comment: "Create a new issue")
        issue.creationDate = .now
        issue.priority = 1 
        
        // assigns tag to the created issue 
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }
        save()
        
        // setting the issue in the datamodel to this issue 
        selectedIssue = issue
    }
    
    func newTag() {
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        // NSLocalizedString for multiple language support
        tag.name = NSLocalizedString("New Tag", comment: "Create a new tag")
        save()
    }
    
    // count how many decoded values have come from T
    func count<T>(for fetchRequest: NSFetchRequest<T> ) -> Int {
        // count how many items for this fetchRequest if not return 0
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
        
    }
    
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "issues":
            // returns true if they added a certain number of issues
            let fetchRequest = Issue.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "closed":
            // returns true if they closed a certain number of issues
            let fetchRequest = Issue.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "tags":
            // return true if they created a certain number of tags
            let fetchRequest = Tag.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        default:
            // an unknown award criterion; this should never be allowed
            // fatalError("Unknown award criterion: \(award.criterion)")
            return false
        }
    }
}
