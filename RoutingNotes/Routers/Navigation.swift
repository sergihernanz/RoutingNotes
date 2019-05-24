//
//  Navigation.swift
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
