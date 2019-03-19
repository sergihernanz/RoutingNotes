//
//  NavigatorImpl.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 30/11/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var navigationController: UINavigationController? {
        assertionFailure()
        return nil
    }
}

enum NavigationError: Error {
    case invalidDestinationForCurrentNavigation(currentNavigation:NotesNavigation, destinationDescription:String)

    var localizedDescription: String {
        switch self {
        case .invalidDestinationForCurrentNavigation(let currentNavigation, let destinationDescription):
            return "Current navigation (\(currentNavigation) does not support navigating to \(destinationDescription)"
        }
    }
}

final class NotesStatefulNavigator: NSObject, StatefulNavigator {

    typealias NavigationType = MainNotesNavigation
    typealias ModelType = NotesModelContext
    typealias BuilderType = NotesNavigationEndpointsBuilder

    internal var model: NotesModelContext
    internal var endpointsBuilder: NotesNavigationEndpointsBuilder

    init(model: NotesModelContext,
         endpointsBuilder: NotesNavigationEndpointsBuilder) {
        self.model = model
        self.endpointsBuilder = endpointsBuilder
        navigatorState = .idle(.main(.folders))
        super.init()
    }

    // MARK: return the main UIViewController (UINavigationController)
    fileprivate lazy var navigationController: UINavigationController = {
        let rootVC = endpointsBuilder.buildTopItem(forNavigationEndpoint: .main(.folders),
                                                                          navigator: self,
                                                                          model: model)
        let navC = UINavigationController(rootViewController: rootVC)
        navC.navigationBar.tintColor = .black
        navC.delegate = self
        return navC
    }()
    var rootViewController: UIViewController {
        return navigationController
    }

    // MARK: Build and read the stack of UIViewControllers
    var viewControllersStack: [UIViewController] {
        var ncViewControllers = navigationController.viewControllers
        guard let modal = navigationController.presentedViewController else {
            return ncViewControllers
        }
        ncViewControllers.append(modal)
        return ncViewControllers
    }
    func present(newViewControllerStack: [UIViewController], forNavigation: MainNotesNavigation, animated: Bool) {
        switch forNavigation {
        case .main:
            navigationController.setPopOrPushViewControllers(newViewControllerStack,
                                                             animated: animated) {
                self.completeAnimation(self.getCurrentNavigation())
            }
        case .modal:
            var others = newViewControllerStack
            others.removeLast()
            if let modal = newViewControllerStack.last,
               others.count > 0 {
                navigationController.setPopOrPushViewControllers(others,
                                                                 modalTopMost: modal,
                                                                 animated: animated) {
                    self.completeAnimation(self.getCurrentNavigation())
                }
            }
        }
    }

    // Call didSet on navigatorState didSet method... manual step other than protocol conformance
    internal var navigatorState: NavigatorState<MainNotesNavigation> {
        didSet {
            didSet(newState: navigatorState, oldState: oldValue)
            print("[NOTESNAVIGATOR] \(navigatorState)")
        }
    }

}

extension NotesStatefulNavigator: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {

    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        completeAnimation(getCurrentNavigation())
    }
}
