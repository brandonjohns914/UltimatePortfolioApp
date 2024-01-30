//
//  ExtensionTests.swift
//  UltimatePortfolioTests
//
//  Created by Brandon Johns on 1/29/24.
//

import CoreData
import XCTest
@testable import UltimatePortfolio

final class ExtensionTests: BaseTestCase {

    
    /// Testing that issueTitle gets unwrappec correctly
    func testIssueTitleUnwrap() {
        //Given
        let issue = Issue(context: managedObjectContext)
        
        //When
        issue.title = "Example issue"
        //Then
        XCTAssertEqual(issue.issueTitle, "Example issue", "Changing title should also change issueTitle")
        
        //When
        issue.issueTitle = "Updated issue"
        //Then
        XCTAssertEqual(issue.title, "Updated issue", "Changing issueTitle should also change Title")
    }
    
    
    /// Testing that issueContent gets unwrapped correctly
    func testIssueContentUnwrap() {
        
        //Given
        let issue = Issue(context: managedObjectContext)
        //When
        issue.content = "Example issue"
        //Then
        XCTAssertEqual(issue.issueContent, "Example issue", "Changing content should also change issueContent")
        
        //When
        issue.issueContent = "Updated issue"
        //Then
        XCTAssertEqual(issue.content, "Updated issue", "Changing issueContent should also change content")
    }
    
    
    
    /// Testing that issueCreationDate unwraps correctly
    func testIssueCreationDateUnwrap() {
        // Given
        let issue = Issue(context: managedObjectContext)
        let testDate = Date.now

        // When
        issue.creationDate = testDate

        // Then
        XCTAssertEqual(issue.issueCreationDate, testDate, "Changing creationDate should also change issueCreationDate.")
    }
    
    
    /// Testing that an Issue and Tags
    /// Issues should not have any tags
    /// Adding a Tag to an ISsue should give the issueTags one tag
    func testIssueTagsUnwrap() {
        //Given
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)
        
        //When
        XCTAssertEqual(issue.issueTags.count, 0, "A new issue should have no tags.")
        issue.addToTags(tag)
        
        //Then
        XCTAssertEqual(issue.issueTags.count, 1, "Adding 1 tag to an issue should result in issueTags having count 1.")
    }
    
    
    /// Testing that adding adding a tag should make the issueTagList be set to that tag
    func testIssueTagsList() {
        //Given
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)

        //When
        tag.name = "My Tag"
        issue.addToTags(tag)

        //Then
        XCTAssertEqual(issue.issueTagsList, "My Tag", "Adding 1 tag to an issue should make issueTagsList be My Tag.")
    }
    
    
    /// Testing the sorting of Issues that should follow name then creation date
    func testIssueSortingIsStable() {
        //Given
        let issue1 = Issue(context: managedObjectContext)
        //When
        issue1.title = "B Issue"
        issue1.creationDate = .now
        
        //Given
        let issue2 = Issue(context: managedObjectContext)
        //When
        issue2.title = "B Issue"
        issue2.creationDate = .now.addingTimeInterval(1)
        
        //Given
        let issue3 = Issue(context: managedObjectContext)
        //When
        issue3.title = "A Issue"
        issue3.creationDate = .now.addingTimeInterval(100)

        //Given
        let allIssues = [issue1, issue2, issue3]
        let sorted = allIssues.sorted()
        //Then
        XCTAssertEqual([issue3, issue1, issue2], sorted, "Sorting issue arrays should use name then creation date.")
    }
    
    
    /// Testing chaging the id of a tag should change the tagID
    func testTagIDUnwrap() {
        //When
        let tag = Tag(context: managedObjectContext)
        // Given
        tag.id = UUID()
        //Then
        XCTAssertEqual(tag.tagID, tag.id, "Changing id should also change tagID.")
    }

    
    /// Testing changing the tag.name should also change tagName
    func testTagNameUnwrap() {
        //When
        let tag = Tag(context: managedObjectContext)
        //Given
        tag.name = "Example Tag"
        //Then
        XCTAssertEqual(tag.tagName, "Example Tag", "Changing name should also change tagName.")
    }
    
    /// Testing Tag Active Issues
    /// A new tag should have zero active issues
    func testTagActiveIssues() {
        //Given
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)
        //Then
        XCTAssertEqual(tag.tagActiveIssues.count, 0, "A new tag should have 0 active issues.")
        //When
        tag.addToIssues(issue)
        //Then
        XCTAssertEqual(tag.tagActiveIssues.count, 1, "A new tag with 1 new issue should have 1 active issue.")
        //When
        issue.completed = true
        //Then
        XCTAssertEqual(tag.tagActiveIssues.count, 0, "A new tag with 1 completed issue should have 0 active issues.")
    }
    
    /// Testing that Sorting of tags that should use name then UUID
    func testTagSortingIsStable() {
        //Given
        let tag1 = Tag(context: managedObjectContext)
        //When
        tag1.name = "B Tag"
        tag1.id = UUID()

        let tag2 = Tag(context: managedObjectContext)
        tag2.name = "B Tag"
        tag2.id = UUID(uuidString: "FFFFFFFF-ADDB-4F16-A6A8-ED85A83BA580")

        let tag3 = Tag(context: managedObjectContext)
        tag3.name = "A Tag"
        tag3.id = UUID()

        //When
        let allTags = [tag1, tag2, tag3]
        let sortedTags = allTags.sorted()
        //Then
        XCTAssertEqual([tag3, tag1, tag2], sortedTags, "Sorting tag arrays should use name then UUID string.")
    }
    
    /// Testing Awards should not be empty
    func testBundleDecodingAwards() {
        //Given
        let awards = Bundle.main.decode("Awards.json", as: [Award].self)
        //Then
        XCTAssertFalse(awards.isEmpty, "Awards.json should decode to a non-empty array.")
    }
    
    
    /// Testing that decoding a JSON converts it to a string
    func testDecodingString() {
        //Given
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode("DecodableString.json", as: String.self)
        
        //Then
        XCTAssertEqual(data, "Never ask a starfish for directions.", "The string must match DecodableString.json.")
    }
    
    
    /// Testing decoding JSON into a dictionary
    func testDecodingDictionary() {
        //Given
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode("DecodableDictionary.json", as: [String: Int].self)
       
       //Then
        XCTAssertEqual(data.count, 3, "There should be three items decoded from DecodableDictionary.json.")
        XCTAssertEqual(data["One"], 1, "The dictionary should contain the value 1 for the key One.")
    }
}
