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
        """, block:{ _ in
            XCTAssertEqual(navigation, .folders)
        })
        XCTContext.runActivity(named: """
            WHEN we encode the item
        """, block:{ _ in
            do {
                let encoded = try JSONEncoder().encode(navigation)
                print(String(data: encoded, encoding: .utf8) ?? "")
                XCTAssertNotNil(encoded)
                navigationDecoded = try JSONDecoder().decode(NotesNavigation.self, from: encoded)
                XCTAssertNotNil(navigationDecoded)
            } catch ( let e ) {
                XCTFail(e.localizedDescription)
            }
        })
        XCTContext.runActivity(named: """
            THEN it is correctly decoded
        """, block:{ _ in
            XCTAssertEqual(navigationDecoded, .folders)
        })
    }

    func testFoldersListEncode() {
        let navigation: NotesNavigation = .folders👉list(listId: "1")
        var navigationDecoded: NotesNavigation = .folders
        XCTContext.runActivity(named: """
            GIVEN we have a .foldersList navigation
        """, block:{ _ in
            XCTAssertEqual(navigation, .folders👉list(listId: "1"))
        })
        XCTContext.runActivity(named: """
            WHEN we encode the item
        """, block:{ _ in
            do {
                let encoded = try JSONEncoder().encode(navigation)
                print(String(data: encoded, encoding: .utf8) ?? "")
                XCTAssertNotNil(encoded)
                navigationDecoded = try JSONDecoder().decode(NotesNavigation.self, from: encoded)
                XCTAssertNotNil(navigationDecoded)
            } catch ( let e ) {
                XCTFail(e.localizedDescription)
            }
        })
        XCTContext.runActivity(named: """
            THEN it is correctly decoded
        """, block:{ _ in
            XCTAssertEqual(navigationDecoded, .folders👉list(listId: "1"))
        })
    }

    func testFoldersListNoteEncode() {
        let navigation: NotesNavigation = .folders👉🏻list👉note(listId: "1", noteId: "A")
        var navigationDecoded: NotesNavigation = .folders
        XCTContext.runActivity(named: """
            GIVEN we have a .foldersListNote navigation
        """, block:{ _ in
            XCTAssertEqual(navigation, .folders👉🏻list👉note(listId: "1", noteId: "A"))
        })
        XCTContext.runActivity(named: """
            WHEN we encode the item
        """, block:{ _ in
            do {
                let encoded = try JSONEncoder().encode(navigation)
                print(String(data: encoded, encoding: .utf8) ?? "")
                XCTAssertNotNil(encoded)
                navigationDecoded = try JSONDecoder().decode(NotesNavigation.self, from: encoded)
                XCTAssertNotNil(navigationDecoded)
            } catch ( let e ) {
                XCTFail(e.localizedDescription)
            }
        })
        XCTContext.runActivity(named: """
            THEN it is correctly decoded
        """, block:{ _ in
            XCTAssertEqual(navigationDecoded, .folders👉🏻list👉note(listId: "1", noteId: "A"))
        })
    }

}