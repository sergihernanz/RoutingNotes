//
//  NavigationEndpointsBuilder.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 20/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit

protocol TopNavigationItemBuilder {

    associatedtype NavigationType: Navigation
    associatedtype NavigatorType: Navigator
    associatedtype ModelType

    func isCorrectlyConfigured(viewController: UIViewController, forNavigation: NavigationType) -> Bool
    func buildTopItem(forNavigationEndpoint: NavigationType,
                      navigator: NavigatorType,
                      model: ModelType) -> UIViewController
}

private class _AnyNavigationEndpointsBuilderBase<NavigationType: Navigation, NavigatorType: Navigator, ModelType>: TopNavigationItemBuilder {

    init() {
        guard type(of: self) != _AnyNavigationEndpointsBuilderBase.self else {
            fatalError("_AnyNavigationEndpointsBuilderBase<_,_,_> instances can not be created, create a subclass instance instead")
        }
    }
    func buildTopItem(forNavigationEndpoint: NavigationType,
                      navigator: NavigatorType,
                      model: ModelType) -> UIViewController {
        fatalError("Method must be overriden")
    }
    func isCorrectlyConfigured(viewController: UIViewController, forNavigation: NavigationType) -> Bool {
        fatalError("Method must be overriden")
    }
}
fileprivate final class _AnyNavigationEndpointsBuilderBox<Concrete: TopNavigationItemBuilder>:
                            _AnyNavigationEndpointsBuilderBase<Concrete.NavigationType, Concrete.NavigatorType, Concrete.ModelType> {
    // variable used since we're calling mutating functions
    var concrete: Concrete
    init(_ concrete: Concrete) {
        self.concrete = concrete
    }
    override func buildTopItem(forNavigationEndpoint: Concrete.NavigationType,
                               navigator: Concrete.NavigatorType,
                               model: Concrete.ModelType) -> UIViewController {
        return concrete.buildTopItem(forNavigationEndpoint: forNavigationEndpoint,
                                     navigator: navigator,
                                     model: model)
    }
    override func isCorrectlyConfigured(viewController: UIViewController, forNavigation: Concrete.NavigationType) -> Bool {
        return concrete.isCorrectlyConfigured(viewController: viewController, forNavigation: forNavigation)
    }
}

final class AnyNavigationEndpointsBuilder<NavigationType: Navigation, NavigatorType: Navigator, ModelType>: TopNavigationItemBuilder {

    private let box: _AnyNavigationEndpointsBuilderBase<NavigationType, NavigatorType, ModelType>
    init<Concrete: TopNavigationItemBuilder>(_ concrete: Concrete) where Concrete.NavigationType == NavigationType,
                                                                           Concrete.NavigatorType == NavigatorType,
                                                                           Concrete.ModelType == ModelType {
        box = _AnyNavigationEndpointsBuilderBox(concrete)
    }
    func buildTopItem(forNavigationEndpoint: NavigationType,
                      navigator: NavigatorType,
                      model: ModelType) -> UIViewController {
        return box.buildTopItem(forNavigationEndpoint: forNavigationEndpoint,
                                navigator: navigator,
                                model: model)
    }
    func isCorrectlyConfigured(viewController: UIViewController, forNavigation: NavigationType) -> Bool {
        return box.isCorrectlyConfigured(viewController: viewController, forNavigation: forNavigation)
    }
}
