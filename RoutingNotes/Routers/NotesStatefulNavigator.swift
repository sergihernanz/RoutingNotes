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

    typealias NavigationType = NotesNavigation
    typealias ModelType = NotesModelContext
    typealias BuilderType = NotesNavigationEndpointsBuilder

    internal var model: NotesModelContext
    internal var endpointsBuilder: NotesNavigationEndpointsBuilder

    init(model: NotesModelContext,
         endpointsBuilder: NotesNavigationEndpointsBuilder) {
        self.model = model
        self.endpointsBuilder = endpointsBuilder
        navigatorState = .idle(.folders)
        super.init()
    }

    // MARK: return the main UIViewController (UINavigationController)
    fileprivate lazy var navigationController: UINavigationController = {
        let rootVC = endpointsBuilder.buildTopItem(forNavigationEndpoint: .folders,
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
        return navigationController.viewControllers
    }
    func present(newViewControllerStack: [UIViewController], forNavigation: NotesNavigation, animated: Bool) {
        navigationController.setPopOrPushViewControllers(newViewControllerStack, animated: animated)
    }

    // Call didSet on navigatorState didSet method... manual step other than protocol conformance
    internal var navigatorState: NavigatorState<NotesNavigation> {
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
        let newNavigation = getCurrentNavigation()
        switch navigatorState {
        case .idle:
            // Swipe back gesture recognizer
            navigatorState = .idle(newNavigation)
        case .navigating(_, let to, _, _):
            // Router started animation just finished...
            assert(to == newNavigation)
            navigatorState = .idle(newNavigation)
        case .navigatingToNonFinalNavigation(_, let to, let finalNavigation, let animated, finalCompletion: let finalCompletion):
            // Navigate to final destination
            navigatorState = .navigating(from: to, to: finalNavigation, animated: animated, toCompletion: finalCompletion)
        }
    }
}
