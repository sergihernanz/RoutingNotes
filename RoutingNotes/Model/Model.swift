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

    func fetch<T>(id:I) throws -> T?
    func fetch<T>(request:R) throws -> [T]

}

fileprivate class _AnyModelContextBase<I,R>: ModelContext {
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
fileprivate final class _AnyModelContextBox<Concrete: ModelContext>: _AnyModelContextBase<Concrete.I,Concrete.R> {
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

final class AnyModelContext<I,R>: ModelContext {
    private let box: _AnyModelContextBase<I,R>
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
    let predicate:NSPredicate?
    let sortDescriptors:[NSSortDescriptor]
    let range:ClosedRange<Int>

    static var emptyPredicate : NotesModelFetchRequest {
        return NotesModelFetchRequest(predicate:nil,
                                      sortDescriptors:[],
                                      range:0...0)
    }
}
typealias OrdersModelContext = AnyModelContext<NotesModelId,NotesModelFetchRequest>


// Notes model
enum NotesModelId : Equatable {
    // These below are just trying to emulate other systems different than core data, or entity+id search based queries
    case list(ListId)
    case note(NoteId)
}
protocol NotesModelBase {
    var notesModelId : NotesModelId { get }
}
func ==(lhs: NotesModelBase, rhs: NotesModelBase) -> Bool {
    return lhs.notesModelId == rhs.notesModelId
}

typealias ListId = String
protocol List : NotesModelBase {
    var listId : ListId { get }
    var name : String {get set}
    func fetchNotes(ctxt:AnyModelContext<NotesModelId,NotesModelFetchRequest>) throws -> [Note]
}

typealias NoteId = String
protocol Note : NotesModelBase {
    var noteId : NoteId { get }
    var title : String {get set}
    var modifiedDate : Date {get set}
    var content : String {get set}
    func fetchList(ctxt:AnyModelContext<NotesModelId,NotesModelFetchRequest>) throws -> List
}

// Implementations
struct ListUserDefaults : List, Codable {
    var notesModelId : NotesModelId { return .list(listId) }
    var listId: ListId
    var name: String

    func fetchNotes(ctxt: AnyModelContext<NotesModelId, NotesModelFetchRequest>) throws -> [Note] {
        let predicate = NSPredicate(format: "listId = %@", listId)
        let req = NotesModelFetchRequest(predicate: predicate,
                                         sortDescriptors: [],
                                         range: 0...0)
        return try ctxt.fetch(request: req)
    }
}
struct NoteUserDefaults : Note, Codable {
    var notesModelId : NotesModelId { return .note(noteId) }
    var noteId: NoteId
    var title: String
    var modifiedDate: Date
    var content: String

    var listId : ListId
    func fetchList(ctxt: AnyModelContext<NotesModelId, NotesModelFetchRequest>) throws -> List {
        return try ctxt.fetch(id:.list(listId))!
    }
}
class UserDefaultsOrdersModelContext : ModelContext {

    typealias I = NotesModelId
    typealias R = NotesModelFetchRequest

    let persistenceName : String
    init(persistenceName:String) {
        self.persistenceName = persistenceName
        loadMockData()
    }

    private func persistenceKey(type:String) -> String {
        return "\(persistenceName)_\(type)"
    }

    func fetch<T>(id: NotesModelId) throws -> T? {
        let key = persistenceKey(type:String(describing: T.self))
        switch id {
        case .list(let listId):
            guard let listData = UserDefaults.standard.data(forKey:key ) else {
                return nil
            }
            let decoder = JSONDecoder()
            let lists = try decoder.decode([ListUserDefaults].self, from: listData)
            return lists.filter({ (list) -> Bool in list.listId == listId }).first as? T
        case .note(let noteId):
            guard let noteData = UserDefaults.standard.data(forKey:key ) else {
                return nil
            }
            let decoder = JSONDecoder()
            let notes = try decoder.decode([NoteUserDefaults].self, from: noteData)
            return notes.filter({ (note) -> Bool in note.noteId == noteId }).first as? T
        }
    }

    func fetch<T>(request: NotesModelFetchRequest) throws -> [T] {
        fatalError()
    }

    func fetch(request: NotesModelFetchRequest) throws -> [Note] {
        let udNotes = try fetch(request: request) as [NoteUserDefaults]
        return udNotes as [Note]
    }
    func fetch(request: NotesModelFetchRequest) throws -> [List] {
        let udLists = try fetch(request: request) as [ListUserDefaults]
        return udLists as [List]
    }
    func fetch<T>(request: NotesModelFetchRequest) throws -> [T] where T: Codable & NotesModelBase {
        let key = persistenceKey(type:String(describing: T.self))
        guard let data = UserDefaults.standard.value(forKey:key) as? Data else {
            return [];
        }
        return try JSONDecoder().decode(Array<T>.self, from: data)
    }


    func loadMockData() {
        let lists = [
            ListUserDefaults(listId: "1", name: "List 1"),
            ListUserDefaults(listId: "2", name: "List 2"),
            ListUserDefaults(listId: "3", name: "List 3"),
        ];
        let notes = [
        NoteUserDefaults(noteId: "A",
                         title: "Note A",
                         modifiedDate: Date(),
                         content: "Note A content",
                         listId: "1"),
        NoteUserDefaults(noteId: "B",
                         title: "Note B",
                         modifiedDate: Date(),
                         content: "Note B content",
                         listId: "2"),
        NoteUserDefaults(noteId: "C",
                         title: "Note C",
                         modifiedDate: Date(),
                         content: "Note C content",
                         listId: "2"),
        NoteUserDefaults(noteId: "D",
                         title: "Note D",
                         modifiedDate: Date(),
                         content: "Note D content",
                         listId: "2"),
        ];
        let encoder = JSONEncoder()
        do {
            let listsKey = persistenceKey(type:String(describing: ListUserDefaults.self))
            try UserDefaults.standard.setValue(encoder.encode(lists), forKeyPath: listsKey)
            let notesKey = persistenceKey(type:String(describing: NoteUserDefaults.self))
            try UserDefaults.standard.setValue(encoder.encode(notes), forKeyPath: notesKey)
        } catch ( _ ) {
            fatalError()
        }
    }
}
