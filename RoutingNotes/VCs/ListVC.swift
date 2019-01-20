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

    private(set) var listInput : ListId

    private(set) var navigator:Navigator
    private(set) var model:NotesModelContext
    required init(navigator:Navigator, model:NotesModelContext, navigationInput:ListId) {
        self.navigator = navigator
        self.model = model
        self.listInput = navigationInput

        do {
            let list = try model.fetch(id: .list(listInput)) as List?
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
            let list = try model.fetch(id: .list(listInput)) as List?
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
}
