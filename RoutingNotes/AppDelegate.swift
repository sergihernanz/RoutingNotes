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

        let useTestsEndpointsBuilder = ProcessInfo.processInfo.environment.keys.contains("TEST_ENDPOINTS_BUILDER")
        let model = populateMockModel()
        let anyEndpointsBuilder = !useTestsEndpointsBuilder ? AnyNavigationEndpointsBuilder(NotesNavigationEndpointsBuilderImpl()) :
                                                              AnyNavigationEndpointsBuilder(TestsEndpointsBuilder())
        let navigator = NotesStatefulNavigator(model: model,
                                      endpointsBuilder: anyEndpointsBuilder)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigator.rootViewController
        window.makeKeyAndVisible()
        self.window = window
        self.navigator = navigator

        loadLastAppLaunchNavigation()

        UNUserNotificationCenter.current().delegate = self
        //scheduleLocalNotification()
        //registerShortcuts()
        //registerCoreSpotlightEntries()

        return true
    }
}

extension AppDelegate {

    static let savedNavigationUserDefaultsKey = "savedNavigationUSerDefaultsKey"

    func loadLastAppLaunchNavigation() {
        // Load previous last navigation endpoint
        if let savedJSONNavigation = UserDefaults.standard.string(forKey: AppDelegate.savedNavigationUserDefaultsKey),
            let savedNavigation = NotesNavigation(jsonString: savedJSONNavigation) {
            navigator.navigate(to: savedNavigation, animated: false, completion: {_ in })
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.set(navigator.currentNavigation.toJSONString(),
                                  forKey: AppDelegate.savedNavigationUserDefaultsKey)
    }
}

extension AppDelegate {

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
            let jsonNavigationToNoteA = try JSONEncoder().encode(NotesNavigation.folders👉list👉note(listId: "1", noteId: "A"))
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
        if let navigation = NotesNavigation(jsonString: shortcutItem.type) {
            navigator.navigate(to: navigation, animated: false, completion: { _ in
                completionHandler(true)
            })
        }
    }
}

extension AppDelegate {

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let war = self.application(application, continueWebUserActivity: userActivity, restorationHandler: restorationHandler)
        let csr = self.application(application, continueCoreSpotlightUserActivity: userActivity, restorationHandler: restorationHandler)
        return war || csr
    }
}

// Handle opening links
extension AppDelegate {

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return open(link: url)
    }
    func application(_ application: UIApplication,
                     continueWebUserActivity userActivity: NSUserActivity,
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

import UserNotifications

// Handle opening notifications
extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let link = userInfo["link"] as? String,
           let navigation = NotesNavigation(jsonString: link) {
            navigator.navigate(to: navigation, animated: false, completion: { _ in
                completionHandler(.noData)
            })
        } else {
            completionHandler(.noData)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let link = notification.request.content.userInfo["link"] as? String,
           let navigation = NotesNavigation(jsonString: link) {
            navigator.navigate(to: navigation, animated: false, completion: { _ in
                completionHandler(.sound)
                self.begForgiveness()
            })
        } else {
            completionHandler(.alert)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let link = response.notification.request.content.userInfo["link"] as? String,
           let navigation = NotesNavigation(jsonString: link) {
            navigator.navigate(to: navigation, animated: false, completion: { _ in
                completionHandler()
            })
        } else {
            completionHandler()
        }
    }

    func scheduleLocalNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                let jsonNavigationToNoteA = NotesNavigation.folders👉list👉note(listId: "1", noteId: "A").toJSONString()
                let content = UNMutableNotificationContent()
                content.title = "Note A has changed"
                content.body = "See the latest changes in List 1: Note A"
                content.userInfo = ["link": jsonNavigationToNoteA as Any]

                // Create the trigger as a repeating event.
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                // Create the request
                let uuidString = UUID().uuidString
                let request = UNNotificationRequest(identifier: uuidString,
                                                    content: content,
                                                    trigger: trigger)

                // Schedule the request with the system.
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.add(request) { (error) in
                    if error != nil {
                        assertionFailure()
                    }
                }
            }
        }
    }

    func begForgiveness() {
        let alertController = UIAlertController(title: "Ups",
                                                message: "Mmm.. we've navigated to a local notification destination without asking",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "WTF! Ok", style: .destructive, handler: nil))
        navigator.rootViewController.present(alertController, animated: true, completion: nil)
    }
}

import CoreSpotlight
import CoreServices
extension AppDelegate {

    func registerCoreSpotlightEntries() {
        do {
            var spotlightItems = [CSSearchableItem]()
            for note in try navigator.model.fetch(request: NotesModelFetchRequest.emptyPredicate) as [Note] {
                let list = try note.fetchList(ctxt: navigator.model)
                let navigation = NotesNavigation.folders👉list👉note(listId: list.listId, noteId: note.noteId)
                let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                var keywords = [String]()
                keywords.append(note.title)
                searchableItemAttributeSet.title = note.title
                searchableItemAttributeSet.contentDescription = note.content
                searchableItemAttributeSet.keywords = keywords
                let searchableItem = CSSearchableItem(uniqueIdentifier: navigation.toJSONString(),
                                                      domainIdentifier: note.noteId,
                                                      attributeSet: searchableItemAttributeSet)
                spotlightItems.append(searchableItem)
            }
            CSSearchableIndex.default().indexSearchableItems(spotlightItems) { (error) -> Void in
                if let err = error {
                    print(err.localizedDescription)
                }
            }
        } catch {
        }
    }

    func application(_ application: UIApplication,
                     continueCoreSpotlightUserActivity userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            if let userInfo = userActivity.userInfo {
                if let jsonNavigation = userInfo[CSSearchableItemActivityIdentifier] as? String,
                   let navigation = NotesNavigation(jsonString: jsonNavigation) {
                    navigator.navigate(to: navigation, animated: false, completion: {_ in })
                    return true
                }
            }
        }
        return false
    }
}
