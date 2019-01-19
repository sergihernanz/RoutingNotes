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
        let pos0Navigation = newNavigation.pop()
        let VCs = [navigationController.getLastInstancedOrNewViewController(forNavigation: pos0Navigation) ??
                    buildLastRoutableViewController(forNavigation: pos0Navigation),
                   navigationController.getLastInstancedOrNewViewController(forNavigation: newNavigation) ??
                    buildLastRoutableViewController(forNavigation: newNavigation)]
        navigationController.setPopOrPushViewControllers(VCs, animated: animated)
    }

    fileprivate func presentDetail(listId:ListId,noteId:NoteId, animated:Bool, completion: @escaping (_ cancelled: Bool) -> Void) {
        let newNavigation: Navigation = .folders👉🏻list👉note(listId: listId, noteId: noteId)
        currentState = .navigating(from: currentNavigation,
                                   to: newNavigation,
                                   toCompletion: completion)
        let pos1Navigation = newNavigation.pop()
        let pos0Navigation = pos1Navigation.pop()
        let VCs = [navigationController.getLastInstancedOrNewViewController(forNavigation: pos0Navigation) ??
                    buildLastRoutableViewController(forNavigation: pos0Navigation),
                   navigationController.getLastInstancedOrNewViewController(forNavigation: pos1Navigation) ??
                    buildLastRoutableViewController(forNavigation: pos1Navigation),
                   navigationController.getLastInstancedOrNewViewController(forNavigation: newNavigation) ??
                    buildLastRoutableViewController(forNavigation: newNavigation)]
        navigationController.setPopOrPushViewControllers(VCs, animated: animated)
    }
}

extension NavigatorImpl {

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
    func setPopOrPushViewControllers(_ newViewControllers: [UIViewController], animated: Bool) {
        var viewControllersWithoutLast = viewControllers
        _ = viewControllersWithoutLast.popLast()
        if newViewControllers.elementsEqual(viewControllersWithoutLast) {
            popViewController(animated: animated)
        } else {
            self.setViewControllers(newViewControllers, animated: animated)
        }
    }
    func getLastInstancedOrNewViewController(forNavigation:Navigation) -> UIViewController? {
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
        if navC.viewControllers.count <= 1 {
            assert(navC.viewControllers[0] is FoldersVC)
            return .folders
        } else if navC.viewControllers.count == 2 {
            guard let listVC = navC.viewControllers[1] as? ListVC else {
                assertionFailure()
                return .folders
            }
            return .folders👉list(listId: listVC.navigationInput)
        } else {
            assert(navC.viewControllers.count==3)
            guard let listVC = navC.viewControllers[1] as? ListVC,
                  let noteVC = navC.viewControllers[2] as? NoteVC else {
                assertionFailure()
                return .folders
            }
            return .folders👉🏻list👉note(listId: listVC.navigationInput, noteId: noteVC.navigationInput)
        }
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
