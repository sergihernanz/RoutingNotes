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

    fileprivate func populateMockModel() -> NotesModelContext {
        let model = MockUDOrdersModelContext(persistenceName: "test")
        return NotesModelContext(model)
    }

    var window: UIWindow?
    private var navigator: NavigatorImpl!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let model = populateMockModel()
        let endpointsBuilder = NotesNavigationEndpointsBuilder()
        //let endpointsBuilder = TestsEndpointsBuilder()
        let navigator = NavigatorImpl(model:model,
                                      endpointsBuilder: endpointsBuilder)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigator.rootViewController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

}

