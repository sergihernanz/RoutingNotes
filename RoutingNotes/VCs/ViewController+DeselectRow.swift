//
//  ViewController+DeselectRow.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 20/12/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import UIKit

extension UIViewController {

    func deselectRow(tableView: UITableView, animated: Bool) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            if let coordinator = transitionCoordinator {
                coordinator.animate(alongsideTransition: { context in
                    tableView.deselectRow(at: selectedIndexPath, animated: true)
                }, completion: { context in
                    if context.isCancelled {
                        tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
                    }
                })
            } else {
                tableView.deselectRow(at: selectedIndexPath, animated: animated)
            }
        }
    }

}
