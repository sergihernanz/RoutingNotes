//
//  Routing.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 28/11/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import Foundation

enum NotesNavigation : Navigation {

    case folders
    case folders👉list(listId:ListId)
    case folders👉🏻list👉note(listId:ListId, noteId:NoteId)

    func pop() -> NotesNavigation? {
        switch self {
        case .folders👉🏻list👉note(listId: let listId, noteId:_):
            return .folders👉list(listId: listId)
        case .folders👉list(listId: _):
            return .folders
        case .folders:
            return nil
        }
    }
}

enum NavigationError : Error {
    case invalidDestinationForCurrentNavigation(currentNavigation:NotesNavigation, destinationDescription:String)

    var localizedDescription: String {
        switch self {
        case .invalidDestinationForCurrentNavigation(let currentNavigation, let destinationDescription):
            return "Current navigation (\(currentNavigation) does not support navigating to \(destinationDescription)"
        }
    }
}


import UIKit

protocol Navigator: class {

    associatedtype NavigationType

    // Root viewcontroller to be presented on a VC hierarchy
    var rootViewController: UIViewController { get }

    // Information
    var currentNavigation : NavigationType { get }

    // Deep link
    func navigate(to: NavigationType, animated: Bool, completion: @escaping (_ cancelled: Bool) -> Void)

    // TODO: Normal navigation

    // TODO: Dependency based navigation
}
