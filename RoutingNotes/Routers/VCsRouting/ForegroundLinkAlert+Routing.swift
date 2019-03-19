//
//  ForegroundLinkAlert+Routing.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 19/03/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit

class ForegroundAlert: Navigatable {

    var navigationInput: NotesNavigation
    var navigationOutput: Bool?
    var navigator: NotesStatefulNavigator
    var model: NotesModelContext

    required init(navigator: NotesStatefulNavigator, model: NotesModelContext, navigationInput: NotesNavigation) {
        self.navigationInput = navigationInput
        self.navigator = navigator
        self.model = model
    }

    private lazy var privateViewController: UIViewController = {
        let alertVC = UIAlertController(title: "",
                                        message: "Check out XXX",
                                        preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Go there", style: .default, handler: { _ in /*[weak self] _ in
            guard let self = self else {
                return
            }*/
            self.navigationOutput = true
            self.navigator.navigate(to: .main(self.navigationInput), animated: true) {_ in }
        }))
        alertVC.addAction(UIAlertAction(title: "Not now", style: .destructive, handler: { _ in /*[weak self] _ in
            guard let self = self else {
                return
            }*/
            self.navigationOutput = true
            switch self.navigator.currentNavigation {
            case .main(let notesNavigation), .modal(_, onTopOf: let notesNavigation):
                self.navigator.navigate(to: .main(notesNavigation), animated: true, completion: { _ in })
            }
        }))
        return alertVC
    }()
    var viewController: UIViewController {
        return privateViewController
    }

}
