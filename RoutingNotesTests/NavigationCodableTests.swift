//
//  NavigationCodableTests.swift
//  RoutingNotesTests
//
//  Created by Sergi Hernanz on 13/02/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import XCTest
@testable import RoutingNotes

class NavigationCodableTests: XCTestCase {

    func testFoldersEncode() {
        let navigation: NotesNavigation = .folders
        var navigationDecoded: NotesNavigation = .folders
        XCTContext.runActivity(named: """
            GIVEN we have a .folders navigation
        """, block: { _ in
            XCTAssertEqual(navigation, .folders)
        })
        XCTContext.runActivity(named: """
            WHEN we encode the item
        """, block: { _ in
            do {
                let encoded = try JSONEncoder().encode(navigation)
                print(String(data: encoded, encoding: .utf8) ?? "")
                XCTAssertNotNil(encoded)
                navigationDecoded = try JSONDecoder().decode(NotesNavigation.self, from: encoded)
                XCTAssertNotNil(navigationDecoded)
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        })
        XCTContext.runActivity(named: """
            THEN it is correctly decoded
        """, block: { _ in
            XCTAssertEqual(navigationDecoded, .folders)
        })
    }

    func testFoldersListEncode() {
        let navigation: NotesNavigation = .folders👉list(listId: "1")
        var navigationDecoded: NotesNavigation = .folders
        XCTContext.runActivity(named: """
            GIVEN we have a .foldersList navigation
        """, block: { _ in
            XCTAssertEqual(navigation, .folders👉list(listId: "1"))
        })
        XCTContext.runActivity(named: """
            WHEN we encode the item
        """, block: { _ in
            do {
                let encoded = try JSONEncoder().encode(navigation)
                print(String(data: encoded, encoding: .utf8) ?? "")
                XCTAssertNotNil(encoded)
                navigationDecoded = try JSONDecoder().decode(NotesNavigation.self, from: encoded)
                XCTAssertNotNil(navigationDecoded)
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        })
        XCTContext.runActivity(named: """
            THEN it is correctly decoded
        """, block: { _ in
            XCTAssertEqual(navigationDecoded, .folders👉list(listId: "1"))
        })
    }

    func testFoldersListNoteEncode() {
        let navigation: NotesNavigation = .folders👉list👉note(listId: "1", noteId: "A")
        var navigationDecoded: NotesNavigation = .folders
        XCTContext.runActivity(named: """
            GIVEN we have a .foldersListNote navigation
        """, block: { _ in
            XCTAssertEqual(navigation, .folders👉list👉note(listId: "1", noteId: "A"))
        })
        XCTContext.runActivity(named: """
            WHEN we encode the item
        """, block: { _ in
            do {
                let encoded = try JSONEncoder().encode(navigation)
                print(String(data: encoded, encoding: .utf8) ?? "")
                XCTAssertNotNil(encoded)
                navigationDecoded = try JSONDecoder().decode(NotesNavigation.self, from: encoded)
                XCTAssertNotNil(navigationDecoded)
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        })
        XCTContext.runActivity(named: """
            THEN it is correctly decoded
        """, block: { _ in
            XCTAssertEqual(navigationDecoded, .folders👉list👉note(listId: "1", noteId: "A"))
        })
    }

}

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
