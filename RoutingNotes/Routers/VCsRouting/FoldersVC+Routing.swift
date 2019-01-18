//
//  FoldersVC+Routing.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 18/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import Foundation
import UIKit

extension FoldersVC : Navigatable {

    typealias InputType = Void
    typealias OutputType = ListId

    var navigationInput: Void { return }
    var navigationOutput: ListId? {
        guard let selectedIP = tableView.indexPathForSelectedRow else {
            return nil
        }
        return folders[selectedIP.row].listId
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = folders[indexPath.row]
        do {
            try navigator.navigateToList(listId: list.listId, animated: true) { (cancelled: Bool) in }
        } catch let navigateToListError {
            fatalError(navigateToListError.localizedDescription)
        }
    }
}

fileprivate extension Navigation {
    func navigationToList(listId: ListId) throws -> Navigation {
        switch self {
        case .folders:
            return .folders👉list(listId: listId)
        default:
            throw NavigationError.invalidDestinationForCurrentNavigation(currentNavigation: self,
                                                                         destinationDescription: "List \(listId)")
        }
    }
}

fileprivate extension Navigator {
    func navigateToList(listId: ListId, animated: Bool, completion: @escaping (_ cancelled: Bool) -> Void) throws {
        let newNavigation = try currentNavigation.navigationToList(listId: listId)
        navigate(to: newNavigation, animated: animated, completion: completion)
    }
}
