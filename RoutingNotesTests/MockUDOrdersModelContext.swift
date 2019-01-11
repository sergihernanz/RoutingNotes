//
//  MockUDOrdersModelContext.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 29/12/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import Foundation

class MockUDOrdersModelContext : UserDefaultsOrdersModelContext {

    override init(persistenceName: String) {
        super.init(persistenceName: persistenceName)
        loadMockData()
    }

    private func loadMockData() {
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
