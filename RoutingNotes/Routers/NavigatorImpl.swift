//
//  NavigatorImpl.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 30/11/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import Foundation
import UIKit


class NavigatorImpl : Navigator {
    fileprivate var window : UIWindow
    fileprivate var model : OrdersModelContext

    init(window:UIWindow, model:OrdersModelContext) {
        self.window = window
        self.model = model
        currentNavigation = .folders
        self.window.rootViewController = self.navigationController
    }

    fileprivate lazy var navigationController : UINavigationController = {
        let navC = UINavigationController(rootViewController: FoldersVC(navigator: self, model:model, navigationInput:nil))
        navC.navigationBar.tintColor = UIColor.black
        return navC
    }()

    var currentNavigation: Navigation

    func navigate(to: Navigation, completion: () -> Void) {
        let animate = true
        switch to {
        case .folders:
            presentFolders(animated: animate)
        case .folders👉list(let listId):
            presentList(listId: listId, animated: animate)
        case .folders👉🏻list👉note(let listId, let noteId):
            presentDetail(listId: listId, noteId: noteId, animated: animate)
        }
    }

    fileprivate func presentFolders(animated:Bool) {
        navigationController.popToRootViewController(animated: animated)
        currentNavigation = .folders
    }

    fileprivate func presentList(listId:ListId, animated:Bool) {
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
        currentNavigation = .folders👉list(listId: listId)
    }

    fileprivate func presentDetail(listId:ListId,noteId:NoteId, animated:Bool) {
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
        currentNavigation = .folders👉🏻list👉note(listId: listId, noteId: noteId)
    }


}
