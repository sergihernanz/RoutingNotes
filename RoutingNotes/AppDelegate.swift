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

// Handle opening URLs
extension AppDelegate {

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return open(link: url)
    }
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                return open(link: url)
            }
        }
        return false
    }

    fileprivate func open(link: URL) -> Bool {
        do {
            if let navigation = try NotesLinkParser.navigation(url: link) {
                navigator.navigate(to: navigation, animated: false, completion: {_ in })
                return true
            }
        } catch {
            return false
        }
        return false
    }
}


class NotesLinkParser {

    static func navigation(url: URL) throws -> NotesNavigation? {
        let foldersRegex = try NSRegularExpression(pattern: "^routingnotes://folders$", options: .caseInsensitive)
        let listRegex = try NSRegularExpression(pattern: "^routingnotes://list/(\\w)$", options: .caseInsensitive)
        let noteRegex = try NSRegularExpression(pattern: "^routingnotes://list/(\\w)/note/(\\w)$", options: .caseInsensitive)
        let urlString = url.absoluteString
        let urlStringRange = NSRange(location: 0, length: urlString.count)
        let foldersMatches = foldersRegex.numberOfMatches(in: urlString, options: .anchored, range: urlStringRange)
        if foldersMatches > 0 {
            return .folders
        }
        let listMatches = listRegex.matches(in: urlString, options: .anchored, range: urlStringRange)
        if listMatches.count == 1,
           let match = listMatches.first,
           match.numberOfRanges == 2 {
            let listIdRange = match.range(at: 1)
            let listId = String(urlString[String.Index(encodedOffset: listIdRange.lowerBound)..<String.Index(encodedOffset: listIdRange.upperBound)])
            return .folders👉list(listId: listId)
        }
        let noteMatches = noteRegex.matches(in: urlString, options: .anchored, range: urlStringRange)
        if noteMatches.count == 1,
           let match = noteMatches.first,
           match.numberOfRanges == 3,
           let listIdRange = noteMatches.first?.range(at: 1),
           let noteIdRange = noteMatches.first?.range(at: 2) {
            let listId = String(urlString[String.Index(encodedOffset: listIdRange.lowerBound)..<String.Index(encodedOffset: listIdRange.upperBound)])
            let noteId = String(urlString[String.Index(encodedOffset: noteIdRange.lowerBound)..<String.Index(encodedOffset: noteIdRange.upperBound)])
            return .folders👉🏻list👉note(listId: listId, noteId: noteId)
        }
        return nil
    }
}
