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

    private(set) var noteInput: NoteId

    var navigator: NotesStatefulNavigator
    var model: NotesModelContext
    required init(navigator: NotesStatefulNavigator, model:NotesModelContext, navigationInput:NoteId) {
        self.navigator = navigator
        self.model = model
        self.noteInput = navigationInput

        super.init(nibName: nil, bundle: nil)
    }

    lazy var titleTextField : UITextField = {
        let ret = UITextField()
        ret.translatesAutoresizingMaskIntoConstraints = false
        ret.backgroundColor = UIColor(white: 0.97, alpha: 1)
        ret.font = UIFont.systemFont(ofSize: 18)
        return ret
    }()
    lazy var bodyTextField : UITextView = {
        let ret = UITextView()
        ret.translatesAutoresizingMaskIntoConstraints = false
        ret.backgroundColor = UIColor(white: 0.97, alpha: 1)
        ret.font = UIFont.systemFont(ofSize: 14)
        return ret
    }()

    override func loadView() {
        let mainView = UIView(frame: UIScreen.main.bounds)
        mainView.backgroundColor = UIColor.white
        mainView.addSubview(titleTextField)
        mainView.addSubview(bodyTextField)
        let guide = mainView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.topAnchor.constraint(equalTo: titleTextField.topAnchor, constant:-16),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            titleTextField.bottomAnchor.constraint(equalTo: bodyTextField.topAnchor, constant:-8),
            guide.leftAnchor.constraint(equalTo: titleTextField.leftAnchor, constant:-16),
            guide.rightAnchor.constraint(equalTo: titleTextField.rightAnchor, constant:16),
            guide.bottomAnchor.constraint(equalTo: bodyTextField.bottomAnchor, constant:16),
            guide.leftAnchor.constraint(equalTo: bodyTextField.leftAnchor, constant:-16),
            guide.rightAnchor.constraint(equalTo: bodyTextField.rightAnchor, constant:16)
            ])
        view = mainView
    }

    private(set) var note : Note! {
        didSet {
            titleTextField.text = note.title
            bodyTextField.text = note.content
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try note = model.fetch(id: NotesModelId.note(noteInput))!
        } catch {
            fatalError()
        }
        navigationItem.title = note.title
    }

}
