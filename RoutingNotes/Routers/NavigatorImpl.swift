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

class NotesNavigationEndpointsBuilder: NavigationEndpointsBuilder {

    typealias NavigationType = NotesNavigation
    typealias NavigatorType = NavigatorImpl
    typealias ModelType = NotesModelContext

    private(set) var model: NotesModelContext
    required init(model: NotesModelContext) {
        self.model = model
    }

    func getInstancedOrBuildViewController(forNavigationEndpoint:NotesNavigation,
                                           navigator: NavigatorImpl) -> UIViewController {
        return getEndpointCorrectInstancedViewController(forNavigationEndpoint: forNavigationEndpoint,
                                                         navigator: navigator) ??
                buildEndpointRoutableViewController(forNavigationEndpoint: forNavigationEndpoint,
                                                    navigator: navigator)
    }
    private func buildEndpointRoutableViewController(forNavigationEndpoint:NotesNavigation,
                                                     navigator: NavigatorImpl) -> UIViewController {
        switch forNavigationEndpoint {
        case .folders:
            return FoldersVC(navigator: navigator, model:model, navigationInput:())
        case .folders👉list(let listId):
            return ListVC(navigator: navigator, model:model, navigationInput: listId)
        case .folders👉🏻list👉note(_, let noteId):
            return NoteVC(navigator: navigator, model:model, navigationInput: noteId)
        }
    }

    func getEndpointCorrectInstancedViewController(forNavigationEndpoint:NotesNavigation,
                                                   navigator: NavigatorImpl) -> UIViewController? {
        switch forNavigationEndpoint {
        case .folders:
            return navigator.navigationController.viewControllers.first
        case .folders👉list(let listId):
            guard navigator.navigationController.viewControllers.count > 1,
                let secondVC = navigator.navigationController.viewControllers[1] as? ListVC,
                secondVC.navigationInput == listId,
                // TODO:
                //secondVC.navigator === navigator,
                secondVC.model === model else {
                    return nil
            }
            return secondVC
        case .folders👉🏻list👉note(_, let noteId):
            guard navigator.navigationController.viewControllers.count > 2,
                let thirdVC = navigator.navigationController.viewControllers[2] as? NoteVC,
                thirdVC.navigationInput == noteId,
                // TODO:
                //thirdVC.navigator === navigator,
                thirdVC.model === model else {
                    return nil
            }
            return thirdVC
        }
    }

    func getCurrentNavigation(fromNavigator: NavigatorImpl) -> NotesNavigation {
        var evaluatingNavigation: NotesNavigation
        switch fromNavigator.currentState {
        case .idle(let currentNavigation):
            evaluatingNavigation = currentNavigation
        case .navigating(_, let to, _, _):
            evaluatingNavigation = to
        case .navigatingToNonFinalNavigation(_, let to, _, _, _):
            evaluatingNavigation = to
        }

        let evaluatingStack = evaluatingNavigation.navigationStack()
        assert(evaluatingStack.count >= fromNavigator.navigationController.viewControllers.count)
        let validVCsOnNavC = evaluatingStack.compactMap { (navigation) -> UIViewController? in
            getEndpointCorrectInstancedViewController(forNavigationEndpoint: navigation,
                                                      navigator: fromNavigator)
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


class NavigatorImpl : NSObject, Navigator {

    fileprivate var model : NotesModelContext
    fileprivate var endpointsBuilder : NotesNavigationEndpointsBuilder

    init(model:NotesModelContext, endpointsBuilder: NotesNavigationEndpointsBuilder) {
        self.model = model
        self.endpointsBuilder = endpointsBuilder
        currentState = .idle(.folders)
        super.init()
    }

    fileprivate lazy var navigationController : UINavigationController = {
        let navC = UINavigationController(rootViewController: FoldersVC(navigator: self, model:model, navigationInput:()))
        navC.navigationBar.tintColor = UIColor.black
        navC.delegate = self
        return navC
    }()
    var rootViewController: UIViewController {
        return navigationController
    }

    var currentNavigation: NotesNavigation {
        return currentState.currentNavigation
    }
    
    fileprivate var currentState: NavigatorState<NotesNavigation> {
        didSet {
            if oldValue == currentState {
                return
            }
            // Call completion closures correctly: from navigating to idle
            switch oldValue {
            case .navigating(from: _, let toNavigation, _, let completion):
                switch currentState {
                case .idle(let newNavigation):
                    assert(toNavigation == newNavigation)
                    if oldValue != currentState {
                        completion(currentState != .idle(toNavigation))
                    }
                default: break
                }
            default: break
            }

            // Configure vCs accordingly to new state
            switch currentState {
            case .navigating(_, let to, let animated, _):
               let navigationStack = to.navigationStack()
               let VCs = navigationStack.map { (navigation) -> UIViewController in
                endpointsBuilder.getInstancedOrBuildViewController(forNavigationEndpoint: navigation,
                                                                   navigator: self)
               }
               navigationController.setPopOrPushViewControllers(VCs, animated: animated)
            default: break
            }

            print("[NOTESNAVIGATOR] \(currentState)")
        }
    }

    func navigate(to: NotesNavigation, animated: Bool, completion: @escaping (_ cancelled: Bool) -> Void) {
        switch currentState {
        case .idle(let navigation):
            currentState = .navigating(from: navigation,
                                       to: to,
                                       animated: animated,
                                       toCompletion: completion)
        case .navigating(let navigatingFrom, let navigatingTo, let animated, let toCompletion):
            if to == navigatingTo {
                // Already navigating there... just recreate completion closure to call current and new completion closure
                currentState = .navigating(from: navigatingFrom,
                                           to: navigatingTo,
                                           animated: animated,
                                           toCompletion: { (cancelled) in
                                            toCompletion(cancelled)
                                            completion(cancelled)
                })
            } else {
                toCompletion(true)
                currentState = .navigatingToNonFinalNavigation(from: navigatingFrom,
                                                               to: navigatingTo,
                                                               finalNavigation: to,
                                                               animated: animated,
                                                               finalCompletion: completion)
            }
        case .navigatingToNonFinalNavigation(let from, let currentTo, let finalNavigation, _, let finalCompletion):
            if to == finalNavigation {
                // Already final-navigating there... just recreate completion closure to call current and new completion closure
                currentState = .navigatingToNonFinalNavigation(from: from,
                                                               to: currentTo,
                                                               finalNavigation: finalNavigation,
                                                               animated: animated,
                                                               finalCompletion: { (cancelled) in
                                                                finalCompletion(cancelled)
                                                                completion(cancelled)
                })
            } else {
                finalCompletion(true)
                currentState = .navigatingToNonFinalNavigation(from: from,
                                                               to: currentTo,
                                                               finalNavigation: to,
                                                               animated: animated,
                                                               finalCompletion: completion)
            }
        }
    }
}


extension NavigatorImpl : UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {

    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        let newNavigation = endpointsBuilder.getCurrentNavigation(fromNavigator: self)
        switch currentState {
        case .idle:
            // Swipe back gesture recognizer
            currentState = .idle(newNavigation)
        case .navigating(_, let to, _, _):
            // Router started animation just finished...
            assert(to == newNavigation)
            currentState = .idle(newNavigation)
        case .navigatingToNonFinalNavigation(_, let to, let finalNavigation, let animated, finalCompletion: let finalCompletion):
            // Navigate to final destination
            currentState = .navigating(from: to, to: finalNavigation, animated: animated, toCompletion: finalCompletion)
        }
    }
}
