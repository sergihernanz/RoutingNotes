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
        registerShortcuts()
    }

    func registerShortcuts() {
        do {
            var items = [UIApplicationShortcutItem]()
            let favIcon = UIApplicationShortcutIcon(type: .favorite)
            let jsonNavigationToList1 = try JSONEncoder().encode(NotesNavigation.folders👉list(listId: "1"))
            if let jsonStringNavigationToList1 = String(data: jsonNavigationToList1, encoding: .utf8) {
                items.append(UIApplicationShortcutItem(type: jsonStringNavigationToList1,
                                                       localizedTitle: "List 1",
                                                       localizedSubtitle: nil,
                                                       icon: favIcon,
                                                       userInfo: nil))
            }
            let jsonNavigationToNoteA = try JSONEncoder().encode(NotesNavigation.folders👉🏻list👉note(listId: "1", noteId: "A"))
            if let jsonStringNavigationToNoteA = String(data: jsonNavigationToNoteA, encoding: .utf8) {
                items.append(UIApplicationShortcutItem(type: jsonStringNavigationToNoteA,
                                                       localizedTitle: "Note A",
                                                       localizedSubtitle: nil,
                                                       icon: favIcon,
                                                       userInfo: nil))
            }
            UIApplication.shared.shortcutItems = items
        } catch {
            UIApplication.shared.shortcutItems = nil
        }
    }

    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        do {
            guard let data = shortcutItem.type.data(using: .utf8) else {
                completionHandler(false)
                return
            }
            let navigation = try JSONDecoder().decode(NotesNavigation.self, from: data)
            navigator.navigate(to: navigation, animated:false, completion: { _ in
                completionHandler(true)
            })
        } catch {
            completionHandler(false)
        }
    }
}

