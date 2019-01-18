//
//  Routing.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 28/11/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import Foundation

enum Navigation : Equatable {
    case folders
    case folders👉list(listId:ListId)
    case folders👉🏻list👉note(listId:ListId, noteId:NoteId)
}

enum NavigationError : Error {
    case invalidDestinationForCurrentNavigation(currentNavigation:Navigation, destinationDescription:String)

    var localizedDescription: String {
        switch self {
        case .invalidDestinationForCurrentNavigation(let currentNavigation, let destinationDescription):
            return "Current navigation (\(currentNavigation) does not support navigating to \(destinationDescription)"
        }
    }
}


import UIKit

protocol Navigator {

    // Root viewcontroller to be presented on a VC hierarchy
    var rootViewController: UIViewController { get }

    // Information
    var currentNavigation : Navigation { get }

    // Deep link
    func navigate(to: Navigation, animated: Bool, completion: @escaping (_ cancelled: Bool) -> Void)

    // TODO: Normal navigation

    // TODO: Dependency based navigation
}
