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

    var model : OrdersModelContext!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        model = populateMockModel()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    fileprivate func populateMockModel() -> OrdersModelContext {
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
            let anyContext = OrdersModelContext(model)
            let notes : [Note] = try anyContext.fetch(request: NotesModelFetchRequest.emptyPredicate)
            let lists : [List] = try anyContext.fetch(request: NotesModelFetchRequest.emptyPredicate)
            assert(notes.count>0)
            assert(lists.count>0)
        } catch (_) {
            fatalError()
        }
        return OrdersModelContext(model)
    }

    func testMainFoldersScreenRoute() {
        var navigator: NavigatorImpl!
        XCTContext.runActivity(named: """
            GIVEN we have a valid router configured for the default route
                  AND configured with a mock model
        """, block:{ _ in
            let model = populateMockModel()
            navigator = NavigatorImpl(model: model)
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
            navigator = NavigatorImpl(model: model)
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
            navigator.navigate(to: .folders👉list(listId: "1"), completion: {
                exp.fulfill()
            })
            RunLoop.current.run(until: Date())
            wait(for: [exp], timeout: 2)
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
