//
//  AppDelegate.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 28/11/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    fileprivate func populateMockModel() -> OrdersModelContext {
        let model = UserDefaultsOrdersModelContext(persistenceName: "test")
        do {
            let notes : [Note] = try model.fetch(request: NotesModelFetchRequest.emptyPredicate)
            let lists : [List] = try model.fetch(request: NotesModelFetchRequest.emptyPredicate)
            assert(notes.count>0)
            assert(lists.count>0)
        } catch (_) {
            fatalError()
        }
        do {
            let anyContext = OrdersModelContext(model)
            let notes : [Note] = try anyContext.fetch(request: NotesModelFetchRequest.emptyPredicate)
            let lists : [List] = try anyContext.fetch(request: NotesModelFetchRequest.emptyPredicate)
            assert(notes.count>0)
            assert(lists.count>0)
        } catch (_) {
            fatalError()
        }
        return OrdersModelContext(model)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        let model = populateMockModel()
        _ = NavigatorImpl(window: window, model:model)
        window.makeKeyAndVisible()

        return true
    }

}

