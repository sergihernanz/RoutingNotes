//
//  FoldersVC.swift
//  RoutingNotes
//
//  Created by Sergi Hernanz on 30/11/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import Foundation
import UIKit

class FoldersVC: UIViewController {

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) { fatalError() }
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    private(set) var navigator: NotesStatefulNavigator
    private(set) var model: NotesModelContext
    required init(navigator: NotesStatefulNavigator, model: NotesModelContext, navigationInput: Void) {
        self.navigator = navigator
        self.model = model

        do {
            try folders = model.fetch(request: NotesModelFetchRequest.emptyPredicate) as [List]
        } catch {
            folders = []
        }
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        view = table
    }

    private(set) var folders: [List] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = NSLocalizedString("Folders", comment: "Folders screen title")
        deselectRow(tableView: tableView, animated: animated)
    }
}

extension FoldersVC: UITableViewDataSource {

    static let cellReuseIdentifier = "listCell"

    var tableView: UITableView {
        return view as! UITableView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: FoldersVC.cellReuseIdentifier) ??
            UITableViewCell(style: .subtitle, reuseIdentifier: FoldersVC.cellReuseIdentifier)
    }

}

extension FoldersVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let list = folders[indexPath.row]
        guard let titleLabel = cell.textLabel,
            let subtitleLabel = cell.detailTextLabel else {
                assertionFailure()
                return
        }
        titleLabel.text = list.name
        do {
            subtitleLabel.text = "\(try list.fetchNotes(ctxt: model).count) notes"
        } catch {
            subtitleLabel.text = "0 notes"
        }
    }

}
