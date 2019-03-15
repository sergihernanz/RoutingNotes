//
//  Model.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 09/12/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import Foundation

// Model context
protocol ModelContext {

    associatedtype I
    associatedtype R

    func fetch<T>(id: I) throws -> T?
    func fetch<T>(request: R) throws -> [T]

}

private class _AnyModelContextBase<I, R>: ModelContext {
    init() {
        guard type(of: self) != _AnyModelContextBase.self else {
            fatalError("_AnyModelContextBase<I,R> instances can not be created, create a subclass instance instead")
        }
    }
    func fetch<T>(id: I) throws -> T? {
        fatalError("Method must be overriden")
    }
    func fetch<T>(request: R) throws -> [T] {
        fatalError("Method must be overriden")
    }
}
fileprivate final class _AnyModelContextBox<Concrete: ModelContext>: _AnyModelContextBase<Concrete.I, Concrete.R> {
    // variable used since we're calling mutating functions
    var concrete: Concrete
    init(_ concrete: Concrete) {
        self.concrete = concrete
    }
    override func fetch<T>(id: I) throws -> T? {
        return try concrete.fetch(id: id)
    }
    override func fetch<T>(request: R) throws -> [T] {
        return try concrete.fetch(request: request)
    }
}

final class AnyModelContext<I, R>: ModelContext {
    private let box: _AnyModelContextBase<I, R>
    // Initializer takes our concrete implementer of ModelContext i.e. ListModelContext
    init<Concrete: ModelContext>(_ concrete: Concrete) where Concrete.I == I, Concrete.R == R {
        box = _AnyModelContextBox(concrete)
    }
    func fetch<T>(id: I) throws -> T? {
        return try box.fetch(id: id)
    }
    func fetch<T>(request: R) throws -> [T] {
        return try box.fetch(request: request)
    }
}

struct NotesModelFetchRequest {
    var filter: ((Any) -> Bool)?
    let sortDescriptors: [NSSortDescriptor]
    let range: ClosedRange<Int>

    static var emptyPredicate: NotesModelFetchRequest {
        return NotesModelFetchRequest(filter: nil,
                                      sortDescriptors: [],
                                      range: 0...0)
    }
}
typealias NotesModelContext = AnyModelContext<NotesModelId, NotesModelFetchRequest>

// Notes model
enum NotesModelId: Equatable {
    // These below are just trying to emulate other systems different than core data, or entity+id search based queries
    case list(ListId)
    case note(NoteId)
}
protocol NotesModelBase {
    var notesModelId: NotesModelId { get }
}
func == (lhs: NotesModelBase, rhs: NotesModelBase) -> Bool {
    return lhs.notesModelId == rhs.notesModelId
}

typealias ListId = String
protocol List: NotesModelBase {
    var listId: ListId { get }
    var name: String {get set}
    func fetchNotes(ctxt: AnyModelContext<NotesModelId, NotesModelFetchRequest>) throws -> [Note]
}

typealias NoteId = String
protocol Note: NotesModelBase {
    var noteId: NoteId { get }
    var title: String {get set}
    var modifiedDate: Date {get set}
    var content: String {get set}
    var listId: ListId {get set}
    func fetchList(ctxt: AnyModelContext<NotesModelId, NotesModelFetchRequest>) throws -> List
}

// Implementations
struct ListUserDefaults: List, Codable {
    var notesModelId: NotesModelId { return .list(listId) }
    var listId: ListId
    var name: String

    func fetchNotes(ctxt: AnyModelContext<NotesModelId, NotesModelFetchRequest>) throws -> [Note] {
        let req = NotesModelFetchRequest(filter: { return ($0 as! Note).listId == self.listId },
                                         sortDescriptors: [],
                                         range: 0...0)
        return try ctxt.fetch(request: req)
    }
}
struct NoteUserDefaults: Note, Codable {
    var notesModelId: NotesModelId { return .note(noteId) }
    var noteId: NoteId
    var title: String
    var modifiedDate: Date
    var content: String
    var listId: ListId
    func fetchList(ctxt: AnyModelContext<NotesModelId, NotesModelFetchRequest>) throws -> List {
        return try ctxt.fetch(id: .list(listId))!
    }
}
class UserDefaultsOrdersModelContext: ModelContext {

    typealias I = NotesModelId
    typealias R = NotesModelFetchRequest

    let persistenceName: String
    init(persistenceName: String) {
        self.persistenceName = persistenceName
    }

    internal func persistenceKey(type: String) -> String {
        return "\(persistenceName)_\(type)"
    }

    func fetch<T>(id: NotesModelId) throws -> T? {
        switch id {
        case .list(let listId):
            let req = NotesModelFetchRequest(filter: { return ($0 as! List).listId == listId },
                                             sortDescriptors: [],
                                             range: 0...0)
            let lists = try fetch(request: req) as [ListUserDefaults]
            return lists.first as? T
        case .note(let noteId):
            let req = NotesModelFetchRequest(filter: { return ($0 as! Note).noteId == noteId },
                                             sortDescriptors: [],
                                             range: 0...0)
            let notes = try fetch(request: req) as [NoteUserDefaults]
            return notes.first as? T
        }
    }

    func fetch<T>(request: NotesModelFetchRequest) throws -> [T] {
        switch String(describing: T.self) {
        case String(describing: Note.self):
            let udNotes = try fetch(request: request) as [NoteUserDefaults]
            return udNotes as! [T]
        case String(describing: List.self):
            let udLists = try fetch(request: request) as [ListUserDefaults]
            return udLists as! [T]
        default:
            fatalError()
        }
    }

    func fetch<T>(request: NotesModelFetchRequest) throws -> [T] where T: Codable & NotesModelBase {
        let key = persistenceKey(type: String(describing: T.self))
        guard let data = UserDefaults.standard.value(forKey: key) as? Data else {
            return []
        }
        let ret = try JSONDecoder().decode(Array<T>.self, from: data)
        guard let filter = request.filter else {
            return ret
        }
        return ret.filter(filter)
    }

}
