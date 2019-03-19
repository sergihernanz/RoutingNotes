//
//  NotesNavigation.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 28/11/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import Foundation

enum MainNotesNavigation {
    case main(NotesNavigation)
    case modal(NotesModalNavigation, onTopOf: NotesNavigation)
}

enum NotesModalNavigation {
    case receivedNotificationOnForeground(NotesNavigation)
}

enum NotesNavigation {
    case folders
    case folders👉list(listId: ListId)
    case folders👉list👉note(listId: ListId, noteId: NoteId)
}

extension MainNotesNavigation: Navigation {

    init() {
        self = .main(.folders)
    }

    func pop() -> MainNotesNavigation? {
        switch self {
        case .modal(_, onTopOf: let notesNavigation):
            return .main(notesNavigation)
        case .main(let notesNavigation):
            guard let poppedNotesNavigation = notesNavigation.pop() else {
                return nil
            }
            return .main(poppedNotesNavigation)
        }
    }

    var notesNavigation: NotesNavigation {
    switch self {
    case .main(let notesNavigation), .modal(_, onTopOf: let notesNavigation):
        return notesNavigation
    }
    }
}

extension NotesModalNavigation: Navigation {

    init() {
        self = .receivedNotificationOnForeground(.folders)
    }

    func  pop() -> NotesModalNavigation? {
        return nil
    }

}

extension NotesNavigation: Navigation {

    init() {
        self = .folders
    }

    func pop() -> NotesNavigation? {
        switch self {
        case .folders👉list👉note(listId: let listId, noteId:_):
            return .folders👉list(listId: listId)
        case .folders👉list(listId: _):
            return .folders
        case .folders:
            return nil
        }
    }
}
