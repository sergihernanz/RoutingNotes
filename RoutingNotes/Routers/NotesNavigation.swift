//
//  NotesNavigation.swift
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
