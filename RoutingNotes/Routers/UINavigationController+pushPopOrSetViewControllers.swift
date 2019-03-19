//
//  UINavigationController+pushPopOrSetViewControllers.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 20/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit

extension UINavigationController {

    // Completion is only called if a simple modal dismissal is done,
    //  otherwise you need to register as navigation controller delegate
    func setPopOrPushViewControllers(_ newViewControllers: [UIViewController],
                                     animated: Bool,
                                     completion: (() -> Void)? = nil) {
        if viewControllers.elementsEqual(newViewControllers) {
            // Nothing to do
            if nil != self.presentedViewController {
                self.dismiss(animated: animated, completion: completion)
            }
            return
        }
        let privateSetPopOrPush: () -> Void = {
            var viewControllersWithoutLast = self.viewControllers
            _ = viewControllersWithoutLast.popLast()
            if newViewControllers.elementsEqual(viewControllersWithoutLast) {
                // New array matches currentArray.popLast... pop
                self.popViewController(animated: animated)
                return
            }
            while viewControllersWithoutLast.count > 2 {
                _ = viewControllersWithoutLast.popLast()
                if let lastVC = viewControllersWithoutLast.last,
                    newViewControllers.elementsEqual(viewControllersWithoutLast) {
                    // New array matches currentArray.popSome... pop to the first correct one
                    self.popToViewController(lastVC, animated: animated)
                    return
                }
            }
            if let rootViewController = self.viewControllers.first,
                newViewControllers.count == 1,
                let newUniqueViewController = newViewControllers.first,
                newUniqueViewController === rootViewController {
                // New array has only one item and matches currentArray.first... pop to root vc
                self.popToRootViewController(animated: animated)
                return
            }
            // New array matches currentArray.popLast... pop
            self.setViewControllers(newViewControllers, animated: animated)
        }
        if nil != self.presentedViewController {
            self.dismiss(animated: false, completion: privateSetPopOrPush)
        } else {
            privateSetPopOrPush()
        }
    }

    func setPopOrPushViewControllers(_ newViewControllers: [UIViewController],
                                     modalTopMost: UIViewController,
                                     animated: Bool,
                                     completion: (() -> Void)? = nil) {
        self.setPopOrPushViewControllers(newViewControllers, animated: animated)
        self.present(modalTopMost, animated: animated, completion: completion)
    }
}
