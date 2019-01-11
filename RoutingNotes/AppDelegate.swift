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
        let model = MockUDOrdersModelContext(persistenceName: "test")
        return OrdersModelContext(model)
    }

    var window: UIWindow?
    private var navigator: NavigatorImpl!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let model = populateMockModel()
        let navigator = NavigatorImpl(model:model)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigator.rootViewController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

}

