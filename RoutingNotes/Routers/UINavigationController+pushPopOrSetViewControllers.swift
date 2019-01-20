//
//  UINavigationController+pushPopOrSetViewControllers.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 20/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit

extension UINavigationController {

    func setPopOrPushViewControllers(_ newViewControllers: [UIViewController], animated: Bool) {
        if viewControllers.elementsEqual(newViewControllers) {
            // Nothing to do
            return
        }
        var viewControllersWithoutLast = viewControllers
        _ = viewControllersWithoutLast.popLast()
        if newViewControllers.elementsEqual(viewControllersWithoutLast) {
            // New array matches currentArray.popLast... pop
            popViewController(animated: animated)
            return
        }
        while viewControllersWithoutLast.count > 2 {
            _ = viewControllersWithoutLast.popLast()
            if let lastVC = viewControllersWithoutLast.last,
                newViewControllers.elementsEqual(viewControllersWithoutLast) {
                // New array matches currentArray.popSome... pop to the first correct one
                popToViewController(lastVC, animated: animated)
                return
            }
        }
        if let rootViewController = viewControllers.first,
            newViewControllers.count == 1,
            let newUniqueViewController = newViewControllers.first,
            newUniqueViewController === rootViewController {
            // New array has only one item and matches currentArray.first... pop to root vc
            popToRootViewController(animated: animated)
            return
        }
        // New array matches currentArray.popLast... pop
        self.setViewControllers(newViewControllers, animated: animated)
    }

}
