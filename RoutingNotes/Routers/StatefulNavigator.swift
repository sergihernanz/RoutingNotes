//
//  StatefulNavigator.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 25/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit

/***
 Easy implementation of a Navigator by using algorithms based on comparing:
 - The stack of existing viewControllers
 - The stack of the Navigation Item
 */
protocol StatefulNavigator: Navigator {

    var model: ModelType { get }
    var navigatorState: NavigatorState<NavigationType> { get set }

    associatedtype BuilderType: TopNavigationItemBuilder where ModelType == BuilderType.ModelType,
                                                                 NavigationType == BuilderType.NavigationType,
                                                                 BuilderType.NavigatorType == Self
    var endpointsBuilder: BuilderType { get }

    var viewControllersStack: [UIViewController] { get }
    func present(newViewControllerStack: [UIViewController], forNavigation: NavigationType, animated: Bool)

}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
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

    func didSet(newState: NavigatorState<NavigationType>, oldState: NavigatorState<NavigationType>) {
        if oldState == newState {
            return
        }
        // Call completion closures correctly: from navigating to idle
        switch oldState {
        case .navigating(from: _, let toNavigation, _, let completion):
            switch newState {
            case .idle(let newNavigation):
                assert(toNavigation == newNavigation)
                if oldState != newState {
                    completion(newState != .idle(toNavigation))
                }
            default: break
            }
        default: break
        }

        // Configure vCs accordingly to new state
        switch newState {
        case .navigating(_, let to, let animated, _):
            let navigationStack = to.navigationStack()
            let VCs = navigationStack.map { (navigation) -> UIViewController in
                getCorrectlyInstancedViewController(forNavigationEndpoint: navigation) ??
                    endpointsBuilder.buildTopItem(forNavigationEndpoint: navigation, navigator: self, model: model)
            }
            present(newViewControllerStack: VCs, forNavigation: to, animated: animated)
        default: break
        }
    }

    fileprivate func getCorrectlyInstancedViewController(forNavigationEndpoint: NavigationType) -> UIViewController? {
        let stackCount = forNavigationEndpoint.navigationStack().count
        if let vc = viewControllersStack[safe: stackCount-1],
            endpointsBuilder.isCorrectlyConfigured(viewController: vc, forNavigation: forNavigationEndpoint) {
            return vc
        }
        return nil
    }

    func getCurrentNavigation() -> NavigationType {
        var evaluatingNavigation: NavigationType
        switch navigatorState {
        case .idle(let currentNavigation):
            evaluatingNavigation = currentNavigation
        case .navigating(_, let to, _, _):
            evaluatingNavigation = to
        case .navigatingToNonFinalNavigation(_, let to, _, _, _):
            evaluatingNavigation = to
        }

        let evaluatingStack = evaluatingNavigation.navigationStack()
        assert(evaluatingStack.count >= viewControllersStack.count)
        let validVCsOnNavC = evaluatingStack.compactMap { (navigation) -> UIViewController? in
            getCorrectlyInstancedViewController(forNavigationEndpoint: navigation)
            }.count
        let numOfVCsAccordingToEvailuatingNavigation = evaluatingStack.count
        let invalidVCsNumberInEvaluatingNavigation = numOfVCsAccordingToEvailuatingNavigation - validVCsOnNavC
        assert( invalidVCsNumberInEvaluatingNavigation >= 0 )
        if invalidVCsNumberInEvaluatingNavigation > 0 {
            for _ in [1...invalidVCsNumberInEvaluatingNavigation] {
                evaluatingNavigation = evaluatingNavigation.pop()!
            }
        }
        return evaluatingNavigation
    }
}
