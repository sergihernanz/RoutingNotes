//
//  Navigator.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 23/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit

protocol Navigator: class {

    associatedtype NavigationType: Equatable

    // Root viewcontroller to be presented on a VC hierarchy
    var rootViewController: UIViewController { get }

    // Information
    var currentNavigation : NavigationType { get }

    // Deep link
    func navigate(to: NavigationType, animated: Bool, completion: @escaping (_ cancelled: Bool) -> Void)

    // TODO: Normal navigation

    // TODO: Dependency based navigation

}

protocol StatefulNavigator: Navigator {

    var navigatorState: NavigatorState<NavigationType> { get set }

    // These methods are using the cache of built VCs (system navigation) to help the VC build process
    func getCorrectlyInstancedViewController(forNavigationEndpoint:NavigationType) -> UIViewController?
    func getCurrentNavigation() -> NavigationType
}

extension StatefulNavigator {

    var currentNavigation: NavigationType {
        return navigatorState.currentNavigation
    }

    func navigate(to: NavigationType, animated: Bool, completion: @escaping (_ cancelled: Bool) -> Void) {
        switch navigatorState {
        case .idle(let navigation):
            if navigation != to {
                navigatorState = .navigating(from: navigation,
                                             to: to,
                                             animated: animated,
                                             toCompletion: completion)
            }
        case .navigating(let navigatingFrom, let navigatingTo, let animated, let toCompletion):
            if to == navigatingTo {
                // Already navigating there... just recreate completion closure to call current and new completion closure
                navigatorState = .navigating(from: navigatingFrom,
                                             to: navigatingTo,
                                             animated: animated,
                                             toCompletion: { (cancelled) in
                                                toCompletion(cancelled)
                                                completion(cancelled)
                })
            } else {
                toCompletion(true)
                navigatorState = .navigatingToNonFinalNavigation(from: navigatingFrom,
                                                                 to: navigatingTo,
                                                                 finalNavigation: to,
                                                                 animated: animated,
                                                                 finalCompletion: completion)
            }
        case .navigatingToNonFinalNavigation(let from, let currentTo, let finalNavigation, _, let finalCompletion):
            if to == finalNavigation {
                // Already final-navigating there... just recreate completion closure to call current and new completion closure
                navigatorState = .navigatingToNonFinalNavigation(from: from,
                                                                 to: currentTo,
                                                                 finalNavigation: finalNavigation,
                                                                 animated: animated,
                                                                 finalCompletion: { (cancelled) in
                                                                    finalCompletion(cancelled)
                                                                    completion(cancelled)
                })
            } else {
                finalCompletion(true)
                navigatorState = .navigatingToNonFinalNavigation(from: from,
                                                                 to: currentTo,
                                                                 finalNavigation: to,
                                                                 animated: animated,
                                                                 finalCompletion: completion)
            }
        }
    }
}



/*
 // type erasure pattern for Interactor observer
 private class _AnyNavigatorBase<NavigationType>: Navigator {
 init() {
 guard type(of: self) != _AnyNavigatorBase.self else {
 fatalError("_AnyNavigatorBase<NavigationType> instances can not be created, create a subclass instance instead")
 }
 }
 var rootViewController: UIViewController {
 fatalError("Method must be overriden")
 }
 var currentNavigation: NavigationType {
 fatalError("Method must be overriden")
 }
 func navigate(to: NavigationType, animated: Bool, completion: @escaping (Bool) -> Void) {
 fatalError("Method must be overriden")
 }
 }

 fileprivate final class _AnyNavigatorBox<Concrete: Navigator>: _AnyNavigatorBase<Concrete.NavigationType> {
 // variable used since we're calling mutating functions
 var concrete: Concrete
 init(_ concrete: Concrete) {
 self.concrete = concrete
 }
 override var rootViewController: UIViewController {
 return concrete.rootViewController
 }
 override var currentNavigation: NavigationType {
 return concrete.currentNavigation
 }
 override func navigate(to: NavigationType, animated: Bool, completion: @escaping (Bool) -> Void) {
 concrete.navigate(to: to, animated: animated, completion: completion)
 }
 }

 final class AnyNavigator<NavigationType>: Navigator {
 private let box: _AnyNavigatorBase<NavigationType>
 // Initializer takes our concrete implementer of Navigator i.e. NotesNavigator
 init<Concrete: Navigator>(_ concrete: Concrete) where Concrete.NavigationType == NavigationType {
 box = _AnyNavigatorBox(concrete)
 }
 var rootViewController: UIViewController {
 return box.rootViewController
 }
 var currentNavigation: NavigationType {
 return box.currentNavigation
 }
 func navigate(to: NavigationType, animated: Bool, completion: @escaping (Bool) -> Void) {
 box.navigate(to: to, animated: animated, completion: completion)
 }
 }
 */
