//
//  ListVC+Routing.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 18/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import Foundation
import UIKit

extension ListVC: Navigatable {

    typealias InputType = ListId
    typealias OutputType = NoteId

    var navigationInput: ListId {
        return listInput
    }

    var navigationOutput: NoteId? {
        guard let selectedIP = tableView.indexPathForSelectedRow else {
            return nil
        }
        return notes[selectedIP.row].noteId
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        do {
            try navigator.navigateToDetail(noteId: note.noteId, animated: true) { (_: Bool) in }
        } catch let navigateToListError {
            fatalError(navigateToListError.localizedDescription)
        }
    }
}

fileprivate extension NotesNavigation {
    func navigationToDetail(noteId: ListId) throws -> NotesNavigation {
        switch self {
        case .folders👉list(listId: let listId):
            return .folders👉list👉note(listId: listId, noteId: noteId)
        default:
            throw NavigationError.invalidDestinationForCurrentNavigation(currentNavigation: self,
                                                                         destinationDescription: "Note \(noteId)")
        }
    }
}

fileprivate extension Navigator where NavigationType == NotesNavigation {
    func navigateToDetail(noteId: NoteId, animated: Bool, completion: @escaping (_ cancelled: Bool) -> Void) throws {
        let newNavigation = try currentNavigation.navigationToDetail(noteId: noteId)
        navigate(to: newNavigation, animated: animated, completion: completion)
    }
}
