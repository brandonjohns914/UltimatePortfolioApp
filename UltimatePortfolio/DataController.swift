//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/16/24.
//


import CoreData
import SwiftUI

enum SortType: String {
    // raw value is what is assigned in coredata so the string version of these
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}
enum Status {
    case all, open, closed
}


/// An environment singleton responsible for managing our Core Data stack, including handling saving,
/// counting fetch requests, tracking orders, and dealing with sample data.
class DataController: ObservableObject {
    // loads/stores core data information so it can be passed between devices
    /// The lone CloudKit container used to store all our data
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
        //let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let trimmedFilterText = String(filterText).trimmingCharacters(in: .whitespaces)
        // searching Tag for the request
        let request = Tag.fetchRequest()
        if trimmedFilterText.isEmpty == false {
            // search case insensitive for exactly what was typed in
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }
        // return the result or an empty array
        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    
    //Loads the model once eveywhere its shared
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Fauled to load model file")
        }
        
        return managedObjectModel
        
    }()
    
    
    //creates a testing feature that only exsists in ram
    
    /// Initializes a data controller, either in memory( for testing use as previewing),
    /// or on permanent storage(for use in regular app runs).
    /// defaults to permanenet storage
    ///
    /// - Parameter inMemory: store this in data memory or not
    init(inMemory: Bool = false ) {
        // this loads the main data file
        // Self because its a static method
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        
        //For testing and previewing
        // this creates a temporary in memory database and writes to dev/null
        // the testing data is destoried after the app finishes
        if inMemory{
            // write this file to nowhere
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        //if something happens on another device
        container.viewContext.automaticallyMergesChangesFromParent = true
        //in memory changes more important that remote changes
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        // watches iCloud for all changes to sync local UI when a remote change happens
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
        forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        // when changes has happened call remoteStoreChanged so the views will update
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged
        )
        // error if the main file is never loaded
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
            
            //runs only in Debug mode for testing
            #if DEBUG
            //"enable-testing" is referenced in UITests
            if CommandLine.arguments.contains("enable-testing") {
                self.deleteAll()
                // turns off the animation during debugging 
                UIView.setAnimationsEnabled(false)
            }
            #endif
            
        }
    }
    // change has happened to the data
    /// Updates once a change has happened to the data in memory
    /// - Parameter notification: notification lets date know it should update
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    // used for testing and previewing
    
    /// Used to create sample data for testing
    /// Creates 5 Tags and 50 Issues
    func createSampleData() {
        // main queues managed object context
        let viewContext = container.viewContext
        //Issue/Tag == entities created in th main data file
        // 5 tags
        for tagCounter in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(tagCounter)"
            // in each tag create 10 issues
            for issueCounter in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(tagCounter)-\(issueCounter)"
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
    
    /// Saves our Core Data context if and only if  there are changes.
    /// This silently ignores any errors casued by saving,
    /// but this should be fine because all our attributes are optional.
    func save() {
        //because the onsubmit in issueview  save if there is a queued save just cancel it 
        saveTask?.cancel()
        // active memory has changed then save it
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    // save task after waiting a few seconds
    
    /// Creates a new task to wait three seconds before saving
    /// It will cancel the current save request if a change happens before the three second timer is completed
    /// It must run on the MainActor
    func queueSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            print("Queuing save")
            try await Task.sleep(for: .seconds(3))
            save()
            print("Saved")
        }
    }
    
    ///  Deletes objects from the data model
    ///  NSManagedObect = base core data Model that all objects inherit from
    ///  Memory is oging to send the delete item to the queue delete it and then save it
    /// - Parameter object: object is item being deleted from the model
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }
   
    // deleting the values found from the fetchRequest in a batchDeleteRequest
    
    //1)
    /// Private delete function that is used for testing and deleting values that are fetchRequested in batchDeleteRequest
    /// When Performing a batch delete request we need to read the result back
    /// then  merged all changes to the result into a viewContext in order to keep it in sync
  
    /// - Parameter fetchRequest: what fetched items to delete
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
     
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        // send back the results IDs
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
       
        //when performing abatch delete we need to read the result back
        //then merge all the changes that result back into a view context
        // this way they stay in sync
        // 1st tell me what you deleted the batch result the object identifiers
        // 2nd execute fetch request
        // 3rd place the delete objects into a dictionary
        
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
   
    
    /// Runs a fetch request with various predicates that filters the user's issues based on
    /// tag, title, and content text, search tokens, priority, and completion status
    ///
    /// - Returns: An array of all matching issues
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
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, contentPredicate]
            )
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
    
    /// Creates a new  Issue
    /// sets the values of Issue from the  datamodel
    /// .title, .creationDate, .priority
    
    func newIssue() {
        let issue = Issue(context: container.viewContext)
        // NSLocalizedString for multiple language support
        issue.title = NSLocalizedString("New Issue", comment: "Create a New Issue")
        issue.creationDate = .now
        issue.priority = 1
        
        
        // assigns to the user created tag and attaches an issue to the tag
        // the issue wont appear in the list without attaching it. 
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }
        save()
        // setting the issue in the datamodel to this issue
        selectedIssue = issue
    }
    
    
    /// Creats a new Tag
    /// sets values for .id and .name
    func newTag() {
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        // NSLocalizedString for multiple language support
        tag.name = NSLocalizedString("New Tag", comment: "Create a new tag")
        save()
    }
    // count how many decoded values have come from T
    
    /// Generic type of decoded values
    /// - Parameter fetchRequest: looking for the count of items
    /// - Returns: <#description#>
    func count<T>(for fetchRequest: NSFetchRequest<T> ) -> Int {
        // count how many items for this fetchRequest if not return 0
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    
    /// Creates the awarding system
    /// Decodes the award values for issues, closed, and tags
    /// - Parameter award: decoded values from the award.json
    /// - Returns: returns true for the award if they have hit the required parameters 
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



/*
 1) 
 ***
 when performing abatch delete we need to read the result back
 then merge all the changes that result back into a view context
  this way they stay in sync
  1st tell me what you deleted the batch result the object identifiers
  2nd execute fetch request
  3rd place the delete objects into a dictionary
 ***
 */
