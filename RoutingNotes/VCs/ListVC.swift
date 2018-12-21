//
//  ListVC.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 30/11/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import Foundation
import UIKit

class ListVC : UIViewController {

    @available(*,unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) { fatalError() }
    @available(*,unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    private(set) var routeInput : ListId

    fileprivate var navigator:Navigator
    fileprivate var model:OrdersModelContext
    init(navigator:Navigator, model:OrdersModelContext, listId:ListId) {
        self.navigator = navigator
        self.model = model
        self.routeInput = listId

        do {
            let list = try model.fetch(id: .list(routeInput)) as List?
            if let l = list {
                try notes = l.fetchNotes(ctxt: model)
            } else {
                notes = []
            }
        } catch {
            notes = []
        }
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        view = table
    }

    var notes : [Note] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deselectRow(tableView: tableView, animated: animated)

        do {
            let list = try model.fetch(id: .list(routeInput)) as List?
            if let listName = list?.name {
                navigationItem.title = listName
            }
        } catch {
            assertionFailure()
        }
    }
}

extension ListVC : UITableViewDataSource {

    static let cellReuseIdentifier = "listCell"

    var tableView : UITableView {
        return view as! UITableView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: ListVC.cellReuseIdentifier) ??
            UITableViewCell(style: .subtitle, reuseIdentifier: ListVC.cellReuseIdentifier)
    }

}

extension ListVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        guard let titleLabel = cell.textLabel,
            let subtitleLabel = cell.detailTextLabel else {
                assertionFailure()
                return
        }
        titleLabel.text = note.title
        subtitleLabel.text = String(describing: note.modifiedDate)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        let newNavigation = Navigation.folders👉🏻list👉note(listId: routeInput, noteId: note.noteId)
        navigator.navigate(to: newNavigation) {}
    }
}
