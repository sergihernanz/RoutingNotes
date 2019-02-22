//
//  NotesLinkParser.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 15/02/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import Foundation

class NotesLinkParser {

    static func navigation(url: URL) throws -> NotesNavigation? {
        let foldersRegexs = [try NSRegularExpression(pattern: "(?:^https://|^)inqbarna\\.firebaseapp\\.com($|/$|/routingnotes/*$)", options: .caseInsensitive),
                            try NSRegularExpression(pattern: "^routingnotes://folders/*$", options: .caseInsensitive)]
        let listRegexs = [try NSRegularExpression(pattern: "(?:^https://|^)inqbarna\\.firebaseapp\\.com/routingnotes/(\\w)/*$", options: .caseInsensitive),
                          try NSRegularExpression(pattern: "^routingnotes://list/(\\w)$", options: .caseInsensitive)]
        let noteRegexs = [try NSRegularExpression(pattern: "(?:^https://|^)inqbarna\\.firebaseapp\\.com/routingnotes/(\\w)/(\\w)/*$", options: .caseInsensitive),
                          try NSRegularExpression(pattern: "^routingnotes://list/(\\w)/note/(\\w)$", options: .caseInsensitive)]
        let urlString = url.absoluteString
        let urlStringRange = NSRange(location: 0, length: urlString.count)
        for foldersRegex in foldersRegexs {
            let foldersMatches = foldersRegex.numberOfMatches(in: urlString, options: .anchored, range: urlStringRange)
            if foldersMatches > 0 {
                return .folders
            }
        }
        for listRegex in listRegexs {
            let listMatches = listRegex.matches(in: urlString, options: .anchored, range: urlStringRange)
            if listMatches.count == 1,
                let match = listMatches.first,
                match.numberOfRanges == 2 {
                let listIdRange = match.range(at: 1)
                let listId = String(urlString[String.Index(encodedOffset: listIdRange.lowerBound)..<String.Index(encodedOffset: listIdRange.upperBound)])
                return .folders👉list(listId: listId)
            }
        }
        for noteRegex in noteRegexs {
            let noteMatches = noteRegex.matches(in: urlString, options: .anchored, range: urlStringRange)
            if noteMatches.count == 1,
                let match = noteMatches.first,
                match.numberOfRanges == 3,
                let listIdRange = noteMatches.first?.range(at: 1),
                let noteIdRange = noteMatches.first?.range(at: 2) {
                let listId = String(urlString[String.Index(encodedOffset: listIdRange.lowerBound)..<String.Index(encodedOffset: listIdRange.upperBound)])
                let noteId = String(urlString[String.Index(encodedOffset: noteIdRange.lowerBound)..<String.Index(encodedOffset: noteIdRange.upperBound)])
                return .folders👉🏻list👉note(listId: listId, noteId: noteId)
            }
        }
        return nil
    }
}
