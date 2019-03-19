//
//  NoteVC+Routing.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 18/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit

extension NoteVC: Navigatable {

    typealias InputType = NoteId
    typealias OutputType = Void

    var navigationInput: NoteId {
        return noteInput
    }
    var navigationOutput: Void? {
        return nil
    }
    var viewController: UIViewController {
        return self
    }

}
