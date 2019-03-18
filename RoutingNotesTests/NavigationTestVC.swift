//
//  NavigationTestVC.swift
//  RoutingNotesTests
//
//  Created by Sergi Hernanz on 21/01/2019.
//  Copyright © 2019 Sergi Hernanz. All rights reserved.
//

import UIKit
//@testable import RoutingNotes

class NavigationTestVC: UIViewController, Navigatable {

    typealias InputType = Any
    typealias OutputType = Any
    typealias NavigatorType = NotesStatefulNavigator
    typealias ModelType = NotesModelContext

    private(set) var navigator: NotesStatefulNavigator
    private(set) var model: NotesModelContext
    private(set) var navigationInput: Any
    private(set) var navigationOutput: Any?
    required init(navigator: NotesStatefulNavigator, model: NotesModelContext, navigationInput: Any) {
        self.navigator = navigator
        self.model = model
        self.navigationInput = navigationInput
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var foldersButton: UIButton = {
        let rect = CGRect(x: 0, y: 0, width: 375, height: 40)
        let foldersButton = UIButton(frame: rect)
        foldersButton.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        foldersButton.tag = 0
        foldersButton.setTitle("Deep link to folders", for: .normal)
        foldersButton.setTitleColor(.blue, for: .normal)
        foldersButton.setTitleColor(.black, for: .highlighted)
        foldersButton.showsTouchWhenHighlighted = true
        return foldersButton
    }()

    lazy var listButton: UIButton = {
        let rect = CGRect(x: 0, y: 0, width: 375, height: 40)
        let listButton = UIButton(frame: rect)
        listButton.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        listButton.tag = 1
        listButton.setTitle("Deep link to list 1", for: .normal)
        listButton.setTitleColor(.red, for: .normal)
        listButton.setTitleColor(.black, for: .highlighted)
        listButton.showsTouchWhenHighlighted = true
        return listButton
    }()

    lazy var noteButton: UIButton = {
        let rect = CGRect(x: 0, y: 0, width: 375, height: 40)
        let noteButton = UIButton(frame: rect)
        noteButton.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        noteButton.tag = 2
        noteButton.setTitle("Deep link to note A", for: .normal)
        noteButton.setTitleColor(.green, for: .normal)
        noteButton.setTitleColor(.black, for: .highlighted)
        noteButton.showsTouchWhenHighlighted = true
        return noteButton
    }()

    override func loadView() {

        let view = UIView()
        view.backgroundColor = .white
        let stack = UIStackView(arrangedSubviews: [foldersButton, listButton, noteButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 30
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            foldersButton.heightAnchor.constraint(equalToConstant: 44),
            foldersButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            listButton.heightAnchor.constraint(equalToConstant: 44),
            listButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            noteButton.heightAnchor.constraint(equalToConstant: 44),
            noteButton.widthAnchor.constraint(equalTo: view.widthAnchor),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        self.view = view
    }

    @objc func buttonTapped(button: UIButton) {
        switch button.tag {
        case 1:
            navigator.navigate(to: .main(.folders👉list(listId:"1")), animated: true) {_ in }
        case 2:
            navigator.navigate(to: .main(.folders👉list👉note(listId: "1", noteId: "A")), animated: true) {_ in }
        default:
            navigator.navigate(to: .main(.folders), animated: true) {_ in }
        }
    }

    //COLORED navigation item
    private func color(forTitle title: String) -> UIColor {
        switch title {
        case "Folders":
            return .blue
        case "List 1":
            return .red
        default:
            return .green
        }
    }

    private lazy var coloredNavigationItem: UINavigationItem = {
        let title = self.title ?? ""
        let navItem = UINavigationItem(title: title)
        let label = UILabel()
        label.attributedText = NSAttributedString(string: title,
                                                  attributes: [NSAttributedString.Key.foregroundColor: color(forTitle: title)])
        navItem.titleView = label
        navItem.backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        navItem.backBarButtonItem?.tintColor = color(forTitle: title)
        return navItem
    }()
    override var navigationItem: UINavigationItem {
        return coloredNavigationItem
    }

}
