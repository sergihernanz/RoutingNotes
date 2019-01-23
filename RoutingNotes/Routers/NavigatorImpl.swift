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

    func buildEndpointRoutableViewController(forNavigationEndpoint:NotesNavigation,
                                             navigator: NavigatorImpl,
                                             model: NotesModelContext) -> UIViewController {
        switch forNavigationEndpoint {
        case .folders:
            return FoldersVC(navigator: navigator, model:model, navigationInput:())
        case .folders👉list(let listId):
            return ListVC(navigator: navigator, model:model, navigationInput: listId)
        case .folders👉🏻list👉note(_, let noteId):
            return NoteVC(navigator: navigator, model:model, navigationInput: noteId)
        }
    }

    func correctlyConfigured(viewController: UIViewController, forNavigation: NotesNavigation) -> Bool {
        switch forNavigation {
        case .folders:
            return viewController is FoldersVC
        case .folders👉list(let listId):
            if let listVC = viewController as? ListVC,
                listVC.navigationInput == listId {
                return true
            }
        case .folders👉🏻list👉note(_, let noteId):
            if let noteVC = viewController as? NoteVC, noteVC.navigationInput == noteId {
                return true
            }
        }
        return false
    }

}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class NavigatorImpl : NSObject, StatefulNavigator {

    typealias NavigationType = NotesNavigation

    fileprivate var model : NotesModelContext
    fileprivate var endpointsBuilder : NotesNavigationEndpointsBuilder

    init(model:NotesModelContext,
         endpointsBuilder: NotesNavigationEndpointsBuilder) {
        self.model = model
        self.endpointsBuilder = endpointsBuilder
        navigatorState = .idle(.folders)
        super.init()
    }

    fileprivate lazy var navigationController : UINavigationController = {
        let rootVC = endpointsBuilder.buildEndpointRoutableViewController(forNavigationEndpoint: .folders,
                                                                          navigator: self,
                                                                          model: model)
        let navC = UINavigationController(rootViewController: rootVC)
        navC.navigationBar.tintColor = UIColor.black
        navC.delegate = self
        return navC
    }()
    var rootViewController: UIViewController {
        return navigationController
    }

    internal var navigatorState: NavigatorState<NotesNavigation> {
        didSet {
            if oldValue == navigatorState {
                return
            }
            // Call completion closures correctly: from navigating to idle
            switch oldValue {
            case .navigating(from: _, let toNavigation, _, let completion):
                switch navigatorState {
                case .idle(let newNavigation):
                    assert(toNavigation == newNavigation)
                    if oldValue != navigatorState {
                        completion(navigatorState != .idle(toNavigation))
                    }
                default: break
                }
            default: break
            }

            // Configure vCs accordingly to new state
            switch navigatorState {
            case .navigating(_, let to, let animated, _):
               let navigationStack = to.navigationStack()
               let VCs = navigationStack.map { (navigation) -> UIViewController in
                getCorrectlyInstancedViewController(forNavigationEndpoint: navigation) ??
                    endpointsBuilder.buildEndpointRoutableViewController(forNavigationEndpoint: navigation,
                                                                         navigator: self,
                                                                         model: model)
               }
               navigationController.setPopOrPushViewControllers(VCs, animated: animated)
            default: break
            }

            print("[NOTESNAVIGATOR] \(navigatorState)")
        }
    }

    func getCorrectlyInstancedViewController(forNavigationEndpoint:NotesNavigation) -> UIViewController? {
        switch forNavigationEndpoint {
        case .folders:
            return navigationController.viewControllers.first
        case .folders👉list:
            guard let secondVC = navigationController.viewControllers[safe: 1],
                endpointsBuilder.correctlyConfigured(viewController: secondVC,
                                                     forNavigation: forNavigationEndpoint) else {
                                                        return nil
            }
            return secondVC
        case .folders👉🏻list👉note:
            guard let thirdVC = navigationController.viewControllers[safe: 2],
                endpointsBuilder.correctlyConfigured(viewController: thirdVC,
                                                     forNavigation: forNavigationEndpoint) else {
                                                        return nil
            }
            return thirdVC
        }
    }

    func getCurrentNavigation() -> NotesNavigation {
        var evaluatingNavigation: NotesNavigation
        switch navigatorState {
        case .idle(let currentNavigation):
            evaluatingNavigation = currentNavigation
        case .navigating(_, let to, _, _):
            evaluatingNavigation = to
        case .navigatingToNonFinalNavigation(_, let to, _, _, _):
            evaluatingNavigation = to
        }

        let evaluatingStack = evaluatingNavigation.navigationStack()
        assert(evaluatingStack.count >= navigationController.viewControllers.count)
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


extension NavigatorImpl : UINavigationControllerDelegate {

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
