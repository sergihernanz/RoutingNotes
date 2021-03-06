//
//  Navigatable.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 16/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit

protocol Navigatable {

    associatedtype InputType
    associatedtype OutputType
    associatedtype NavigatorType
    associatedtype ModelType

    var navigationInput: InputType { get }
    var navigationOutput: OutputType? { get }
    var navigator: NavigatorType { get }
    var model: ModelType { get }

    init(navigator: NavigatorType, model: ModelType, navigationInput: InputType)

    // Root viewcontroller to be presented on a VC hierarchy
    var viewController: UIViewController { get }
}
