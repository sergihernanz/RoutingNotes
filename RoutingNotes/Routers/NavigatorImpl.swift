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


class NavigatorImpl : NSObject, Navigator {

    fileprivate var model : OrdersModelContext

    init(model:OrdersModelContext) {
        self.model = model
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

    var currentNavigation: Navigation {
        return currentState.currentNavigation
    }
    
    fileprivate var currentState: NavigatorState<Navigation> {
        willSet {
            switch currentState {
            case .navigating(from: _, to: let toNavigation, toCompletion: let completion):
                if currentState != newValue {
                    // TODO too early notification, if notified/us calls to navigator.currentState... will it be correct ?
                    completion(newValue != .idle(toNavigation))
                }
                break
            default:
                break
            }
        }
        didSet {
            print("[NOTESNAVIGATOR] \(currentState)")
        }
    }

    func navigate(to: Navigation, animated: Bool, completion: @escaping (_ cancelled: Bool) -> Void) {
        switch currentState {
        case .idle:
            switch to {
            case .folders:
                presentFolders(animated: animated, completion: completion)
            case .folders👉list(let listId):
                presentList(listId: listId, animated: animated, completion: completion)
            case .folders👉🏻list👉note(let listId, let noteId):
                presentDetail(listId: listId, noteId: noteId, animated: animated, completion: completion)
            }
        case .navigating(from: let navigatingFrom, to: let navigatingTo, toCompletion: let toCompletion):
            if to != navigatingTo {
                currentState = .navigatingToNonFinalNavigation(from: navigatingFrom, to: navigatingTo,
                                                               finalNavigation: to, finalCompletion: completion)
            } else {
                currentState = .navigating(from: navigatingFrom, to: navigatingTo, toCompletion: { (cancelled) in
                    toCompletion(cancelled)
                    completion(cancelled)
                })
            }
        case .navigatingToNonFinalNavigation(from: let navigatingFrom, to: let navigatingTo,
                                             finalNavigation: let finalNavigation, finalCompletion: let finalCompletion):
            if to != finalNavigation {
                currentState = .navigatingToNonFinalNavigation(from: navigatingFrom, to: navigatingTo,
                                                               finalNavigation: to, finalCompletion: finalCompletion)
            } else {
                currentState = .navigatingToNonFinalNavigation(from: navigatingFrom, to: navigatingTo,
                                                               finalNavigation: finalNavigation, finalCompletion: { (cancelled) in
                    finalCompletion(cancelled)
                    completion(cancelled)
                })
            }
        }
    }

    fileprivate func presentFolders(animated:Bool, completion: @escaping (_ cancelled: Bool) -> Void) {
        currentState = .navigating(from: currentNavigation, to: .folders, toCompletion: completion)
        navigationController.popToRootViewController(animated: animated)
    }

    fileprivate func presentList(listId:ListId, animated:Bool, completion: @escaping (_ cancelled: Bool) -> Void) {
        let newNavigation: Navigation = .folders👉list(listId: listId)
        currentState = .navigating(from: currentNavigation,
                                   to: newNavigation,
                                   toCompletion: completion)
        let navigationStack = newNavigation.navigationStack()
        let VCs = navigationStack.map { (navigation) -> UIViewController in
            getLastInstancedOrNewViewController(forNavigation: navigation)
        }
        navigationController.setPopOrPushViewControllers(VCs, animated: animated)
    }

    fileprivate func presentDetail(listId:ListId,noteId:NoteId, animated:Bool, completion: @escaping (_ cancelled: Bool) -> Void) {
        let newNavigation: Navigation = .folders👉🏻list👉note(listId: listId, noteId: noteId)
        currentState = .navigating(from: currentNavigation,
                                   to: newNavigation,
                                   toCompletion: completion)
        let navigationStack = newNavigation.navigationStack()
        let VCs = navigationStack.map { (navigation) -> UIViewController in
            getLastInstancedOrNewViewController(forNavigation: navigation)
        }
        navigationController.setPopOrPushViewControllers(VCs, animated: animated)
    }
}

extension NavigatorImpl {

    func getLastInstancedOrNewViewController(forNavigation:Navigation) -> UIViewController {
        return navigationController.getLastCorrectInstancedViewController(forNavigation:forNavigation) ??
               buildLastRoutableViewController(forNavigation:forNavigation)
    }
    func buildLastRoutableViewController(forNavigation:Navigation) -> UIViewController {
        switch forNavigation {
        case .folders:
            return FoldersVC(navigator: self, model:model, navigationInput:())
        case .folders👉list(let listId):
            return ListVC(navigator: self, model:model, navigationInput: listId)
        case .folders👉🏻list👉note(_, let noteId):
            return NoteVC(navigator: self, model:model, navigationInput: noteId)
        }
    }
}

extension UINavigationController {
    func getLastCorrectInstancedViewController(forNavigation:Navigation) -> UIViewController? {
        switch forNavigation {
        case .folders:
            return self.viewControllers.first
        case .folders👉list(let listId):
            guard self.viewControllers.count > 1,
                  let secondVC = self.viewControllers[1] as? ListVC,
                  secondVC.navigationInput == listId else {
                    return nil
            }
            return secondVC
        case .folders👉🏻list👉note(_, let noteId):
            guard self.viewControllers.count > 2,
                  let thirdVC = self.viewControllers[2] as? NoteVC,
                  thirdVC.navigationInput == noteId else {
                    return nil
            }
            return thirdVC
        }
    }
}

extension NavigatorImpl : UINavigationControllerDelegate {

    private func calculateCurrentNavigation(fromNavigationController navC: UINavigationController) -> Navigation {
        var evaluatingNavigation: Navigation
        switch self.currentState {
        case .idle(let currentNavigation):
            evaluatingNavigation = currentNavigation
        case .navigating(_, let to, _):
            evaluatingNavigation = to
        case .navigatingToNonFinalNavigation(_, let to, _, _):
            evaluatingNavigation = to
        }

        let evaluatingStack = evaluatingNavigation.navigationStack()
        assert(evaluatingStack.count >= navC.viewControllers.count)
        let validVCsOnNavC = evaluatingStack.compactMap { (navigation) -> UIViewController? in
            navC.getLastCorrectInstancedViewController(forNavigation: navigation)
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
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {

    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        let newNavigation = calculateCurrentNavigation(fromNavigationController: navigationController)
        switch currentState {
        case .navigating(from: _, to: _, toCompletion: _):
            currentState = .idle(newNavigation)
        case .navigatingToNonFinalNavigation(from: _, to: let intermediateDestination,
                                             finalNavigation: let finalNavigation, finalCompletion: let finalCompletion):
            currentState = .idle(intermediateDestination)
            // TODO: save animaged Bool for finalAnimation
            navigate(to: finalNavigation, animated: true, completion: finalCompletion)
        case .idle(_):
            currentState = .idle(newNavigation)
        }
    }
}
