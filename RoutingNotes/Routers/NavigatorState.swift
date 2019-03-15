//
//  NavigatorState.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 18/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import Foundation

protocol Navigation: Equatable {
    init()
    func pop() -> Self?
}

extension Navigation {
    func navigationStack() -> [Self] {
        guard let backNavigation = self.pop() else {
            return [self]
        }
        var stack = backNavigation.navigationStack()
        stack.append(self)
        return stack
    }
}

enum NavigatorState<NavigationType: Navigation> : Equatable {

    case idle(NavigationType)
    case navigating(from:NavigationType, to:NavigationType,
                    animated: Bool, toCompletion:((_ cancelled: Bool) -> Void))
    case navigatingToNonFinalNavigation(from:NavigationType, to:NavigationType,
                                        finalNavigation: NavigationType, animated: Bool,
                                        finalCompletion: ((_ cancelled: Bool) -> Void))

    static func == (lhs: NavigatorState, rhs: NavigatorState) -> Bool {
        switch lhs {
        case .idle(let lhsn):
            switch rhs {
            case .idle(let rhsn):
                return lhsn == rhsn
            default:
                return false
            }
        case .navigating(let lhfrom, let lhto, _, _):
            switch rhs {
            case .navigating(let rhfrom, let rhto, _, _):
                return lhfrom == rhfrom && rhto == lhto
            default:
                return false
            }
        case .navigatingToNonFinalNavigation(let lhfrom, let lhto, let lhfinal, _, _):
            switch rhs {
            case .navigatingToNonFinalNavigation(let rhfrom, let rhto, let rhfinal, _, _):
                return lhfrom == rhfrom && rhto == lhto && rhfinal == lhfinal
            default:
                return false
            }
        }
    }

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
