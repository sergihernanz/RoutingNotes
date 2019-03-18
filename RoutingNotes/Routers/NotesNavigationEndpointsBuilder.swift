//
//  NotesNavigationEndpointsBuilder.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 23/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit

typealias NotesNavigationEndpointsBuilder = AnyNavigationEndpointsBuilder<MainNotesNavigation, NotesStatefulNavigator, NotesModelContext>

class NotesNavigationEndpointsBuilderImpl: TopNavigationItemBuilder {

    typealias NavigationType = MainNotesNavigation
    typealias NavigatorType = NotesStatefulNavigator
    typealias ModelType = NotesModelContext

    func buildTopItem(forNavigationEndpoint: MainNotesNavigation,
                      navigator: NotesStatefulNavigator,
                      model: NotesModelContext) -> UIViewController {
        switch forNavigationEndpoint {
        case .main(let notesNavigation):
            switch notesNavigation {
            case .folders:
                return FoldersVC(navigator: navigator, model: model, navigationInput: ())
            case .folders👉list(let listId):
                return ListVC(navigator: navigator, model: model, navigationInput: listId)
            case .folders👉list👉note(_, let noteId):
                return NoteVC(navigator: navigator, model: model, navigationInput: noteId)
            }
        case .modal(let modalNavigation, onTopOf: _):
            switch modalNavigation {
            case .receivedNotificationOnForeground:
                let alertVC = UIAlertController(title: "",
                                                message: "Check out XXX",
                                                preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Go there", style: .default, handler: { _ in
                    navigator.navigate(to: .main(.folders), animated: true) {_ in }
                }))
                alertVC.addAction(UIAlertAction(title: "Not now", style: .destructive, handler: nil))
                return alertVC
            }
        }
    }

    func isCorrectlyConfigured(viewController: UIViewController, forNavigation: MainNotesNavigation) -> Bool {
        switch forNavigation {
        case .main(let notesNavigation):
            switch notesNavigation {
            case .folders:
                return viewController is FoldersVC
            case .folders👉list(let listId):
                if let listVC = viewController as? ListVC,
                    listVC.navigationInput == listId {
                    return true
                }
            case .folders👉list👉note(_, let noteId):
                if let noteVC = viewController as? NoteVC, noteVC.navigationInput == noteId {
                    return true
                }
            }
        case .modal(let modalNavigation, onTopOf: _):
            switch modalNavigation {
            case .receivedNotificationOnForeground:
                if let foregroundNotificationAlert = viewController as? UIAlertController,
                   foregroundNotificationAlert.title == "Check out XXX" {
                    return true
                }
                return false
            }
        }
        return false
    }

}
