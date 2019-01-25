//
//  TestsEndpointsBuilder.swift
//  RoutingNotesTests
//
//  Created by Sergi Hernanz on 21/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit
//@testable import RoutingNotes

class TestsEndpointsBuilder: NavigationEndpointsBuilder {

    typealias NavigationType = NotesNavigation
    typealias NavigatorType = NotesStatefulNavigator
    typealias ModelType = NotesModelContext

    func buildEndpoint(forNavigationEndpoint:NotesNavigation,
                                             navigator: NotesStatefulNavigator,
                                             model: NotesModelContext) -> UIViewController {
        switch forNavigationEndpoint {
        case .folders:
            let vc = NavigationTestVC(navigator: navigator, model: model, navigationInput: ())
            vc.title = "Folders"
            return vc
        case .folders👉list(let listId):
            let vc = NavigationTestVC(navigator: navigator, model: model, navigationInput: listId)
            vc.title = "List \(listId)"
            return vc
        case .folders👉🏻list👉note(_, let noteId):
            let vc = NavigationTestVC(navigator: navigator, model: model, navigationInput: noteId)
            vc.title = "Note \(noteId)"
            return vc
        }
    }

    func isCorrectlyConfigured(viewController: UIViewController, forNavigation: NotesNavigation) -> Bool {
        guard let testVC = viewController as? NavigationTestVC else {
            fatalError()
        }
        switch forNavigation {
        case .folders:
            return testVC.title == "Folders"
        case .folders👉list(let listId):
            return testVC.title == "List \(listId)"
        case .folders👉🏻list👉note(_, let noteId):
            return testVC.title == "Note \(noteId)"
        }
    }

}
