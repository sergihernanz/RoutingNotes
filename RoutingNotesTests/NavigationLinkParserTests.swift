//
//  NavigationLinkParserTests.swift
//  RoutingNotesTests
//
//  Created by Sergi Hernanz on 18/03/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import Foundation
import XCTest
@testable import RoutingNotes

class NavigationLinkParserTests: XCTestCase {

    func testFoldersLink() {
        var navigation: NotesNavigation?
        var url: URL!
        XCTContext.runActivity(named: """
            GIVEN we have a .folders url
        """, block: { _ in
            url = URL(string: "routingnotes://folders")
            XCTAssertNotNil(url)
        })
        XCTContext.runActivity(named: """
            WHEN we parse the link url
        """, block: { _ in
            do {
                try navigation = NotesLinkParser.navigation(url: url)
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        })
        XCTContext.runActivity(named: """
            THEN it is correctly decoded
        """, block: { _ in
            XCTAssertEqual(navigation, .folders)
        })
    }

    func testFoldersListLink() {
        var navigation: NotesNavigation?
        var url: URL!
        XCTContext.runActivity(named: """
            GIVEN we have a .foldersList url
        """, block: { _ in
            url = URL(string: "routingnotes://list/1")
            XCTAssertNotNil(url)
        })
        XCTContext.runActivity(named: """
            WHEN we parse the link url
        """, block: { _ in
            do {
                try navigation = NotesLinkParser.navigation(url: url)
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        })
        XCTContext.runActivity(named: """
            THEN it is correctly decoded
        """, block: { _ in
            XCTAssertEqual(navigation, .folders👉list(listId: "1"))
        })
    }

    func testFoldersListNoteLink() {
        var navigation: NotesNavigation?
        var url: URL!
        XCTContext.runActivity(named: """
            GIVEN we have a .foldersListNote url
        """, block: { _ in
            url = URL(string: "routingnotes://list/1/note/A")
            XCTAssertNotNil(url)
        })
        XCTContext.runActivity(named: """
            WHEN we parse the link url
        """, block: { _ in
            do {
                try navigation = NotesLinkParser.navigation(url: url)
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        })
        XCTContext.runActivity(named: """
            THEN it is correctly decoded
        """, block: { _ in
            XCTAssertEqual(navigation, .folders👉list👉note(listId: "1", noteId:"A"))
        })
    }

}
