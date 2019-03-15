//
//  Navigator.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 23/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit

protocol Navigator: class {

    associatedtype NavigationType: Navigation
    associatedtype ModelType

    // Root viewcontroller to be presented on a VC hierarchy
    var rootViewController: UIViewController { get }

    // Information
    var currentNavigation: NavigationType { get }

    // Deep link
    func navigate(to: NavigationType, animated: Bool, completion: @escaping (_ cancelled: Bool) -> Void)

    // TODO: Normal navigation

    // TODO: Dependency based navigation
}
