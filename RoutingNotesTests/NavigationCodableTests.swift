//
//  NavigationCodableTests.swift
//  RoutingNotesTests
//
//  Created by Sergi Hernanz on 13/02/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import XCTest
@testable import RoutingNotes

class NotesNavigationCodableTests: XCTestCase {

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

class ModalNotesNavigationCodableTests: XCTestCase {

    func testReceivedNotificationOnForeground() {
        let navigation: NotesModalNavigation = .receivedNotificationOnForeground(.folders)
        var navigationDecoded: NotesModalNavigation = .receivedNotificationOnForeground(.folders)
        XCTContext.runActivity(named: """
            GIVEN we have a .receivedNotificationOnForeground navigation
        """, block: { _ in
            XCTAssertEqual(navigation, .receivedNotificationOnForeground(.folders))
        })
        XCTContext.runActivity(named: """
            WHEN we encode the item
        """, block: { _ in
            do {
                let encoded = try JSONEncoder().encode(navigation)
                print(String(data: encoded, encoding: .utf8) ?? "")
                XCTAssertNotNil(encoded)
                navigationDecoded = try JSONDecoder().decode(NotesModalNavigation.self, from: encoded)
                XCTAssertNotNil(navigationDecoded)
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        })
        XCTContext.runActivity(named: """
            THEN it is correctly decoded
        """, block: { _ in
            XCTAssertEqual(navigationDecoded, .receivedNotificationOnForeground(.folders))
        })
    }
}

class NotesMainNavigationCodableTests: XCTestCase {

    func testMainFoldersEncode() {
        let navigation: MainNotesNavigation = .main(.folders)
        var navigationDecoded: MainNotesNavigation = .main(.folders)
        XCTContext.runActivity(named: """
            GIVEN we have a .main(.folders) navigation
        """, block: { _ in
            XCTAssertEqual(navigation, .main(.folders))
        })
        XCTContext.runActivity(named: """
            WHEN we encode the item
        """, block: { _ in
            do {
                let encoded = try JSONEncoder().encode(navigation)
                print(String(data: encoded, encoding: .utf8) ?? "")
                XCTAssertNotNil(encoded)
                navigationDecoded = try JSONDecoder().decode(MainNotesNavigation.self, from: encoded)
                XCTAssertNotNil(navigationDecoded)
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        })
        XCTContext.runActivity(named: """
            THEN it is correctly decoded
        """, block: { _ in
            XCTAssertEqual(navigationDecoded, .main(.folders))
        })
    }

    func testModalOnTopOfListEncode() {
        let navigation: MainNotesNavigation = .modal(modal: .receivedNotificationOnForeground(.folders), onTopOf:.folders👉list(listId: "List A"))
        var navigationDecoded: MainNotesNavigation = .modal(modal: .receivedNotificationOnForeground(.folders), onTopOf:.folders)
        XCTContext.runActivity(named: """
            GIVEN we have a .main(.folders) navigation
        """, block: { _ in
            XCTAssertEqual(navigation, .modal(modal: .receivedNotificationOnForeground(.folders), onTopOf:.folders👉list(listId: "List A")))
        })
        XCTContext.runActivity(named: """
            WHEN we encode the item
        """, block: { _ in
            do {
                let encoded = try JSONEncoder().encode(navigation)
                print(String(data: encoded, encoding: .utf8) ?? "")
                XCTAssertNotNil(encoded)
                navigationDecoded = try JSONDecoder().decode(MainNotesNavigation.self, from: encoded)
                XCTAssertNotNil(navigationDecoded)
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        })
        XCTContext.runActivity(named: """
            THEN it is correctly decoded
        """, block: { _ in
            XCTAssertEqual(navigationDecoded, .modal(modal: .receivedNotificationOnForeground(.folders), onTopOf:.folders👉list(listId: "List A")))
        })
    }
}
