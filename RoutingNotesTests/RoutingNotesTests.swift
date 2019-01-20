//
//  RoutingNotesTests.swift
//  RoutingNotesTests
//
//  Created by Sergi Hernanz on 28/11/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import XCTest
@testable import RoutingNotes

class RoutingNotesTests: XCTestCase {

    var model : NotesModelContext!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        model = populateMockModel()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    fileprivate func populateMockModel() -> NotesModelContext {
        let model = MockUDOrdersModelContext(persistenceName: "test")
        do {
            let notes : [Note] = try model.fetch(request: NotesModelFetchRequest.emptyPredicate)
            let lists : [List] = try model.fetch(request: NotesModelFetchRequest.emptyPredicate)
            assert(notes.count>0)
            assert(lists.count>0)
        } catch (_) {
            fatalError()
        }
        do {
            let anyContext = NotesModelContext(model)
            let notes : [Note] = try anyContext.fetch(request: NotesModelFetchRequest.emptyPredicate)
            let lists : [List] = try anyContext.fetch(request: NotesModelFetchRequest.emptyPredicate)
            assert(notes.count>0)
            assert(lists.count>0)
        } catch (_) {
            fatalError()
        }
        return NotesModelContext(model)
    }

    func testMainFoldersScreenRoute() {
        var navigator: NavigatorImpl!
        XCTContext.runActivity(named: """
            GIVEN we have a valid router configured for the default route
                  AND configured with a mock model
        """, block:{ _ in
            let model = populateMockModel()
            let endpointsBuilder = NotesNavigationEndpointsBuilder(model: model)
            navigator = NavigatorImpl(model: model, endpointsBuilder: endpointsBuilder)
            XCTAssertNotNil(navigator)
        })
        var rootVCTester: UIWindowRootViewControllerTester<UIViewController>!
        XCTContext.runActivity(named: """
            WHEN we present it on a valid window
        """, block:{ _ in
            let mainVC = navigator.rootViewController
            rootVCTester = UIWindowRootViewControllerTester(viewController: mainVC)
            XCTAssertNotNil(rootVCTester)
            XCTAssertNotNil(rootVCTester.rootWindow)
        })
        XCTContext.runActivity(named: """
            THEN it displays the right array of lists saved on the mock model
        """, block:{ _ in
            let img = rootVCTester.rootWindow.orders_takeSnapshot()
            let sshot = XCTAttachment(image:img)
            self.add(sshot)
            XCTAssertTrue(rootVCTester.rootWindow.allLabels(text: "List 1").count == 1)
            XCTAssertTrue(rootVCTester.rootWindow.allLabels(text: "1 notes").count == 1)
            XCTAssertTrue(rootVCTester.rootWindow.allLabels(text: "List 2").count == 1)
            XCTAssertTrue(rootVCTester.rootWindow.allLabels(text: "3 notes").count == 1)
            XCTAssertTrue(rootVCTester.rootWindow.allLabels(text: "List 3").count == 1)
            XCTAssertTrue(rootVCTester.rootWindow.allLabels(text: "0 notes").count == 1)
        })
    }

    func testDeepLinkToList() {
        var navigator: NavigatorImpl!
        XCTContext.runActivity(named: """
            GIVEN we have a valid router configured for the default route
                  AND configured with a mock model
        """, block:{ _ in
            let model = populateMockModel()
            let endpointsBuilder = NotesNavigationEndpointsBuilder(model: model)
            navigator = NavigatorImpl(model: model, endpointsBuilder: endpointsBuilder)
            XCTAssertNotNil(navigator)
        })
        var rootVCTester: UIWindowRootViewControllerTester<UIViewController>!
        XCTContext.runActivity(named: """
            WHEN we deep Link to a list id AND present it on a valid window
        """, block:{ _ in
            let mainVC = navigator.rootViewController
            rootVCTester = UIWindowRootViewControllerTester(viewController: mainVC)
            RunLoop.current.run(until: Date())
            XCTAssertNotNil(rootVCTester)
            XCTAssertNotNil(rootVCTester.rootWindow)
            
            let exp = expectation(description: "deepLinkToList")
            navigator.navigate(to: .folders👉list(listId: "1"), animated: true,  completion: { (cancelled: Bool) in
                exp.fulfill()
            })
            RunLoop.current.run(until: Date())
            wait(for: [exp], timeout: 6)
            XCTAssertEqual(navigator.currentNavigation, .folders👉list(listId: "1"))
        })
        XCTContext.runActivity(named: """
            THEN it displays the list with the right array of notes saved on the mock model
        """, block:{ _ in
            let img = rootVCTester.rootWindow.orders_takeSnapshot()
            let sshot = XCTAttachment(image:img)
            self.add(sshot)
            XCTAssertTrue(rootVCTester.rootWindow.allLabels(text: "List 1").count == 1)
            XCTAssertTrue(rootVCTester.rootWindow.allLabels(text: "Note A").count == 1)
        })
    }

    func testCallNavigateWithoutWaitingForCompletion() {
        var navigator: NavigatorImpl!
        XCTContext.runActivity(named: """
            GIVEN we have a valid router configured for the default route
                  AND configured with a mock model
        """, block:{ _ in
            let model = populateMockModel()
            let endpointsBuilder = NotesNavigationEndpointsBuilder(model: model)
            navigator = NavigatorImpl(model: model, endpointsBuilder: endpointsBuilder)
            XCTAssertNotNil(navigator)
        })
        var rootVCTester: UIWindowRootViewControllerTester<UIViewController>!
        XCTContext.runActivity(named: """
            WHEN we deep Link to a list id AND to a noteId before first navigate ends AND present it on a valid window
        """, block:{ _ in
            let mainVC = navigator.rootViewController
            rootVCTester = UIWindowRootViewControllerTester(viewController: mainVC)
            RunLoop.current.run(until: Date())
            XCTAssertNotNil(rootVCTester)
            XCTAssertNotNil(rootVCTester.rootWindow)

            let listExp = expectation(description: "deepLinkToList")
            navigator.navigate(to: .folders👉list(listId: "1"), animated: true, completion: { (cancelled: Bool) in
                XCTAssertTrue(cancelled)
                listExp.fulfill()
            })
            let noteExp = expectation(description: "deepLinkToNote")
            navigator.navigate(to: .folders👉🏻list👉note(listId: "1", noteId: "A"), animated: true, completion: { (cancelled: Bool) in
                XCTAssertFalse(cancelled)
                noteExp.fulfill()
            })
            RunLoop.current.run(until: Date())
            wait(for: [listExp, noteExp], timeout: 6)
            XCTAssertEqual(navigator.currentNavigation, .folders👉🏻list👉note(listId: "1", noteId: "A"))
        })
        XCTContext.runActivity(named: """
            THEN it displays the note detail
        """, block:{ _ in
            let img = rootVCTester.rootWindow.orders_takeSnapshot()
            let sshot = XCTAttachment(image:img)
            self.add(sshot)
            XCTAssertTrue(rootVCTester.rootWindow.allLabels(text: "Note A").count == 1)
        })
    }

    func testCallSameNavigateWithoutWaitingForCompletion() {
        var navigator: NavigatorImpl!
        XCTContext.runActivity(named: """
            GIVEN we have a valid router configured for the default route
                  AND configured with a mock model
        """, block:{ _ in
            let model = populateMockModel()
            let endpointsBuilder = NotesNavigationEndpointsBuilder(model: model)
            navigator = NavigatorImpl(model: model, endpointsBuilder: endpointsBuilder)
            XCTAssertNotNil(navigator)
        })
        var rootVCTester: UIWindowRootViewControllerTester<UIViewController>!
        XCTContext.runActivity(named: """
            WHEN we deep Link to a list id AND to a noteId before first navigate ends AND present it on a valid window
        """, block:{ _ in
            let mainVC = navigator.rootViewController
            rootVCTester = UIWindowRootViewControllerTester(viewController: mainVC)
            RunLoop.current.run(until: Date())
            XCTAssertNotNil(rootVCTester)
            XCTAssertNotNil(rootVCTester.rootWindow)

            let noteExp1 = expectation(description: "deepLinkToNote1")
            navigator.navigate(to: .folders👉🏻list👉note(listId: "1", noteId: "A"), animated: true, completion: { (cancelled: Bool) in
                XCTAssertFalse(cancelled)
                noteExp1.fulfill()
            })
            let noteExp2 = expectation(description: "deepLinkToNote2")
            navigator.navigate(to: .folders👉🏻list👉note(listId: "1", noteId: "A"), animated: true, completion: { (cancelled: Bool) in
                XCTAssertFalse(cancelled)
                noteExp2.fulfill()
            })
            RunLoop.current.run(until: Date())
            wait(for: [noteExp1, noteExp2], timeout: 6)
            XCTAssertEqual(navigator.currentNavigation, .folders👉🏻list👉note(listId: "1", noteId: "A"))
        })
        XCTContext.runActivity(named: """
            THEN it displays the note detail
        """, block:{ _ in
            let img = rootVCTester.rootWindow.orders_takeSnapshot()
            let sshot = XCTAttachment(image:img)
            self.add(sshot)
            XCTAssertTrue(rootVCTester.rootWindow.allLabels(text: "Note A").count == 1)
        })
    }

    func testNavigateBackFromDetailToList() {
        var navigator: NavigatorImpl!
        XCTContext.runActivity(named: """
            GIVEN we have a valid router configured for the default route
                  AND configured with a mock model
        """, block:{ _ in
            let model = populateMockModel()
            let endpointsBuilder = NotesNavigationEndpointsBuilder(model: model)
            navigator = NavigatorImpl(model: model, endpointsBuilder: endpointsBuilder)
            XCTAssertNotNil(navigator)
        })
        var rootVCTester: UIWindowRootViewControllerTester<UIViewController>!
        XCTContext.runActivity(named: """
            WHEN we deep Link to a list id AND present it on a valid window
        """, block:{ _ in
            let mainVC = navigator.rootViewController
            rootVCTester = UIWindowRootViewControllerTester(viewController: mainVC)
            RunLoop.current.run(until: Date())
            XCTAssertNotNil(rootVCTester)
            XCTAssertNotNil(rootVCTester.rootWindow)

            let detailExp = expectation(description: "deepLinkToDetail")
            navigator.navigate(to: .folders👉🏻list👉note(listId: "1", noteId: "A"), animated: true,  completion: { (cancelled: Bool) in
                detailExp.fulfill()
            })
            RunLoop.current.run(until: Date())
            wait(for: [detailExp], timeout: 6)
            let listExp = expectation(description: "deepLinkToList")
            navigator.navigate(to: .folders👉list(listId: "1"), animated: true,  completion: { (cancelled: Bool) in
                listExp.fulfill()
            })
            RunLoop.current.run(until: Date())
            wait(for: [listExp], timeout: 6)
            XCTAssertEqual(navigator.currentNavigation, .folders👉list(listId: "1"))
        })
        XCTContext.runActivity(named: """
            THEN it displays the list with the right array of notes saved on the mock model
        """, block:{ _ in
            let img = rootVCTester.rootWindow.orders_takeSnapshot()
            let sshot = XCTAttachment(image:img)
            self.add(sshot)
            XCTAssertTrue(rootVCTester.rootWindow.allLabels(text: "List 1").count == 1)
            XCTAssertTrue(rootVCTester.rootWindow.allLabels(text: "Note A").count == 1)
        })
    }
}
