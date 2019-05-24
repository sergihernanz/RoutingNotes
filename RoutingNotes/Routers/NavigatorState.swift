//
//  NavigatorState.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 18/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import Foundation

enum NavigatorState<NavigationType: Navigation> {

    case idle(NavigationType)
    case navigating(from:NavigationType, to:NavigationType,
                    animated: Bool, toCompletion:((_ cancelled: Bool) -> Void))
    case navigatingToNonFinalNavigation(from:NavigationType, to:NavigationType,
                                        finalNavigation: NavigationType, animated: Bool,
                                        finalCompletion: ((_ cancelled: Bool) -> Void))

    var currentNavigation: NavigationType {
        switch self {
        case .idle(let navigation):
            return navigation
        case .navigating(_, let futureNavigation, _, _):
            return futureNavigation
        case .navigatingToNonFinalNavigation(_, _, let finalNavigation, _, _):
            return finalNavigation
        }
    }
}

extension NavigatorState: Equatable {

    static func == (lhs: NavigatorState, rhs: NavigatorState) -> Bool {
        switch (lhs, rhs) {
        case (.idle(let lhs), .idle(let rhs)):
            return lhs == rhs
        case (.navigating(let lhs), .navigating(let rhs)):
            return lhs.from == rhs.from && lhs.to == rhs.to
        case (.navigatingToNonFinalNavigation(let lhs), .navigatingToNonFinalNavigation(let rhs)):
            return lhs.from == lhs.from && lhs.to == rhs.to && lhs.finalNavigation == rhs.finalNavigation
        default:
            return false
        }
    }

}
