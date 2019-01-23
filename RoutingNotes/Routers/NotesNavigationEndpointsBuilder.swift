//
//  NotesNavigationEndpointsBuilder.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 23/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit

class NotesNavigationEndpointsBuilder: NavigationEndpointsBuilder {

    func buildEndpointRoutableViewController(forNavigationEndpoint:NotesNavigation,
                                             navigator: NotesStatefulNavigator,
                                             model: NotesModelContext) -> UIViewController {
        switch forNavigationEndpoint {
        case .folders:
            return FoldersVC(navigator: navigator, model:model, navigationInput:())
        case .folders👉list(let listId):
            return ListVC(navigator: navigator, model:model, navigationInput: listId)
        case .folders👉🏻list👉note(_, let noteId):
            return NoteVC(navigator: navigator, model:model, navigationInput: noteId)
        }
    }

    func correctlyConfigured(viewController: UIViewController, forNavigation: NotesNavigation) -> Bool {
        switch forNavigation {
        case .folders:
            return viewController is FoldersVC
        case .folders👉list(let listId):
            if let listVC = viewController as? ListVC,
                listVC.navigationInput == listId {
                return true
            }
        case .folders👉🏻list👉note(_, let noteId):
            if let noteVC = viewController as? NoteVC, noteVC.navigationInput == noteId {
                return true
            }
        }
        return false
    }

}
