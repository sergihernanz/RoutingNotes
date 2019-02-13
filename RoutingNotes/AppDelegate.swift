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
    private var navigator: NotesStatefulNavigator!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let model = populateMockModel()
        let endpointsBuilder = NotesNavigationEndpointsBuilderImpl()
        let anyEndpointsBuilder = AnyNavigationEndpointsBuilder(endpointsBuilder)
        //let endpointsBuilder = TestsEndpointsBuilder()
        let navigator = NotesStatefulNavigator(model:model,
                                      endpointsBuilder: anyEndpointsBuilder)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigator.rootViewController
        window.makeKeyAndVisible()
        self.window = window
        self.navigator = navigator

        if let savedJSONNavigation = UserDefaults.standard.object(forKey: AppDelegate.savedNavigationUserDefaultsKey) as? Data {
            do {
                let savedNavigation = try JSONDecoder().decode(NotesNavigation.self, from: savedJSONNavigation)
                navigator.navigate(to: savedNavigation, animated: false, completion: {_ in })
            } catch {
            }
        }

        return true
    }

    static let savedNavigationUserDefaultsKey = "savedNavigationUSerDefaultsKey"
    func applicationDidEnterBackground(_ application: UIApplication) {
        do {
            let jsonNavigation = try JSONEncoder().encode(navigator.currentNavigation)
            UserDefaults.standard.set(jsonNavigation,
                                      forKey: AppDelegate.savedNavigationUserDefaultsKey)
        } catch {
        }
    }
    
}

