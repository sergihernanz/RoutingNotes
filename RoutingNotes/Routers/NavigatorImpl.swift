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
        let navC = UINavigationController(rootViewController: FoldersVC(navigator: self, model:model, navigationInput:nil))
        navC.navigationBar.tintColor = UIColor.black
        navC.delegate = self
        return navC
    }()
    var rootViewController: UIViewController {
        return navigationController
    }

    var currentNavigation: Navigation {
        switch currentState {
        case .idle(let navigation):
            return navigation
        case .navigating(from: _, to: let futureNavigation, toCompletion: _):
            return futureNavigation
        case .navigatingToNonFinalNavigation(from: _, to: _, finalNavigation: let finalNavigation, finalCompletion: _):
            return finalNavigation
        }
    }
    enum NavigatorState : Equatable {

        case idle(Navigation)
        case navigating(from:Navigation, to:Navigation, toCompletion:((_ cancelled: Bool) -> Void))
        case navigatingToNonFinalNavigation(from:Navigation, to:Navigation,
                                            finalNavigation: Navigation, finalCompletion: ((_ cancelled: Bool) -> Void))

        static func == (lhs: NavigatorImpl.NavigatorState, rhs: NavigatorImpl.NavigatorState) -> Bool {
            switch lhs {
            case .idle(let lhsn):
                switch rhs {
                case .idle(let rhsn):
                    return lhsn == rhsn
                default:
                    return false
                }
            case .navigating(from: let lhfrom, to: let lhto, toCompletion: _):
                switch rhs {
                case .navigating(from: let rhfrom, to: let rhto, toCompletion: _):
                    return lhfrom == rhfrom && rhto == lhto;
                default:
                    return false
                }
            case .navigatingToNonFinalNavigation(from: let lhfrom, to: let lhto, finalNavigation: let lhfinal, finalCompletion: _):
                switch rhs {
                case .navigatingToNonFinalNavigation(from: let rhfrom, to: let rhto, finalNavigation: let rhfinal, finalCompletion: _):
                    return lhfrom == rhfrom && rhto == lhto && rhfinal == lhfinal;
                default:
                    return false
                }
            }
        }
    }
    var currentState: NavigatorState {
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
            print("\(currentState)")
        }
    }

    func navigate(to: Navigation, completion: @escaping (_ cancelled: Bool) -> Void) {
        switch currentState {
        case .idle:
            let animate = true
            switch to {
            case .folders:
                presentFolders(animated: animate, completion: completion)
            case .folders👉list(let listId):
                presentList(listId: listId, animated: animate, completion: completion)
            case .folders👉🏻list👉note(let listId, let noteId):
                presentDetail(listId: listId, noteId: noteId, animated: animate, completion: completion)
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
        currentState = .navigating(from: currentNavigation,
                                   to: .folders👉list(listId: listId),
                                   toCompletion: completion)
        if navigationController.children.count>1,
           let currentListVC = navigationController.children[1] as? ListVC,
           currentListVC.navigationInput == listId {
            // Already there, nothing to do
            // [✅,✅,?]
            navigationController.popToViewController(currentListVC, animated: animated)
        } else {
            // List is not in place
            // [✅,❌,?...]
            let listVC = ListVC(navigator: self, model:model, navigationInput: listId)
            if navigationController.children.count>1 {
                // Already there... but different input, rebuild
                // [✅,❌]
                let foldersVC = navigationController.children.first!
                navigationController.setViewControllers([foldersVC,listVC], animated: animated)
            } else {
                // [✅]
                navigationController.pushViewController(listVC, animated: animated)
            }
        }
    }

    fileprivate func presentDetail(listId:ListId,noteId:NoteId, animated:Bool, completion: @escaping (_ cancelled: Bool) -> Void) {
        currentState = .navigating(from: currentNavigation,
                                   to: .folders👉🏻list👉note(listId: listId, noteId: noteId),
                                   toCompletion: completion)
        if navigationController.children.count>2,
           let currentListVC = navigationController.children[1] as? ListVC,
           currentListVC.navigationInput == listId,
           let currentNoteVC = navigationController.children[2] as? NoteVC,
           currentNoteVC.navigationInput == noteId {
            // Already there, nothing to do
            // [✅,✅,✅,?...]
            navigationController.popToViewController(currentNoteVC, animated: animated)
        } else {
            // Note is not in place
            // [✅] [✅,?] [✅,?,❌] [✅,?,❌...]
            let noteVC = NoteVC(navigator: self, model:model, navigationInput: noteId)
            if navigationController.children.count>1,
               let currentListVC = navigationController.children[1] as? ListVC,
               currentListVC.navigationInput == listId {
                // Already there, nothing to do
                // [✅] [✅,✅] [✅,✅,❌] [✅,✅,❌...]
                let foldersVC = navigationController.children.first!
                let listVC = navigationController.children[1]
                navigationController.setViewControllers([foldersVC,listVC,noteVC], animated: animated)
            } else {
                // List is not in place
                // [✅] [✅,❌] [✅,❌...]
                let listVC = ListVC(navigator: self, model:model, navigationInput: listId)
                let foldersVC = navigationController.children.first!
                navigationController.setViewControllers([foldersVC,listVC,noteVC], animated: animated)
            }
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
            navigate(to: finalNavigation, completion: finalCompletion)
        case .idle(_):
            currentState = .idle(newNavigation)
        }
    }
}
