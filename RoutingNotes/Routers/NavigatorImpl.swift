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
        let navC = UINavigationController(rootViewController: FoldersVC(navigator: self, model:model))
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
        case .navigating(from: _, to: let futureNavigation):
            return futureNavigation
        }
    }
    enum NavigatorState {
        case navigating(from:Navigation,to:Navigation)
        case idle(Navigation)
    }
    var currentState: NavigatorState {
        didSet {
            print("\(currentState)")
            switch currentState {
            case .idle(_):
                currentNavigateCompletionBlock?()
                currentNavigateCompletionBlock = nil
            default:
                break
            }
        }
    }
    private var currentNavigateCompletionBlock: (() -> Void)?

    func navigate(to: Navigation, completion: @escaping () -> Void) {
        let animate = true
        switch to {
        case .folders:
            presentFolders(animated: animate, completion: completion)
        case .folders👉list(let listId):
            presentList(listId: listId, animated: animate, completion: completion)
        case .folders👉🏻list👉note(let listId, let noteId):
            presentDetail(listId: listId, noteId: noteId, animated: animate, completion: completion)
        }
    }

    fileprivate func presentFolders(animated:Bool, completion: () -> Void) {
        currentState = .navigating(from: currentNavigation, to: .folders)
        navigationController.popToRootViewController(animated: animated)
    }

    fileprivate func presentList(listId:ListId, animated:Bool, completion: @escaping () -> Void) {
        currentState = .navigating(from: currentNavigation, to: .folders👉list(listId: listId))
        if navigationController.children.count>1,
           let currentListVC = navigationController.children[1] as? ListVC,
           currentListVC.routeInput == listId {
            // Already there, nothing to do
            // [✅,✅,?]
            currentNavigateCompletionBlock = completion
            navigationController.popToViewController(currentListVC, animated: animated)
        } else {
            // List is not in place
            // [✅,❌,?...]
            let listVC = ListVC(navigator: self, model:model, listId: listId)
            if navigationController.children.count>1 {
                // Already there... but different input, rebuild
                // [✅,❌]
                currentNavigateCompletionBlock = completion
                let foldersVC = navigationController.children.first!
                navigationController.setViewControllers([foldersVC,listVC], animated: animated)
            } else {
                // [✅]
                currentNavigateCompletionBlock = completion
                navigationController.pushViewController(listVC, animated: animated)
            }
        }
    }

    fileprivate func presentDetail(listId:ListId,noteId:NoteId, animated:Bool, completion: @escaping () -> Void) {
        currentState = .navigating(from: currentNavigation, to: .folders👉🏻list👉note(listId: listId, noteId: noteId))
        if navigationController.children.count>2,
           let currentListVC = navigationController.children[1] as? ListVC,
           currentListVC.routeInput == listId,
           let currentNoteVC = navigationController.children[2] as? NoteVC,
           currentNoteVC.routeInput == noteId {
            // Already there, nothing to do
            // [✅,✅,✅,?...]
            currentNavigateCompletionBlock = completion
            navigationController.popToViewController(currentNoteVC, animated: animated)
        } else {
            // Note is not in place
            // [✅] [✅,?] [✅,?,❌] [✅,?,❌...]
            let noteVC = NoteVC(navigator: self, model:model, noteId: noteId)
            if navigationController.children.count>1,
               let currentListVC = navigationController.children[1] as? ListVC,
               currentListVC.routeInput == listId {
                // Already there, nothing to do
                // [✅] [✅,✅] [✅,✅,❌] [✅,✅,❌...]
                currentNavigateCompletionBlock = completion
                let foldersVC = navigationController.children.first!
                let listVC = navigationController.children[1]
                navigationController.setViewControllers([foldersVC,listVC,noteVC], animated: animated)
            } else {
                // List is not in place
                // [✅] [✅,❌] [✅,❌...]
                currentNavigateCompletionBlock = completion
                let listVC = ListVC(navigator: self, model:model, listId: listId)
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
            return .folders👉list(listId: listVC.routeInput)
        } else {
            assert(navC.viewControllers.count==3)
            guard let listVC = navC.viewControllers[1] as? ListVC,
                  let noteVC = navC.viewControllers[2] as? NoteVC else {
                assertionFailure()
                return .folders
            }
            return .folders👉🏻list👉note(listId: listVC.routeInput, noteId: noteVC.routeInput)
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
        case .navigating(from: _, to: let to):
            assert(to == newNavigation)
            currentState = .idle(newNavigation)
        case .idle(_):
            currentState = .idle(newNavigation)
            break
        }
    }
}
