//
//  NoteVC.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 30/11/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import Foundation
import UIKit

class NoteVC : UIViewController {

    @available(*,unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) { fatalError() }
    @available(*,unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    private(set) var routeInput : NoteId

    fileprivate var navigator:Navigator
    fileprivate var model:OrdersModelContext
    init(navigator:Navigator, model:OrdersModelContext, noteId:NoteId) {
        self.navigator = navigator
        self.model = model
        self.routeInput = noteId
        super.init(nibName: nil, bundle: nil)
    }
}
