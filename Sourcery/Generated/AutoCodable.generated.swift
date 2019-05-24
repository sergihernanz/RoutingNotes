// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension MainNotesNavigation {

    enum CodingKeys: String, CodingKey {
        case main
        case modal
        case onTopOf
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.main), try container.decodeNil(forKey: .main) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .main)
            let associatedValue0 = try associatedValues.decode(NotesNavigation.self)
            self = .main(associatedValue0)
            return
        }
        if container.allKeys.contains(.modal), try container.decodeNil(forKey: .modal) == false {
            let associatedValues = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .modal)
            let modal = try associatedValues.decode(NotesModalNavigation.self, forKey: .modal)
            let onTopOf = try associatedValues.decode(NotesNavigation.self, forKey: .onTopOf)
            self = .modal(modal: modal, onTopOf: onTopOf)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .main(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .main)
            try associatedValues.encode(associatedValue0)
        case let .modal(modal, onTopOf):
            var associatedValues = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .modal)
            try associatedValues.encode(modal, forKey: .modal)
            try associatedValues.encode(onTopOf, forKey: .onTopOf)
        }
    }

}

extension NotesModalNavigation {

    enum CodingKeys: String, CodingKey {
        case receivedNotificationOnForeground
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.receivedNotificationOnForeground), try container.decodeNil(forKey: .receivedNotificationOnForeground) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .receivedNotificationOnForeground)
            let associatedValue0 = try associatedValues.decode(NotesNavigation.self)
            self = .receivedNotificationOnForeground(associatedValue0)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .receivedNotificationOnForeground(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .receivedNotificationOnForeground)
            try associatedValues.encode(associatedValue0)
        }
    }

}

extension NotesNavigation {

    enum CodingKeys: String, CodingKey {
        case folders
        case folders👉list
        case folders👉list👉note
        case listId
        case noteId
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.folders), try container.decodeNil(forKey: .folders) == false {
            self = .folders
            return
        }
        if container.allKeys.contains(.folders👉list), try container.decodeNil(forKey: .folders👉list) == false {
            let associatedValues = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .folders👉list)
            let listId = try associatedValues.decode(ListId.self, forKey: .listId)
            self = .folders👉list(listId: listId)
            return
        }
        if container.allKeys.contains(.folders👉list👉note), try container.decodeNil(forKey: .folders👉list👉note) == false {
            let associatedValues = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .folders👉list👉note)
            let listId = try associatedValues.decode(ListId.self, forKey: .listId)
            let noteId = try associatedValues.decode(NoteId.self, forKey: .noteId)
            self = .folders👉list👉note(listId: listId, noteId: noteId)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .folders:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .folders)
        case let .folders👉list(listId):
            var associatedValues = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .folders👉list)
            try associatedValues.encode(listId, forKey: .listId)
        case let .folders👉list👉note(listId, noteId):
            var associatedValues = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .folders👉list👉note)
            try associatedValues.encode(listId, forKey: .listId)
            try associatedValues.encode(noteId, forKey: .noteId)
        }
    }

}
