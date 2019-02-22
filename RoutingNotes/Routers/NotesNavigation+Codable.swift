//
//  NotesNavigation+Codable.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 22/02/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import Foundation


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

extension NotesNavigation {

    func toJSONString() -> String? {
        do {
            let data = try JSONEncoder().encode(self)
            return String(data: data, encoding: .utf8)
        } catch let e {
            fatalError(e.localizedDescription)
        }
    }

    init?(jsonString: String) {
        do {
            guard let data = jsonString.data(using: .utf8) else {
                return nil
            }
            self = try JSONDecoder().decode(NotesNavigation.self, from: data)
        } catch {
            return nil
        }
    }
}
