//
//  NotesNavigation+Codable.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 22/02/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import Foundation

protocol AutoDecodable: Decodable {}
protocol AutoEncodable: Encodable {}
protocol AutoCodable: AutoDecodable, AutoEncodable {}

extension MainNotesNavigation: AutoCodable {
}

extension NotesModalNavigation: AutoCodable {
}

extension NotesNavigation: AutoCodable {
}

extension MainNotesNavigation {

    func toJSONString() -> String? {
        do {
            let data = try JSONEncoder().encode(self)
            return String(data: data, encoding: .utf8)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    init?(jsonString: String) {
        do {
            guard let data = jsonString.data(using: .utf8) else {
                return nil
            }
            self = try JSONDecoder().decode(MainNotesNavigation.self, from: data)
        } catch {
            return nil
        }
    }
}
