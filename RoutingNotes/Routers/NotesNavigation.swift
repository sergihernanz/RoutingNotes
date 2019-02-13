//
//  NotesNavigation.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 28/11/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import Foundation

enum NotesNavigation : Navigation {

    init() {
        self = .folders
    }

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

extension NotesNavigation: Codable {

    fileprivate enum CodingKeys: CodingKey {
        case folders
        case foldersList
        case foldersListNote
        enum FoldersListCodingKeys: CodingKey {
            case listId
        }
        enum FoldersListNoteCodingKeys: CodingKey {
            case listId
            case noteId
        }
    }

    init(from decoder: Decoder) throws {
        let mainContainer = try decoder.container(keyedBy: CodingKeys.self)
        if mainContainer.contains(.folders) {
            self = .folders
        } else if mainContainer.contains(.foldersList) {
            let foldersListContainer = try mainContainer.nestedContainer(keyedBy: CodingKeys.FoldersListCodingKeys.self,
                                                                         forKey: .foldersList)
            let listId = try foldersListContainer.decode(String.self, forKey: .listId)
            self = .folders👉list(listId: listId)
        } else if mainContainer.contains(.foldersListNote) {
            let foldersListNoteContainer = try mainContainer.nestedContainer(keyedBy: CodingKeys.FoldersListNoteCodingKeys.self,
                                                                             forKey: .foldersListNote)
            let listId = try foldersListNoteContainer.decode(String.self, forKey: .listId)
            let noteId = try foldersListNoteContainer.decode(String.self, forKey: .noteId)
            self = .folders👉🏻list👉note(listId: listId, noteId: noteId)
        } else {
            assertionFailure("Incorrectly decoded instance")
            self = .folders
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .folders:
            try container.encodeNil(forKey: .folders)
        case .folders👉list(listId: let listId):
            var associatedValuesContainer = container.nestedContainer(keyedBy: CodingKeys.FoldersListCodingKeys.self,
                                                                      forKey: .foldersList)
            try associatedValuesContainer.encode(listId, forKey: .listId)
        case .folders👉🏻list👉note(listId: let listId, noteId: let noteId):
            var associatedValuesContainer = container.nestedContainer(keyedBy: CodingKeys.FoldersListNoteCodingKeys.self,
                                                                      forKey: .foldersListNote)
            try associatedValuesContainer.encode(listId, forKey: .listId)
            try associatedValuesContainer.encode(noteId, forKey: .noteId)
        }
    }

}
