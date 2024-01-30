//
//  UltimatePortfolioTests.swift
//  UltimatePortfolioTests
//
//  Created by Brandon Johns on 1/28/24.
//

import CoreData
import XCTest

//@testable brings in all code from the app without restrictions like public
@testable import UltimatePortfolio


/// BaseTestCase is what all other tests are based off
/// creates implicitly unwrapped DataController and NSManagedObjectContext
/// //
class BaseTestCase: XCTestCase {
    // all tests have datastorage as needed
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
