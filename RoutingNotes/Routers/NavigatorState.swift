//
//  NavigatorState.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 18/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import Foundation

enum NavigatorState<NavigationType : Equatable> : Equatable {

    case idle(NavigationType)
    case navigating(from:NavigationType, to:NavigationType, toCompletion:((_ cancelled: Bool) -> Void))
    case navigatingToNonFinalNavigation(from:NavigationType, to:NavigationType,
        finalNavigation: NavigationType, finalCompletion: ((_ cancelled: Bool) -> Void))

    static func == (lhs: NavigatorState, rhs: NavigatorState) -> Bool {
        switch lhs {
        case .idle(let lhsn):
            switch rhs {
            case .idle(let rhsn):
                return lhsn == rhsn
            default:
                return false
            }
        case .navigating(from: let lhfrom, to: let lhto, toCompletion: _):
            switch rhs {
            case .navigating(from: let rhfrom, to: let rhto, toCompletion: _):
                return lhfrom == rhfrom && rhto == lhto;
            default:
                return false
            }
        case .navigatingToNonFinalNavigation(from: let lhfrom, to: let lhto, finalNavigation: let lhfinal, finalCompletion: _):
            switch rhs {
            case .navigatingToNonFinalNavigation(from: let rhfrom, to: let rhto, finalNavigation: let rhfinal, finalCompletion: _):
                return lhfrom == rhfrom && rhto == lhto && rhfinal == lhfinal;
            default:
                return false
            }
        }
    }

    var currentNavigation: NavigationType {
        switch self {
        case .idle(let navigation):
            return navigation
        case .navigating(from: _, to: let futureNavigation, toCompletion: _):
            return futureNavigation
        case .navigatingToNonFinalNavigation(from: _, to: _, finalNavigation: let finalNavigation, finalCompletion: _):
            return finalNavigation
        }
    }
}
