//
//  Repository.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 01/12/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import Foundation

protocol List {
    var listId : ListId { get }
    var name : String {get set}
}

protocol Note {
    var noteId : NoteId { get }
    var title : String {get set}
    var modifiedDate : Date {get set}
    var content : NSAttributedString {get set}
}

protocol Repository {

    associatedtype T
    associatedtype I

    func getAll() -> [T]
    func get( identifier:I ) -> T?
    func create( a:T ) -> Bool
    func update( a:T ) -> Bool
    func delete( a:T ) -> Bool

}

protocol RepositoryFactory {
    func getListsRepository() -> AnyRepository<List,ListId>
    func getNotesRepository() -> AnyRepository<Note,NoteId>
}


protocol Data {

    associatedtype T
    associatedtype I

    func fetch(id:I) -> T
    func fetch(predicate:NSPredicate, sortDescriptors:[NSSortDescriptor], range:NSRange?) -> [T]

    //var mutableData : MutableData { get }

}

//protocol MutableData {

    //associatedtype T

    //func fetch(id:I) -> T
    //func fetch(predicate:NSPredicate, sortDescriptors:[NSSortDescriptor], range:NSRange?) -> [T]
    //func create( a:T ) -> Bool
    //func update( a:T ) -> Bool
    //func delete( a:T ) -> Bool
//}


fileprivate class _AnyRepositoryBase<T,I>: Repository {

    init() {
        guard type(of: self) != _AnyRepositoryBase.self else {
            fatalError("_AnyRepositoryBase<T,I> instances can not be created, create a subclass instance instead")
        }
    }

    func getAll() -> [T] {
        fatalError("Method must be overriden")
    }
    func get(identifier: I) -> T? {
        fatalError("Method must be overriden")
    }
    func create(a: T) -> Bool {
        fatalError("Method must be overriden")
    }
    func update(a: T) -> Bool {
        fatalError("Method must be overriden")
    }
    func delete(a: T) -> Bool {
        fatalError("Method must be overriden")
    }
}

fileprivate final class _AnyRepositoryBox<Concrete: Repository>: _AnyRepositoryBase<Concrete.T,Concrete.I> {
    // variable used since we're calling mutating functions
    var concrete: Concrete

    init(_ concrete: Concrete) {
        self.concrete = concrete
    }

    override func getAll() -> [T] {
        return concrete.getAll()
    }
    override func get(identifier: I) -> T? {
        return concrete.get(identifier: identifier)
    }
    override func create(a: T) -> Bool {
        return concrete.create(a: a)
    }
    override func update(a: T) -> Bool {
        return concrete.update(a: a)
    }
    override func delete(a: T) -> Bool {
        return concrete.delete(a: a)
    }
}

final class AnyRepository<T,I>: Repository {

    private let box: _AnyRepositoryBase<T,I>

    // Initializer takes our concrete implementer of Repository i.e. ListRepository
    init<Concrete: Repository>(_ concrete: Concrete) where Concrete.T == T, Concrete.I == I {
        box = _AnyRepositoryBox(concrete)
    }

    func getAll() -> [T] {
        return box.getAll()
    }
    func get(identifier: I) -> T? {
        return box.get(identifier: identifier)
    }
    func create(a: T) -> Bool {
        return box.create(a: a)
    }
    func update(a: T) -> Bool {
        return box.update(a: a)
    }
    func delete(a: T) -> Bool {
        return box.delete(a: a)
    }
}

// Implementations
struct ListImpl : List {
    var listId: ListId
    var name: String
}
struct NoteImpl : Note {
    var noteId: NoteId
    var title: String
    var modifiedDate: Date
    var content: NSAttributedString
}

class SimpleArrayRepository<T,I:Hashable> : Repository {

    fileprivate var repositoryContent = [I:T]()

    func getAll() -> [T] {
        return Array(repositoryContent.values)
    }

    func get(identifier: I) -> T? {
        return repositoryContent[identifier]
    }

    func create(a: T) -> Bool {
        return false
    }

    func update(a: T) -> Bool {
        return false
    }

    func delete(a: T) -> Bool {
        return false
    }


    init(content:[I:T]) {
        repositoryContent = content
    }
}

enum RepositoryErrors: Error {
    case unexpectedTypeRepositoryRequested
}

class SimpleArrayRepositoryFactory : RepositoryFactory {
    func getRepository<T,I>() throws -> AnyRepository<T,I> {
        switch (T.self,I.self) {
        case (is List, is ListId.Type):
            return getListsRepository() as! AnyRepository<T, I>
        case (is Note, is NoteId.Type):
            return getNotesRepository() as! AnyRepository<T, I>
        default:
            throw RepositoryErrors.unexpectedTypeRepositoryRequested
        }
    }

    func getListsRepository() -> AnyRepository<List,ListId> {
        let lists = [ListId("1"):ListImpl(listId: "1", name: "First list")] as [String:List]
        let arrayRepo = SimpleArrayRepository<List,ListId>(content: lists)
        return AnyRepository(arrayRepo)
    }

    func getNotesRepository() -> AnyRepository<Note,NoteId> {
        let firstNote = NoteImpl(noteId: "1",
                                 title: "First note",
                                 modifiedDate: Date(),
                                 content: NSAttributedString(string: ""))
        let lists = [NoteId("1"):firstNote] as [String:Note]
        let arrayRepo = SimpleArrayRepository<Note,NoteId>(content: lists)
        return AnyRepository(arrayRepo)
    }

}
