//
//  NavigationEndpointsBuilder.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 20/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit

protocol NavigationEndpointsBuilder {
    associatedtype NavigationType : Navigation
    associatedtype NavigatorType : Navigator
    associatedtype ModelType

    var model: ModelType { get }
    init(model: ModelType)

    func getInstancedOrBuildViewController(forNavigationEndpoint:NavigationType,
                                           navigator: NavigatorType) -> UIViewController
    func getEndpointCorrectInstancedViewController(forNavigationEndpoint:NotesNavigation,
                                                   navigator: NavigatorType) -> UIViewController?
    func getCurrentNavigation(fromNavigator: NavigatorType) -> NavigationType
}
