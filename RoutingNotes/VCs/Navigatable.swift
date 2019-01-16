//
//  Navigatable.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 16/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import Foundation

protocol Navigatable {

    associatedtype InputType
    associatedtype OutputType

    var navigationInput: InputType { get }
    var navigationOutput: OutputType? { get }
    var navigator: Navigator { get }
    var model: OrdersModelContext { get }

    init(navigator:Navigator, model:OrdersModelContext, navigationInput: InputType);
}
