//
//  Routing.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 28/11/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import Foundation

enum Navigation {
    case folders
    case folders👉list(listId:ListId)
    case folders👉🏻list👉note(listId:ListId, noteId:NoteId)
}


protocol Navigator {

    // Information
    var currentNavigation : Navigation { get }

    // Deep link
    func navigate(to:Navigation, completion: () -> Void)

    // TODO: Normal navigation

    // TODO: Dependency based navigation
}
